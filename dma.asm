.include "api.asm"
.include "macros.asm"

; target address is $4000
* = $4000
.cpu "w65c02"

OUT_LINE = 29
DMA_FILL_BYTE = $DF01
DMA_READY = $DF01
DMA_CONTROL = $DF00
DMA_ENABLE = %00000001
DMA_FILL =   %00000100
DMA_START =  %10000000
DMA_SOURCE = $DF04
DMA_DESTINATION = $DF08
DMA_COUNT = $DF0C
ZP_ADDR = $B0

BYTE_VALUE = $FF

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


; --------------------------------------------------
; This routine is the entry point of the program
;--------------------------------------------------
main
    jsr initEvents
    stz TRY_COUNT

    #kprint 0, OUT_LINE, startedTxt, len(startedTxt), startedColor

_nextTry    
    jsr setMemory
    #kprint 0, OUT_LINE+1, fillOkTxt, len(fillOkTxt), fillOkColor

    jsr copyMemory
    #kprint 0, OUT_LINE+2, copyOkTxt, len(copyOkTxt), copyOkColor

    jsr compareMemoryBlock

    inc TRY_COUNT
    lda TRY_COUNT
    cmp #250
    bne _nextTry

    jsr restoreEvents
    rts

compareMemoryBlock
    #load16BitImmediate $61E4, ZP_ADDR
    ldy #0
_nexByte
    lda (ZP_ADDR),y
    cmp #BYTE_VALUE
    bne _error
    iny
    bne _nexByte
    #kprint 0, OUT_LINE+3, cmpOkTxt, len(cmpOkTxt), cmpOkColor
    bra _done
_error
    #kprint 0, OUT_LINE+3, errorTxt, len(errorTxt), errorColor
_done
    rts

TRY_COUNT .byte 0

setMemory
    #saveIo
    #setIo 0

    lda #DMA_FILL | DMA_ENABLE
    sta DMA_CONTROL
    
    lda #BYTE_VALUE
    sta DMA_FILL_BYTE
    
    ; destination $010000
    lda #$00
    sta DMA_DESTINATION
    lda #$00
    sta DMA_DESTINATION + 1
    lda #$01
    sta DMA_DESTINATION + 2
    
    ; length 4K = $001000
    lda #$00
    sta DMA_COUNT
    lda #$10
    sta DMA_COUNT + 1
    lda #$00
    sta DMA_COUNT + 2

    lda DMA_CONTROL
    ora #DMA_START
    sta DMA_CONTROL
_checkEnd
    lda DMA_READY
    and #$80
    bne _checkEnd

    stz DMA_CONTROL
    ; These seem to be neccessary .... . Otherwise the system
    ; locks up after a few repititions.
    nop
    nop
    nop
    #restoreIo
    rts

copyMemory
    #saveIo
    #setIo 0

    lda #DMA_ENABLE
    sta DMA_CONTROL

    ; source $010000
    lda #$00
    sta DMA_SOURCE
    lda #$00
    sta DMA_SOURCE + 1
    lda #$01
    sta DMA_SOURCE + 2

    ; destination $006000
    lda #$00
    sta DMA_DESTINATION
    lda #$60
    sta DMA_DESTINATION + 1
    lda #$00
    sta DMA_DESTINATION + 2
    
    ; length 4K = $001000
    lda #$00
    sta DMA_COUNT
    lda #$10
    sta DMA_COUNT + 1
    lda #$00
    sta DMA_COUNT + 2

    lda DMA_CONTROL
    ora #DMA_START
    sta DMA_CONTROL
_checkEnd
    lda DMA_READY
    and #$80
    bne _checkEnd

    stz DMA_CONTROL
    #restoreIo
    rts


.include "khelp.asm"

startedTxt .text "Started"
startedColor .text x"62" x len(startedTxt)

copyOkTxt .text "Copy OK"
copyOkColor .text x"62" x len(copyOkTxt)

fillOkTxt .text "Fill OK"
fillOkColor .text x"62" x len(fillOkTxt)

cmpOkTxt .text "Compare OK"
cmpOkColor .text x"62" x len(cmpOkTxt)

errorTxt .text "Error"
errorColor .text x"62" x len(errorTxt)