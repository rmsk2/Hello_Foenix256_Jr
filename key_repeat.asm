
TimerHelp_t .struct 
    interval .byte 0
    cookie   .byte 0
.endstruct

KeyTracking_t .struct
    numMeasureTimersInFlight .byte 0
    keyUpDownCount           .byte 0
    lastKeyPressed           .byte 0
    lastKeyReleased          .byte 0
.endstruct


keyrepeat .namespace

init
    stz TRACKING.numMeasureTimersInFlight 
    stz TRACKING.lastKeyPressed
    stz TRACKING.keyUpDownCount
    stz TRACKING.lastKeyReleased
    rts

MEASUREMENT_TIMEOUT = 30
REPEAT_TIMEOUT = 3
COOKIE_MEASUREMENT_TIMER = $10
COOKIE_REPEAT_TIMER = $11

TIMER_HELP .dstruct TimerHelp_t
TRACKING .dstruct KeyTracking_t

makeTimer .macro interval, cookie
    lda #\interval
    sta TIMER_HELP.interval
    lda #\cookie
    sta TIMER_HELP.cookie
    jsr setTimer60thSeconds
.endmacro


; set a timer that fires after the number of 1/60 th seconds
; as the contents of the accu specifies
setTimer60thSeconds
    sta TIMER_HELP.interval
    ; get current value of timer
    lda #kernel.args.timer.FRAMES | kernel.args.timer.QUERY
    sta kernel.args.timer.units
    jsr kernel.Clock.SetTimer
    ; carry should be clear here as previous jsr clears it, when no error occurred
    ; make a timer which fires interval units from now
    adc TIMER_HELP.interval
    sta kernel.args.timer.absolute
    lda #kernel.args.timer.FRAMES
    sta kernel.args.timer.units
    lda TIMER_HELP.cookie
    sta kernel.args.timer.cookie
    ; Create timer
    jsr kernel.Clock.SetTimer 
    rts


; waiting for a key press event from the kernel
waitForKey
    ; Peek at the queue to see if anything is pending
    lda kernel.args.events.pending ; Negated count
    bpl waitForKey
    ; Get the next event.
    jsr kernel.NextEvent
    bcs waitForKey
    ; Handle the event
    lda myEvent.type    
    cmp #kernel.event.key.PRESSED
    bne _checkKeyRelease
    jsr handleKeyPressEvent
    bcs waitForKey
    rts
_checkKeyRelease
    cmp #kernel.event.key.RELEASED
    bne _checkTimer
    jsr handleKeyReleaseEvent
    bra waitForKey
_checkTimer
    cmp #kernel.event.timer.EXPIRED
    bne waitForKey
    jsr handleTimerEvent
    bcs waitForKey
    rts


handleKeyPressEvent
    lda myEvent.key.flags 
    and #myEvent.key.META
    beq _isAscii
    lda myEvent.key.raw
    jsr testForFKey
    bcs _handleFKey
    sec                                           ; we did not recognize the key. Make another loop iteration in waitForKeyRepeat
    rts
_handleFKey
    lda myEvent.key.raw    
    bra _startMeasureTimer
_isAscii
    lda myEvent.key.ascii
_startMeasureTimer
    sta TRACKING.lastKeyPressed
    #makeTimer MEASUREMENT_TIMEOUT, COOKIE_MEASUREMENT_TIMER
    inc TRACKING.numMeasureTimersInFlight
    inc TRACKING.keyUpDownCount
    lda TRACKING.lastKeyPressed
    clc                                          ; The user pressed a key. Stop iteration in waitForKeyRepeat
    rts


handleKeyReleaseEvent
    lda myEvent.key.flags 
    and #myEvent.key.META
    beq _isAscii
    lda myEvent.key.raw
    jsr testForFKey
    bcs _handleFKey
    rts
_handleFKey
    lda myEvent.key.raw
    bra _updateTracking
_isAscii
    lda myEvent.key.ascii
_updateTracking
    sta TRACKING.lastKeyReleased
    dec TRACKING.keyUpDownCount
    rts


handleTimerEvent
    lda myEvent.timer.cookie
    cmp #COOKIE_MEASUREMENT_TIMER
    bne _checkRepeatTimer
    jsr handleMeasurementTimer
    rts
_checkRepeatTimer
    cmp #COOKIE_REPEAT_TIMER
    bne _wrongTimer
    jsr handleRepeatTimer
    rts
_wrongTimer
    sec
    rts


handleMeasurementTimer
    lda TRACKING.keyUpDownCount
    cmp #1                                         ; There should be exactly one key still being pressed
    beq _testForNumInFlight
    dec TRACKING.numMeasureTimersInFlight
    bra _noRepeat                                  ; No key or several keys currently pressed => do nothing. Cause another loop iteration in waitForKeyRepeat
_testForNumInFlight
    dec TRACKING.numMeasureTimersInFlight
    bne _noRepeat                                  ; zero flag not set => There is at least one other timer in flight, so the one which arrived was not the last to be created
    lda TRACKING.lastKeyPressed
    cmp TRACKING.lastKeyReleased
    beq _noRepeat                                  ; last key pressed and released are are the same *and* there is one key pressed. This can't be right ...
    #makeTimer REPEAT_TIMEOUT, COOKIE_REPEAT_TIMER ; start repeat timer
    lda TRACKING.lastKeyPressed                    ; return key press to caller => Stop iteration in waitForKeyRepeat
    clc
    rts
_noRepeat
    sec                                            ; Cause another loop iteration in waitForKeyRepeat
    rts


handleRepeatTimer
    lda TRACKING.keyUpDownCount
    cmp #1                                         ; There should be exactly one key still being pressed
    beq _testRestartRepeat
    bra _noRepeat                                  ; No key or several keys currently pressed => do nothing. Cause another loop iteration in waitForKeyRepeat
_testRestartRepeat
    lda TRACKING.lastKeyPressed
    cmp TRACKING.lastKeyReleased
    beq _noRepeat                                  ; last key pressed and released are are the same *and* there is one key pressed. This can't be right ...
    #makeTimer REPEAT_TIMEOUT, COOKIE_REPEAT_TIMER ; start repeat timer
    lda TRACKING.lastKeyPressed                    ; return key press to caller => Stop iteration in waitForKeyRepeat
    clc    
    rts
_noRepeat
    sec                                            ; Cause another loop iteration in waitForKeyRepeat
    rts

.endnamespace