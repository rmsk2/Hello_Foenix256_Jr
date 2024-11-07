plotTile .macro x, y, tileNr
    lda #\x
    sta tiles.TILE_PARAMS.xPos
    lda #\y
    sta tiles.TILE_PARAMS.yPos
    lda #\tileNr
    sta tiles.TILE_PARAMS.tileNr
    jsr tiles.callPokeTile
.endmacro


plotTileWithAttr .macro x, y, tileNr, attr
    lda #\x
    sta tiles.TILE_PARAMS.xPos
    lda #\y
    sta tiles.TILE_PARAMS.yPos
    lda #\tileNr
    sta tiles.TILE_PARAMS.tileNr
    lda #\attr
    sta tiles.TILE_PARAMS.attrs
    jsr tiles.callPokeTile
.endmacro


configTileSetAddr .macro addr
    lda #<\addr
    sta tiles.TILE_SET.lo
    lda #>\addr
    sta tiles.TILE_SET.middle
    lda #`\addr
    sta tiles.TILE_SET.hi    
.endmacro


setBackGroundColour .macro val
    lda #<\val
    sta $D00D
    lda #>\val
    sta $D00E
    lda #`\val
    sta $D00F
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

TILE_MAP_0 = 4
TILE_MAP_1 = 5
TILE_MAP_2 = 6

MAP_SIZE_X = 40
MAP_SIZE_Y = 30

ATTRS_DEFAULT = 0


on
    ; setup tile map
    ; address of tile map
    ; Yes, the minus 2 seems to be neccessary
    lda #<TILE_MAP_ADDR - 2
    sta TILE_MAP_REGS + 1
    lda #>TILE_MAP_ADDR - 2
    sta TILE_MAP_REGS + 2
    lda #`TILE_MAP_ADDR - 2
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
    lda TILE_SET.lo
    sta TILE_SET_REGS
    lda TILE_SET.middle
    sta TILE_SET_REGS + 1
    lda TILE_SET.hi
    sta TILE_SET_REGS + 2

    stz TILE_SET_REGS + 3

    lda #TILE_SIZE_8x8 | TILE_MAP_0_ON
    sta TILE_MAP_REGS

    jsr clearTileMap

    ; setup graphics layer, i.e. layer 0 shows tile map 0
    lda #TILE_MAP_0
    sta LAYER_REG1

    ; enter graphics mode using tile mode with a text overlay
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
    #load16BitImmediate MAP_SIZE_X  * MAP_SIZE_Y * 2, MEM_SET.length
    jsr memSet
    rts


calcMapAddress
    #mul8x8BitCoproc TILE_PARAMS.xMax, TILE_PARAMS.yPos, TILE_PTR1 
    #add16Bit TILE_PARAMS.xPos, TILE_PTR1
    #double16Bit TILE_PTR1 
    #add16BitImmediate TILE_MAP_ADDR, TILE_PTR1
    rts    


TileParam_t .struct 
    xMax   .byte MAP_SIZE_X
    xPos   .word 0
    yPos   .word 0
    tileNr .byte ?
    attrs  .byte ATTRS_DEFAULT
.endstruct

TILE_PARAMS .dstruct TileParam_t

callPokeTile
    jsr calcMapAddress
callPokeTileInt
    lda TILE_PARAMS.tileNr
    sta (TILE_PTR1)
    ldy #1
    lda TILE_PARAMS.attrs
    sta (TILE_PTR1), y
    rts


callPeekTile
    jsr calcMapAddress
callPeekTileInt
    lda (TILE_PTR1)
    sta TILE_PARAMS.tileNr
    ldy #1
    lda (TILE_PTR1), y
    sta TILE_PARAMS.attrs
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


DUMMY .word 0
TILE_MAP_ADDR .fill MAP_SIZE_X * MAP_SIZE_Y * 2

TileSetAddr_t .struct 
    lo     .byte ?
    middle .byte ?
    hi     .byte ?
.endstruct

TILE_SET .dstruct TileSetAddr_t

.endnamespace