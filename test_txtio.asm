; target address is $4000
* = $4000
.cpu "w65c02"

jmp main

.include "api.asm"
.include "zeropage.asm"
.include "macros.asm"
.include "txtio.asm"
.include "khelp.asm"

COUNT .byte 0

main
    jsr txtio.init
    jsr initEvents

    lda #$92
    sta CURSOR_STATE.col
    jsr txtio.clear

    ldy #65
_out
    tya
    jsr txtio.charOut
    iny
    cpy #65+26
    bne _out

    lda #79
    sta CURSOR_STATE.xPos
    lda #58
    sta CURSOR_STATE.yPos
    jsr txtio.cursorSet

    ldy #97
_out2
    tya
    jsr txtio.charOut
    iny
    cpy #97+26
    bne _out2

    jsr txtio.left

    lda #$30
    jsr txtio.charOut
    lda #$30
    jsr txtio.charOut

    jsr txtio.backSpace

    jsr txtio.scrollUp

    jsr restoreEvents
    rts
