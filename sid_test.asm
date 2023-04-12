.include "api.asm"
; target address is $4000
* = $4000
.cpu "w65c02"

SID_BASE = $D400

TRIANGLE = 16
SAWTOOTH = 32
SQUARE = 64
NOISE = 128

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

; --------------------------------------------------
; load16BitImmediate loads the 16 bit value given in the first argument 
; into the memory location given the second argument
; --------------------------------------------------
load16BitImmediate .macro addr, target
    lda #<\addr
    sta \target
    lda #>\addr
    sta \target+1
    .endmacro


; move a 16 bit value from one location to the other
move16Bit .macro src, target
    lda \src
    sta \target
    lda \src+1
    sta \target+1
    .endmacro

.include "sid_only.asm"

; The name says it all
main
    ; take event queue away from BASIC
    jsr initEvents

    #clearSID

    ; global volume to maximum
    #setGlobalVolume 15
    ; set envelope
    #setBeepADSR 0, 0, 8, 0, 1
    ; set frequency
    #setFrequency $211c, 1

    #kprint 0, 30, pressKeyStart, len(pressKeyStart), pressKeyStartColor
    jsr waitForKey

    #turnWaveOn TRIANGLE, 1

    #kprint 0, 31, pressKeyEnd, len(pressKeyEnd), pressKeyEndColor
    jsr waitForKey
 
    #turnWaveOff TRIANGLE, 1

    ; restore event queue to values set by BASIC
    jsr restoreEvents

    #kprint 0, 32, msgDone, len(msgDone), msgDoneColor

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

pressKeyEnd .text "Press key to end sound"
pressKeyEndColor .text x"62" x len(pressKeyEnd)

msgDone .text "Done"
msgDoneColor .text x"62" x len(msgDone)