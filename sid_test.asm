.include "api.asm"

; target address is $4000
* = $4000
.cpu "w65c02"

SID_LEFT =  $D400
SID_RIGHT = $D500

SID_TO_USE = SID_RIGHT

.include "sid_only.asm"


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

.include "khelp.asm"

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
