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
    jsr initTxtIo
    jsr initEvents

    lda #65
    sta COUNT
_out
    jsr charOut
    inc COUNT
    lda COUNT
    cmp #65+26
    bne _out

    lda #79
    sta CURSOR_STATE.xPos
    lda #59
    sta CURSOR_STATE.yPos
    jsr cursorSet

    lda #97
    sta COUNT
_out2
    jsr charOut
    inc COUNT
    lda COUNT
    cmp #97+26
    bne _out2

    jsr restoreEvents
    rts
