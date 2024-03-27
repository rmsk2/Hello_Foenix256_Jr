; target address is $4000
* = $4000
.cpu "w65c02"

jmp keyrepeat.main

.include "api.asm"
.include "zeropage.asm"
.include "macros.asm"
.include "txtio.asm"
.include "khelp.asm"

START_TXT1 .text "Use cursor keys to control cursor, c to clear screen, x to quit", $0d
START_TXT2 .text "Other keys are printed raw", $0d
DONE_TXT .text $0d, "Done!", $0d

CRLF = $0D
KEY_X = $78
KEY_C = $63
CRSR_UP = $10
CRSR_DOWN = $0E
CRSR_LEFT = $02
CRSR_RIGHT = $06


TimerHelp_t .struct 
    interval .byte 0
    cookie   .byte 0
.endstruct

KeyTracking_t .struct
    numMeasureTimersInFlight .byte 0
    numRepeatTimersInFlight  .byte 0
    keyUpDownCount           .byte 0
    lastKeyPressed           .byte 0
    lastKeyReleased          .byte 0
.endstruct


keyrepeat .namespace

main
    jsr txtio.init
    jsr init
    jsr initEvents

    ; set fore- and background colours
    lda #$92
    sta CURSOR_STATE.col

    #printString START_TXT1, len(START_TXT1)
    #printString START_TXT2, len(START_TXT2)
    jsr waitForKey

    #printString DONE_TXT, len(DONE_TXT)
    jsr restoreEvents
    rts


MEASUREMENT_TIMEOUT = 30
REPEAT_TIMEOUT = 3
COOKIE_MEASUREMENT_TIMER = $10
COOKIE_REPEAT_TIMER = $11
IMPOSSIBLE_KEY = 0


init
    stz TRACKING.numMeasureTimersInFlight 
    stz TRACKING.numRepeatTimersInFlight 
    stz TRACKING.lastKeyPressed
    stz TRACKING.keyUpDownCount
    lda #IMPOSSIBLE_KEY
    sta TRACKING.lastKeyReleased
    rts


TIMER_HELP .dstruct TimerHelp_t
TRACKING .dstruct KeyTracking_t

makeTimer .macro interval, cookie
    lda #\interval
    sta TIMER_HELP.interval
    lda #\cookie
    sta TIMER_HELP.cookie
    jsr setTimer60thSeconds
.endmacro

saveReg .macro 
    php
    pha
    phx
    phy
.endmacro

restoreReg .macro 
    ply
    plx
    pla
    plp
.endmacro


visKeyUpDown
    #saveReg
    #saveIoState
    #toTxtMatrix
    lda TRACKING.keyUpDownCount    
    and #$F0
    lsr
    lsr
    lsr
    lsr
    tay
    lda txtio.PRBYTE.hex_chars, y
    sta $C000
    lda TRACKING.keyUpDownCount
    and #$0F
    tay
    lda txtio.PRBYTE.hex_chars, y
    sta $C001
    #restoreIoState
    #restoreReg
    rts

; set a timer that fires after the number of 1/60 th seconds
setTimer60thSeconds
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
    jsr processKeyEvent
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
    jsr processKeyEvent
    bcs waitForKey
    rts


processKeyEvent
_charLoop
    cmp #KEY_X
    bne _checkUp
    clc
    rts
_checkUp
    cmp #CRSR_UP
    bne _checkDown
    jsr txtio.up
    sec
    rts
_checkDown
    cmp #CRSR_DOWN
    bne _checkLeft
    jsr txtio.down
    sec
    rts
_checkLeft
    cmp #CRSR_LEFT
    bne _checkRight
    jsr txtio.left
    sec
    rts
_checkRight
    cmp #CRSR_RIGHT
    bne _checkClear
    jsr txtio.right
    sec
    rts
_checkClear
    cmp #KEY_C
    bne _print
    jsr txtio.clear
    jsr txtio.home
    sec
    rts
_print
    jsr txtio.charOut
    sec
    rts


handleKeyPressEvent
    lda myEvent.key.flags 
    and #myEvent.key.META
    beq _isAscii
    lda myEvent.key.raw
    jsr testForFKey
    bcs _handleFKey
    sec                                            ; we did not recognize the key. Make another loop iteration in waitForKey
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
    clc                                            ; The user pressed a key. Stop iteration in waitForKey and return key code.
    ;jsr visKeyUpDown
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
    ldx myEvent.key.raw
    bra _updateTracking
_isAscii
    ldx myEvent.key.ascii
_updateTracking
    lda TRACKING.keyUpDownCount
    beq _done                                      ; counter is already zero => we have missed an event. Do not activate repeat. In essence ignore event.
    dec TRACKING.keyUpDownCount
    bne _continue
    ldx #IMPOSSIBLE_KEY                            ; counter was zero, this means that we can allow last key pressed == last key released
_continue
    stx TRACKING.lastKeyReleased                   ; State seems to be consistent. Save code of released key.
_done
    ;jsr visKeyUpDown
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
    lda TRACKING.numMeasureTimersInFlight
    beq _noRepeat                                  ; don't decrement if already zero. We seem to have missed some events.
    dec TRACKING.numMeasureTimersInFlight
    bra _noRepeat                                  ; No key or several keys currently pressed => do nothing. Cause another loop iteration in waitForKey
_testForNumInFlight
    lda TRACKING.numMeasureTimersInFlight
    beq _noRepeat                                  ; counter is already zero => we have missed an event. Do not activate repeat
    dec TRACKING.numMeasureTimersInFlight
    bne _noRepeat                                  ; zero flag not set => There is at least one other timer in flight, so the one which arrived was not the last to be created
    lda TRACKING.lastKeyPressed
    cmp TRACKING.lastKeyReleased
    beq _noRepeat                                  ; last key pressed and released are are the same *and* there is one key pressed. This can't be right ...
    #makeTimer REPEAT_TIMEOUT, COOKIE_REPEAT_TIMER ; start repeat timer
    inc TRACKING.numRepeatTimersInFlight
    lda TRACKING.lastKeyPressed                    ; return key press to caller => Stop iteration in waitForKey
    clc
    rts
_noRepeat
    sec                                            ; Cause another loop iteration in waitForKey
    rts


handleRepeatTimer
    lda TRACKING.numRepeatTimersInFlight
    beq _noRepeat                                  ; We received a timer event even though we did not record the timer creation => something went wrong
    cmp #1
    beq _continue                                  ; Exactly one timer in flight, i.e. this is the one we received
    dec TRACKING.numRepeatTimersInFlight           ; More than one are in flight => We wait for the youngest and ignore this one
    bra _noRepeat
_continue
    dec TRACKING.numRepeatTimersInFlight
    lda TRACKING.keyUpDownCount
    cmp #1                                         ; There should be exactly one key still being pressed
    beq _testRestartRepeat
    bra _noRepeat                                  ; No key or several keys currently pressed => do nothing. Cause another loop iteration in waitForKey
_testRestartRepeat
    lda TRACKING.lastKeyPressed
    cmp TRACKING.lastKeyReleased
    beq _noRepeat                                  ; last key pressed and released are are the same *and* there is one key pressed. This can't be right ...
    #makeTimer REPEAT_TIMEOUT, COOKIE_REPEAT_TIMER ; start repeat timer
    inc TRACKING.numRepeatTimersInFlight
    lda TRACKING.lastKeyPressed                    ; return key press to caller => Stop iteration in waitForKey
    clc    
    rts
_noRepeat
    sec                                            ; Cause another loop iteration in waitForKey
    rts

.endnamespace