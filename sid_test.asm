.include "api.asm"

; target address is $4000
* = $4000
.cpu "w65c02"

SID_LEFT =  $D400
SID_RIGHT = $D500

SID_TO_USE = SID_RIGHT

.include "sid_only.asm"


; --------------------------------------------------
; This macro prints a string to the screen at a given x and y coordinate. The 
; macro has the following parameters
;
; 1. x coordinate
; 2. y corrdinate
; 3. address of text to print
; 4. length of text to print
; 5. address of color information
;--------------------------------------------------
kprint .macro x, y, txtPtr, len, colPtr
     lda #\x                                     ; set x coordinate
     sta kernel.args.display.x
     lda #\y                                     ; set y coordinate
     sta kernel.args.display.y
     #load16BitImmediate \txtPtr, kernel.args.display.text
     lda #\len                                   ; set text length
     sta kernel.args.display.buflen
     #load16BitImmediate \colPtr, kernel.args.display.color
     jsr kernel.Display.DrawRow                  ; print to the screen
     .endmacro


; move a 16 bit value from one location to the other
move16Bit .macro src, target
    lda \src
    sta \target
    lda \src+1
    sta \target+1
    .endmacro


; The name says it all
main
    ; make sure whe receive kernel events
    jsr initEvents

    #kprint 0, 30, pressKeyStart, len(pressKeyStart), pressKeyStartColor
    jsr waitForKey

    #clearSID SID_TO_USE
    #setGlobalVolume SID_TO_USE, 15
    #setBeepADSR SID_TO_USE, 12, 2, 5, 10, 1
    #setFrequency SID_TO_USE, 8*256+180, 1
    #turnWaveOn SID_TO_USE, SAWTOOTH, 1

    jsr delay

    #turnWaveOff SID_TO_USE, SAWTOOTH, 1

    #kprint 0, 31, msgDone, len(msgDone), msgDoneColor

    ; restore event queue of superbasic
    jsr restoreEvents

    rts

loCount .byte 0
middleCount .byte 0
hiCount .byte 0

; A simple counting loop to cause a delay in the program 
delay
    stz loCount
    stz middleCount
    stz hiCount

_loop
    inc loCount
    bne _loop
    inc middleCount
    bne _loop
    inc hiCount
    lda hiCount
    cmp #$10
    bne _loop

    rts


; value of event buffer at program start (likely set by `superbasic`)
oldEvent .byte 0, 0

; set event buffer to new value
initEvents
    #move16Bit kernel.args.events, oldEvent
    #load16BitImmediate myEvent, kernel.args.events
    rts


; restore original event buffer
restoreEvents
    #move16Bit oldEvent, kernel.args.events
    rts


; the new event buffer
myEvent .dstruct kernel.event.event_t

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
    beq _done
    bra waitForKey
_done
    rts    


; Texts to display
pressKeyStart .text "Press key to start sound"
pressKeyStartColor .text x"62" x len(pressKeyStart)

msgDone .text "Done"
msgDoneColor .text x"62" x len(msgDone)
