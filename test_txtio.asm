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
UPPER .text "ABCDEFGHIJKLMNOPQRTSUVWXYZ"
LOWER .text "abcdefghijklmnopqrstuvwxyz"

main
    jsr txtio.init
    jsr initEvents

    lda #$92
    sta CURSOR_STATE.col
    jsr txtio.clear

    #printString UPPER, 26

    lda #60
    sta CURSOR_STATE.xPos
    lda #59
    sta CURSOR_STATE.yPos
    jsr txtio.cursorSet

    #printString LOWER, 26

    jsr txtio.left

    lda #$30
    jsr txtio.charOut
    lda #$30
    jsr txtio.charOut

    jsr txtio.backSpace
    jsr txtio.down
    
    #printString TEST_MSG, 15

    jsr waitForKey

    jsr restoreEvents
    rts
