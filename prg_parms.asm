* = $0300
.cpu "w65c02"


jmp main

.include "api.asm"
.include "zeropage.asm"
.include "macros.asm"
.include "txtio.asm"
.include "khelp.asm"


TXT_MSG .text $0d, "Press any key to return to BASIC", $0d

LEN_PARMS_IN_BYTES .byte 0
BYTE_COUNT .byte 0

main
    jsr setup.mmu
    jsr clut.init    
    jsr initEvents
    #move16Bit kernel.args.ext, MEM_PTR1
    lda kernel.args.extlen
    sta LEN_PARMS_IN_BYTES
    jsr txtio.init80x60
    jsr txtio.cursorOn

    lda #$12
    sta CURSOR_STATE.col 
    jsr txtio.clear
    
    stz BYTE_COUNT

_loop    
    ldy BYTE_COUNT
    cpy LEN_PARMS_IN_BYTES
    beq _done
    lda (MEM_PTR1), y
    sta TILE_PTR1
    iny
    lda (MEM_PTR1), y
    sta TILE_PTR1 + 1
    iny
    sty BYTE_COUNT
    jsr printZeroTerminated
    bra _loop
_done
    #printString TXT_MSG, len(TXT_MSG)

    jsr waitForKey

    jsr exitToBasic
    ; I guess we never get here ....
    jsr sys64738
    rts


printZeroTerminated
    ldy #0
_loop 
    lda (TILE_PTR1), y
    beq _done
    jsr txtio.charOut
    iny
    bra _loop
_done
    jsr txtio.newLine
    rts


exitToBasic
    jsr txtio.init80x60
    lda #65
    sta kernel.args.run.block_id
    jsr kernel.RunBlock
    rts


; See chapter 17 of the system manual. Section 'Software reset'
sys64738
    lda #$DE
    sta $D6A2
    lda #$AD
    sta $D6A3
    lda #$80
    sta $D6A0
    lda #00
    sta $D6A0
    rts


saveIo .macro
    lda $01
    pha
.endmacro

setIo .macro page
    lda #\page
    sta $01
.endmacro

restoreIo .macro
    pla
    sta $01
.endmacro


TXT_BLACK = 0
TXT_WHITE = 1
TXT_BLUE = 2
TXT_GREEN = 3
TXT_AMBER = 4

clut .namespace

TXT_LUT_FORE_GROUND_BASE = $D800
TXT_LUT_BACK_GROUND_BASE = $D840


setTxtColInt .macro colNum, red, green, blue, alpha
    lda #\blue
    sta TXT_LUT_FORE_GROUND_BASE + ((\colNum & 15) * 4)
    sta TXT_LUT_BACK_GROUND_BASE + ((\colNum & 15) * 4)
    lda #\green
    sta TXT_LUT_FORE_GROUND_BASE + ((\colNum & 15) * 4) + 1
    sta TXT_LUT_BACK_GROUND_BASE + ((\colNum & 15) * 4) + 1
    lda #\red
    sta TXT_LUT_FORE_GROUND_BASE + ((\colNum & 15) * 4) + 2
    sta TXT_LUT_BACK_GROUND_BASE + ((\colNum & 15) * 4) + 2
    lda #\alpha
    sta TXT_LUT_FORE_GROUND_BASE + ((\colNum & 15) * 4) + 3
    sta TXT_LUT_BACK_GROUND_BASE + ((\colNum & 15) * 4) + 3
.endmacro


setTxtCol .macro colNum, red, green, blue, alpha
    #saveIo
    #setIo 0
    #setTxtColInt \colNum, \red, \green, \blue, \alpha
    #restoreIo
.endmacro


init
    #saveIo
    
    #setIo 0
    #setTxtColInt TXT_BLACK,  $00, $00, $00, $FF
    #setTxtColInt TXT_WHITE,  $FF, $FF, $FF, $FF
    #setTxtColInt TXT_BLUE,   $00, $00, $FF, $FF
    #setTxtColInt TXT_GREEN,  $00, $FF, $00, $FF
    #setTxtColInt TXT_AMBER,  $FA, $63, $05, $FF

    #restoreIo
    rts

.endnamespace

setup .namespace

mmu
    ; setup MMU, this seems to be neccessary when running as a PGZ
    lda #%10110011                         ; set active and edit LUT to three and allow editing
    sta 0
    lda #%00000000                         ; enable io pages and set active page to 0
    sta 1

    ; map BASIC ROM out and RAM in
    lda #4
    sta 8+4
    lda #5
    sta 8+5
    rts

; 8  0: 0000 - 1FFF
; 9  1: 2000 - 3FFF
; 10 2: 4000 - 5FFF
; 11 3: 6000 - 7FFF
; 12 4: 8000 - 9FFF
; 13 5: A000 - BFFF
; 14 6: C000 - DFFF
; 15 7: E000 - FFFF
;
; RAM expansion 
; 0x100000 - 0x13FFFF

.endnamespace