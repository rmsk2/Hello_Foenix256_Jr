CURSOR_X = $D014
CURSOR_Y = $D016
CARRIAGE_RETURN = 13


toTxtMatrix .macro
    lda #2
    sta $01
.endmacro

toColorMatrix .macro
    lda #3
    sta $01
.endmacro

saveIoState .macro
    lda $01
    sta CURSOR_STATE.tempIo
.endmacro

restoreIoState .macro    
    lda CURSOR_STATE.tempIo
    sta $01
.endmacro

moveCursor .macro
    lda CURSOR_STATE.xPos
    sta CURSOR_X
    stz CURSOR_X+1
    lda CURSOR_STATE.yPos
    sta CURSOR_Y
    stz CURSOR_Y+1
.endmacro


cursorState_t .struct 
xPos        .byte 0
yPos        .byte 0
videoRamPtr .word 0
xMax        .byte 80
yMax        .byte 60
col         .byte $92
tempIo      .byte 0
nextChar    .byte 0
maxVideoRam .word 0
.endstruct


CURSOR_STATE  .dstruct cursorState_t

txtio .namespace

init
    ;calculate max address
    stz CURSOR_STATE.xPos
    lda CURSOR_STATE.yMax
    sta CURSOR_STATE.yPos
    jsr calcCursorOffset
    #move16Bit CURSOR_STATE.videoRamPtr, CURSOR_STATE.maxVideoRam
    ; initialize from current cursor position
    jsr cursorGet
    rts


calcCursorOffset
    ; calculate x * 80    
    lda CURSOR_STATE.xMax
    sta $DE00
    stz $DE01
    lda CURSOR_STATE.yPos
    sta $DE02
    stz $DE03
    
    #move16Bit $DE04, CURSOR_STATE.videoRamPtr

    ; calculate x * 80 + y + 0xC000
    clc
    lda CURSOR_STATE.videoRamPtr
    adc CURSOR_STATE.xPos
    sta CURSOR_STATE.videoRamPtr
    lda CURSOR_STATE.videoRamPtr+1
    adc #$C0
    sta CURSOR_STATE.videoRamPtr+1

    rts


cursorSet 
    #moveCursor
    jsr calcCursorOffset
    rts    


charOut
    sta CURSOR_STATE.nextChar

    #saveIoState    
    #move16Bit CURSOR_STATE.videoRamPtr, TXT_PTR1    
    #toTxtMatrix
    lda CURSOR_STATE.nextChar
    sta (TXT_PTR1)
    #toColorMatrix
    lda CURSOR_STATE.col
    sta (TXT_PTR1)    
    #restoreIoState

    #inc16Bit CURSOR_STATE.videoRamPtr
    #cmp16Bit CURSOR_STATE.videoRamPtr, CURSOR_STATE.maxVideoRam
    bcc _moveRight
    ; We have reached the lower right corner. For now we return the cursor to the upper
    ; left corner. We also could scroll the screen one line up
    #load16BitImmediate $D270, CURSOR_STATE.videoRamPtr
    stz CURSOR_STATE.xPos
    phy
    jsr scrollUp
    ply
    bra _done
_moveRight  
    ; move cursor one character to the right
    inc CURSOR_STATE.xPos
    lda CURSOR_STATE.xPos
    cmp CURSOR_STATE.xMax
    bcc _done
    stz CURSOR_STATE.xPos
    ; We do not have to worry about an overflow in y position. When we arrive
    ; here there was at least one character position left on the screen
    inc CURSOR_STATE.yPos
_done
    #moveCursor
    rts


cursorGet
    lda CURSOR_X
    sta CURSOR_STATE.xPos
    lda CURSOR_Y
    sta CURSOR_STATE.yPos
    jsr calcCursorOffset

    rts


cursorOn
    lda #1
    ora $D010
    sta $D010
    rts


cursorOff
    lda #%11111110
    and $D010
    sta $D010
    rts


left
    lda CURSOR_STATE.xPos
    beq _leftEdge                                        ; was xPos zero?
    dec a
    sta CURSOR_STATE.xPos
    bra _done
_leftEdge
    lda CURSOR_STATE.yPos
    beq _done                                            ; was yPos zero?
    lda CURSOR_STATE.xMax
    dec a
    sta CURSOR_STATE.xPos
    dec CURSOR_STATE.yPos
_done
    jsr cursorSet
    rts


right
    inc CURSOR_STATE.xPos
    lda CURSOR_STATE.xPos
    cmp CURSOR_STATE.xMax
    bcc _done
    stz CURSOR_STATE.xPos
    inc CURSOR_STATE.yPos
    lda CURSOR_STATE.yPos
    cmp CURSOR_STATE.yMax
    bcc _done
    jsr scrollUp
    dec CURSOR_STATE.yPos
_done
    jsr cursorSet
    rts


up
    lda CURSOR_STATE.yPos
    beq _done
    dec CURSOR_STATE.yPos
_done
    jsr cursorSet
    rts


down
    inc CURSOR_STATE.yPos
    lda CURSOR_STATE.yPos
    cmp CURSOR_STATE.yMax
    bcc _done
    dec CURSOR_STATE.yPos
    phy
    jsr scrollUp
    ply
_done
    jsr cursorSet
    rts


backSpace
    jsr left
    lda #32
    jsr charOut
    jsr left
    rts


newLine
    stz CURSOR_STATE.xPos
    jsr down
    rts


home
    stz CURSOR_STATE.xPos
    stz CURSOR_STATE.yPos
    jsr cursorSet
    rts


BLOCK_COUNT .byte 0
clear
    #saveIoState
    lda #17
    sta BLOCK_COUNT
    #load16BitImmediate $C000, TXT_PTR2
    ldy #0
_blockLoop
    #toTxtMatrix
    lda #32
    sta (TXT_PTR2), y
    #toColorMatrix
    lda CURSOR_STATE.col
    sta (TXT_PTR2), y
    iny
    bne _blockLoop
    inc TXT_PTR2+1
    dec BLOCK_COUNT
    bpl _blockLoop

    ; Special treatment of last 192 bytes which do not form 
    ; a full block
    #load16BitImmediate $D200, TXT_PTR2
    ldy #0
_lastLoop
    #toTxtMatrix
    lda #32
    sta (TXT_PTR2), y
    #toColorMatrix
    lda CURSOR_STATE.col
    sta (TXT_PTR2), y
    iny
    cpy #192
    bne _lastLoop
    #restoreIoState
    rts


LINE_COUNT .byte 0
scrollUp
    #saveIoState

    #load16BitImmediate $C000, TXT_PTR1
    #load16BitImmediate $C050, TXT_PTR2    
    stz LINE_COUNT

    ; move all lines on step up
_nextLine
    ldy #0
_lineLoop
    #toTxtMatrix
    lda (TXT_PTR2), y
    sta (TXT_PTR1), y
    #toColorMatrix
    lda (TXT_PTR2), y
    sta (TXT_PTR1), y
    iny
    cpy #80
    bne _lineLoop
    
    #move16Bit TXT_PTR2, TXT_PTR1
    #add16BitImmediate 80, TXT_PTR2

    inc LINE_COUNT
    lda LINE_COUNT
    cmp #59
    bne _nextLine

    #load16BitImmediate $D270, TXT_PTR1

    ; clear last line
    ldy #0
_lastLineLoop
    #toTxtMatrix
    lda #32
    sta (TXT_PTR1), y
    #toColorMatrix
    lda CURSOR_STATE.col
    sta (TXT_PTR1), y
    iny
    cpy #80
    bne _lastLineLoop

    #restoreIoState
    rts

hexChars .text "0123456789ABCDEF"
tempChar .byte 0
printByte
    sta tempChar
    and #$F0
    lsr
    lsr
    lsr
    lsr
    tay
    lda hexChars, y
    jsr charOut
    lda tempChar
    and #$0F
    tay
    lda hexChars, y
    jsr charOut
    rts


printStr
    sta tempChar
    ldy #0
_printLoop
    cpy tempChar
    beq _done
    lda (TXT_PTR3), y
    cmp #CARRIAGE_RETURN
    bne _realChar
    jsr newLine
    bra _nextChar
_realChar
    jsr charOut
_nextChar
    iny
    bra _printLoop 
_done
    rts

.endnamespace