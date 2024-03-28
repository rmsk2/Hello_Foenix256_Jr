* = $4000
.cpu "w65c02"

jmp main

.include "api.asm"
.include "zeropage.asm"
.include "macros.asm"
.include "txtio.asm"
.include "khelp.asm"
.include "key_repeat.asm"

START_TXT1 .text "Use cursor keys to control cursor, c to clear screen, x to quit", $0d
START_TXT2 .text "Other keys are printed raw", $0d
DONE_TXT .text $0d, "Done!", $0d

CRLF = $0D
KEY_X = $78
KEY_C = $63
CRSR_UP = $10
CRSR_DOWN = $0E
CRSR_LEFT = $02
CRSR_RIGHT = $06

main
    jsr txtio.init
    jsr keyrepeat.init
    jsr initEvents
    #load16bitImmediate processKeyEvent, keyrepeat.FOCUS_VECTOR

    ; set fore- and background colours
    lda #$92
    sta CURSOR_STATE.col

    #printString START_TXT1, len(START_TXT1)
    #printString START_TXT2, len(START_TXT2)
    jsr keyrepeat.waitForKey

    #printString DONE_TXT, len(DONE_TXT)
    jsr restoreEvents
    rts


processKeyEvent
    cmp #KEY_X
    bne _checkUp
    clc
    rts
_checkUp
    cmp #CRSR_UP
    bne _checkDown
    jsr txtio.up
    sec
    rts
_checkDown
    cmp #CRSR_DOWN
    bne _checkLeft
    jsr txtio.down
    sec
    rts
_checkLeft
    cmp #CRSR_LEFT
    bne _checkRight
    jsr txtio.left
    sec
    rts
_checkRight
    cmp #CRSR_RIGHT
    bne _checkClear
    jsr txtio.right
    sec
    rts
_checkClear
    cmp #KEY_C
    bne _print
    jsr txtio.clear
    jsr txtio.home
    sec
    rts
_print
    jsr txtio.charOut
    sec
    rts
