.include "api.asm"

; target address is $4000
* = $4000
.cpu "w65c02"


jmp main

.include "khelp.asm"
.include "zeropage.asm"
.include "macros.asm"
.include "txtio.asm"


TEST_TEXT .text "Dies ist ein Test"

; --------------------------------------------------
; This routine is the entry point of the program
;--------------------------------------------------
main
    jsr txtio.init
    jsr initEvents

    #setCol $92
    ;jsr txtio.clear
    jsr txtio.cursorOff

    #setCol $F2
    #locate 0,0
    #printString TEST_TEXT, len(TEST_TEXT)

    jsr waitForKey

    jsr spritesOn
    jsr simpleSpriteOn

    jsr waitForKey

    jsr simpleSpriteOff
    
    jsr waitForKey
    jsr spritesOff

    jsr txtio.cursorOn
    jsr restoreEvents
    rts

    rts


MSG1 .text "Dies ist ein Test"

SPR_SIZE_8 = 64 | 32
SPR_SIZE_16 = 64
SPR_SIZE_24 = 32
SPR_SIZE_32 = 0

SPR_LAYER_0 = 0
SPR_LAYER_1 = 8
SPR_LAYER_2 = 16
SPR_LAYER_3 = 16 | 8

SPR_LUT_0 = 0
SPR_LUT_1 = 2
SPR_LUT_2 = 4
SPR_LUT_3 = 2 | 4

SPR_ENABLE = 1

simpleSpriteOn
    ; address of sprite data in 21 bit system address space
    lda #<SPR_DATA
    sta $D901
    lda #>SPR_DATA
    sta $D902
    stz $D903

    ; X position
    lda #110
    sta $d904
    stz $d905
    
    ; y position
    lda #48
    sta $d906
    stz $d907

    ; sprite attributes
    lda #SPR_SIZE_8 | SPR_LAYER_0 | SPR_LUT_0 | SPR_ENABLE
    sta $D900
    rts

simpleSpriteOff
    lda #0
    sta $D900
    rts

BIT_TEXT = 1
BIT_OVERLY = 2
BIT_GRAPH = 4
BIT_BITMAP = 8
BIT_TILE = 16
BIT_SPRITE = 32
BIT_GAMMA = 64
BIT_X = 128

BIT_CLK_70 = 1
BIT_DBL_X = 2
BIT_DBL_Y = 4
BIT_MON_SLP = 8 
BIT_FON_OVLY = 16
BIT_FON_SET = 32


spritesOn
    lda #BIT_TEXT | BIT_OVERLY | BIT_SPRITE | BIT_GRAPH
    sta $D000
    lda #0
    sta $D001
    rts

spritesOff 
    lda #BIT_TEXT
    sta $D000
    lda #$00
    sta $D001    
    rts


; A simple block using a single color
SPR_DATA .text x"93" x 1024