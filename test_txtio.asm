; target address is $4000
* = $4000
.cpu "w65c02"

jmp main

.include "api.asm"
.include "zeropage.asm"
.include "macros.asm"
.include "txtio.asm"
.include "khelp.asm"
.include "key_repeat.asm"

; ************************************************************
; Change this to zero when you don't want to use the key repeat feature
; ************************************************************
USE_REPEAT = 1

UPPER .text "ABCDEFGHIJKLMNOPQRTSUVWXYZ"
LOWER .text "abcdefghijklmnopqrstuvwxyz"

ALLOWED_CHARS .text "ABCDEFGHIJKLMNOPQRTSUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,?!_"
INPUT_CHARS .text "A" x 32
OUT_LEN .byte 0
OUT_LEN_TXT .text "Number of characters: $"
ENTER_TXT .text "Enter string: "
DONE_TXT .text $0d, "Done!"
START_TXT1 .text "Use cursor keys to control cursor, c to clear screen, x to quit", $0d
START_TXT2 .text "and return to test input", $0d

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

    ; set fore- and background colours
    lda #$92
    sta CURSOR_STATE.col

    #printString START_TXT1, len(START_TXT1)
    #printString START_TXT2, len(START_TXT2)

_charLoop
.if USE_REPEAT != 0
    jsr keyrepeat.waitForKey
.else
    jsr waitForKey
.endif
    cmp #KEY_X
    beq _done
    cmp #CRSR_UP
    bne _checkDown
    jsr txtio.up
    bra _charLoop
_checkDown
    cmp #CRSR_DOWN
    bne _checkLeft
    jsr txtio.down
    bra _charLoop
_checkLeft
    cmp #CRSR_LEFT
    bne _checkRight
    jsr txtio.left
_checkRight
    cmp #CRSR_RIGHT
    bne _checkCrLf
    jsr txtio.right
    bra _charLoop
_checkCrLf
    cmp #CRLF
    bne _checkClear
    jsr inputTest
    bra _charLoop
_checkClear
    cmp #KEY_C
    bne _charLoop
    jsr txtio.clear
    jsr txtio.home
    bra _charLoop
_done
    #printString DONE_TXT, len(DONE_TXT)
    jsr txtio.newLine
    jsr restoreEvents
    rts


inputTest
    ; print "Enter string: "
    #printString ENTER_TXT, len(ENTER_TXT)

    ; set fore- and background colours to reverse
    lda #$29
    sta CURSOR_STATE.col

    ; get input from user
    #inputString INPUT_CHARS, len(INPUT_CHARS), ALLOWED_CHARS, len(ALLOWED_CHARS)
    ; save length of entered string
    sta OUT_LEN

    ; restore colours to non reverse
    lda #$92
    sta CURSOR_STATE.col

    ; print "Number of characters: $"
    jsr txtio.newLine
    #printString OUT_LEN_TXT, len(OUT_LEN_TXT)

    ; print text length in hex
    lda OUT_LEN    
    jsr txtio.printByte
    jsr txtio.newLine    
    
    ; print text the user entered
    #printStringLenMem INPUT_CHARS, OUT_LEN
    jsr txtio.newLine

    ; turn cursor on, as the input routine turns it off
    jsr txtio.cursorOn

    rts