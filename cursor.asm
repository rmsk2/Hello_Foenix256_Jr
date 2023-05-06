.include "api.asm"
.include "macros.asm"

; target address is $4000
* = $4000
.cpu "w65c02"

OUT_LINE = 29
CURSOR_X = $D014
CURSOR_Y = $D016

; --------------------------------------------------
; This routine is the entry point of the program
;--------------------------------------------------
main
    jsr initEvents

    #kprint 0, OUT_LINE - 3, startedTxt, len(startedTxt), startedColor
    jsr waitForKey

    ldx #10
    lda #10
    jsr setCursor

    #kprint 0, OUT_LINE - 3, started2Txt, len(started2Txt), started2Color
    jsr waitForKey
    ldx #30
    lda #20
    jsr setCursor


    #kprint 0, OUT_LINE - 3, started3Txt, len(started3Txt), started3Color
    jsr waitForKey

    jsr printAllChars

    jsr restoreEvents
    rts

setCursor
    stz CURSOR_X+1
    stx CURSOR_X
    stz CURSOR_Y+1
    sta CURSOR_Y
    rts

printAllChars
    #load16BitImmediate ($C000 + 30*80), $90
    ; save current I/O page configuration
    lda $0001
    pha

    lda #$02
    sta $0001; Swap I/O Page 2 into bank 6

    ldy #0
_loopChars    
    tya
    sta ($90), y
    iny
    bne _loopChars
    
    ; restore I/O page configuration
    pla
    sta $0001


.include "khelp.asm"

startedTxt .text "Press key to set cursor to 10,10"
startedColor .text x"62" x len(startedTxt)

started2Txt .text "Press key to set cursor to 30,20"
started2Color .text x"32" x len(started2Txt)

started3Txt .text "Press key to print full font       "
started3Color .text x"D2" x len(started3Txt)