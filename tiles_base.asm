plotTile .macro x, y, tileNr
    lda #\x
    sta tiles.X_POS
    lda #\y
    sta tiles.Y_POS
    lda #\tileNr
    sta tiles.TILE_NR
    jsr tiles.callPlotTile
.endmacro

tiles .namespace

VKY_MSTR_CTRL_0 = $D000
VKY_MSTR_CTRL_1 = $D001

LAYER_REG1 = $D002
LAYER_REG2 = $D003

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

TILE_SIZE_8x8 = 16
TILE_MAP_0_ON = 1

TILE_MAP_REGS = $D200
TILE_SET_REGS = $D280

TILE_MAP_ADDR = $6000
MAP_SIZE_X = 40
MAP_SIZE_Y = 30

TC1 = 221
TC2 = 122


on
    ; setup tile map
    ; address of tile map
    lda #<TILE_MAP_ADDR
    sta TILE_MAP_REGS + 1
    lda #>TILE_MAP_ADDR
    sta TILE_MAP_REGS + 2
    lda #`TILE_MAP_ADDR
    sta TILE_MAP_REGS + 3
    ; size of tile map
    lda #MAP_SIZE_X
    sta TILE_MAP_REGS + 4
    lda #MAP_SIZE_Y
    sta TILE_MAP_REGS + 6
    ; no scrolling
    stz TILE_MAP_REGS + 8
    stz TILE_MAP_REGS + 9
    stz TILE_MAP_REGS + 10
    stz TILE_MAP_REGS + 11

    ; setup tile set
    lda #<TILE_SET_ADDR
    sta TILE_SET_REGS
    lda #>TILE_SET_ADDR
    sta TILE_SET_REGS + 1
    lda #`TILE_SET_ADDR
    sta TILE_SET_REGS + 2    
    stz TILE_SET_REGS + 3

    lda #TILE_SIZE_8x8 | TILE_MAP_0_ON
    sta TILE_MAP_REGS

    jsr clearTileMap

    ; setup graphics layer, i.e. layer 0 shows tile map 0
    lda #4
    sta LAYER_REG1

    ; enter graphics mode using tile mode with a text overly
    lda #BIT_TILE | BIT_GRAPH | BIT_OVERLY | BIT_TEXT
    sta VKY_MSTR_CTRL_0

    rts


off
    lda #BIT_TEXT
    sta VKY_MSTR_CTRL_0
    stz VKY_MSTR_CTRL_1
    rts


clearTileMap
    stz MEM_SET.valToSet
    #load16BitImmediate TILE_MAP_ADDR, MEM_SET.startAddress
    ; make room for invisible column 1
    #load16BitImmediate (MAP_SIZE_X + 1) * MAP_SIZE_Y * 2, MEM_SET.length
    jsr memSet
    rts


X_MAX    .byte MAP_SIZE_X
X_POS    .word 0
Y_POS    .word 0
TILE_NR  .byte 0
ATTRS    .byte 0
callPlotTile
    inc X_POS
    #mul8x8BitCoproc X_MAX, Y_POS, ZP_GRAPHIC_PTR 
    #add16Bit X_POS, ZP_GRAPHIC_PTR
    #double16Bit ZP_GRAPHIC_PTR 
    #add16BitImmediate TILE_MAP_ADDR, ZP_GRAPHIC_PTR
    lda TILE_NR
    sta (ZP_GRAPHIC_PTR)
    ldy #1
    lda ATTRS
    sta (ZP_GRAPHIC_PTR), y
    rts


MemSet_t .struct 
    valToSet     .byte ?
    startAddress .word ?
    length       .word ?
.endstruct

MEM_SET .dstruct MemSet_t

; parameters in MEM_SET
memSet
    #move16Bit MEM_SET.startAddress, MEM_PTR1
memSetInt
    ldy #0
_set
    ; MEM_SET.length + 1 contains the number of full blocks
    lda MEM_SET.length + 1
    beq _lastBlockOnly
    lda MEM_SET.valToSet
_setBlock
    sta (MEM_PTR1), y
    iny
    bne _setBlock
    dec MEM_SET.length + 1
    inc MEM_PTR1+1
    bra _set

    ; Y register is zero here
_lastBlockOnly
    ; MEM_SET.length contains the number of bytes in last block
    lda MEM_SET.length
    beq _done
    lda MEM_SET.valToSet
_loop
    sta (MEM_PTR1), y
    iny
    cpy MEM_SET.length
    bne _loop
_done
    rts


TILE_SET_ADDR
; tile 0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
; tile 1
.byte TC1,0,TC1,0,TC1,0,TC1,0
.byte TC1,0,TC1,0,TC1,0,TC1,0
.byte TC1,0,TC1,0,TC1,0,TC1,0
.byte TC1,0,TC1,0,TC1,0,TC1,0
.byte TC1,0,TC1,0,TC1,0,TC1,0
.byte TC1,0,TC1,0,TC1,0,TC1,0
.byte TC1,0,TC1,0,TC1,0,TC1,0
.byte TC1,0,TC1,0,TC1,0,TC1,0
; tile 2
.byte TC2,TC2,TC2,TC2,TC2,TC2,TC2,TC2
.byte 0,0,0,0,0,0,0,0
.byte TC2,TC2,TC2,TC2,TC2,TC2,TC2,TC2
.byte 0,0,0,0,0,0,0,0
.byte TC2,TC2,TC2,TC2,TC2,TC2,TC2,TC2
.byte 0,0,0,0,0,0,0,0
.byte TC2,TC2,TC2,TC2,TC2,TC2,TC2,TC2
.byte 0,0,0,0,0,0,0,0



.endnamespace