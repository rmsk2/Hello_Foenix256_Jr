CURSOR_X = $D014
CURSOR_Y = $D016


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


initTxtIo
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
    #load16BitImmediate $C000, CURSOR_STATE.videoRamPtr
    stz CURSOR_STATE.xPos
    stz CURSOR_STATE.yPos
    bra _done
_moveRight  
    ; move cursor one character to the right
    inc CURSOR_STATE.xPos
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