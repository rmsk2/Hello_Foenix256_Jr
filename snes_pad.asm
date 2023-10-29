.include "api.asm"

; target address is $4000
* = $4000
.cpu "w65c02"

PAD_REG = $D880
PAD1_REG1 = $D884
PAD1_REG2 = $D885
OUT_LINE = 29
SET_NES_EN =   %00000001
SET_MODE =     %00000100
SET_NES_TRIG = %10000000
CLR_NES_TRIG = %01111111
TEST_DONE =    %01000000

.include "macros.asm"

; --------------------------------------------------
; This routine is the entry point of the program
;--------------------------------------------------
main
    jsr initEvents

    ; 1. Set NES_EN of NES_CTRL to enable the NES/SNES support (see table 12.2) and set or clear
    ;    MODE, to choose between NES mode or SNES mode.
    lda #SET_NES_EN | SET_MODE
    sta PAD_REG

    #kprint 0, OUT_LINE - 3, intro, len(intro), introColor
    jsr kernelLoop

    jsr restoreEvents
    rts


kernelLoop
    jsr querySnesPad

    ; Peek at the queue to see if anything is pending
    lda kernel.args.events.pending ; Negated count
    bpl kernelLoop
    ; Get the next event.
    jsr kernel.NextEvent
    bcs kernelLoop
    ; Handle the event
    lda myEvent.type    
    
    cmp #kernel.event.key.PRESSED
    beq _done    

    bra kernelLoop
_done
    #kprint 0, OUT_LINE + 2, msgDone, len(msgDone), introColor
    rts    


.include "khelp.asm"

querySnesPad
    ; 2. Set NES_TRIG of NES_CTRL to sample the buttons and transfer the data to the registers.
    lda PAD_REG
    ora #SET_NES_TRIG
    sta PAD_REG

    ; 3. Read NES_STAT and wait until the DONE bit is set
_sample
    ; now wait for DONE
    lda PAD_REG
    and #TEST_DONE
    beq _sample

    ; 4. Check the appropriate NES or SNES control registers (see table 12.3)    
    lda PAD1_REG1
    sta REG1_VAL
    lda PAD1_REG2
    sta REG2_VAL

    ; 5. Clear NES_TRIG
    lda PAD_REG
    and #CLR_NES_TRIG
    sta PAD_REG 

    jsr procPadInfo

    rts


REG1_VAL .byte 0
REG2_VAL .byte 0

procPadInfo
    lda REG1_VAL
    #toBin pad1
    lda REG2_VAL
    #toBin pad2
    #kprint 0, OUT_LINE + 1, pad1, len(pad1), dataColor
    #kprint 9, OUT_LINE + 1, pad2, len(pad2), dataColor
    rts

CONV_HELP .byte 0
toBin .macro addr
    sta CONV_HELP
    ldy #0
_loop    
    asl CONV_HELP
    bcs _oneBit
    lda #$30
    sta \addr, y
    bra _next
_oneBit    
    lda #$31
    sta \addr, Y
_next
    iny
    cpy #8
    bne _loop
    .endmacro

intro .text "Press keys on gamepad. Press any key on keyboard to stop."
introColor .text x"26" x len(intro)

msgDone .text "Done"

pad1 .text "        "
pad2 .text "        "

dataColor .text x"62" x len(intro)
