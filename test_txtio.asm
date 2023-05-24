; target address is $4000
* = $4000
.cpu "w65c02"

jmp main

.include "api.asm"
.include "zeropage.asm"
.include "macros.asm"
.include "txtio.asm"
.include "khelp.asm"

TEST_MSG .text $0d, "Press any key", $0d

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

    lda #60
    sta CURSOR_STATE.xPos
    lda #59
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
    jsr txtio.down
    
    #load16BitImmediate TEST_MSG, TXT_PTR3
    lda #15
    jsr txtio.printStr

    jsr waitForKey

    jsr restoreEvents
    rts
