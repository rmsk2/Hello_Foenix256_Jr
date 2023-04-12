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
; This macro print a string to the screen at a given x and y coordinate. The 
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
     lda #\len                                     ; set text length
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


move16Bit .macro src, target
    lda \src
    sta \target
    lda \src+1
    sta \target+1
    .endmacro

; clear SID register
clearSID .macro 
    ldx #0
    lda #0
_loopRegister
    sta SID_BASE, x
    inx
    cpx #25
    bne _loopRegister
    .endmacro


; set volume for SID
setGlobalVolume .macro volume
    lda #\volume
    and #%00001111
    sta SID_BASE + 24
    .endmacro

                 
setBeepADSR .macro timeAttack, timeDecay, volumeSustain, timeRelease, voice 
    lda #\timeAttack                        ; time to reach full volume
    asl
    asl
    asl
    asl
    ora #\timeDecay                         ; time to fall to .volumeSustain
    sta SID_BASE + 5 + ((\voice-1) * 7)
    lda #\volumeSustain                     ; volume during sustain
    asl
    asl
    asl
    asl
    ora #\timeRelease                       ; time to reach zero volume after sound is turned off (key bit = 0)
    sta SID_BASE + 6 + ((\voice-1) * 7)     
    .endmacro


turnWaveOn .macro waveBit, voice
    lda SID_BASE + 4 + ((\voice-1) * 7)
    and #%00001111
    ora #\waveBit
    ora #1                                  ; set key bit => turn sound on
    sta SID_BASE + 4 + ((\voice-1) * 7)     ; make it happen
    .endmacro


turnWaveOff .macro waveBit, voice
    lda SID_BASE + 4 + ((\voice-1) * 7)
    and #%00001110
    ora #\waveBit                           ; key bit was cleared in line above
    sta SID_BASE + 4 + ((\voice-1) * 7)     ; make it happen
    .endmacro


setFrequency .macro frequency, voice
    #load16BitImmediate \frequency, SID_BASE + ((\voice-1) * 7)
    .endmacro


main
    ; take event queue away from BASIC
    jsr initEvents

    #clearSID

    ; global volume to maximum
    #setGlobalVolume 15
    ; set envelope
    #setBeepADSR 0, 0, 8, 0, 1
    ; set frequency
    #setFrequency $311c, 1

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


oldEvent .byte 0, 0
initEvents
    #move16Bit kernel.args.events, oldEvent
    #load16BitImmediate myEvent, kernel.args.events
    rts


restoreEvents
    #move16Bit oldEvent, kernel.args.events
    rts


myEvent .dstruct kernel.event.event_t

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


pressKeyStart .text "Press key to start sound"
pressKeyStartColor .text x"62" x len(pressKeyStart)

pressKeyEnd .text "Press key to end sound"
pressKeyEndColor .text x"62" x len(pressKeyEnd)

msgDone .text "Done"
msgDoneColor .text x"62" x len(msgDone)