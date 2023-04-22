; --------------------------------------------------
; This macro prints moves the contents of the two bytes stored
; at source and source + 1 to the memory location beginning at
; target.
;--------------------------------------------------
move16Bit .macro src, target
    lda \src
    sta \target
    lda \src+1
    sta \target+1
    .endmacro

; --------------------------------------------------
; load16BitImmediate loads the 16 bit value given in the first argument 
; into the memory location given the second argument.
; --------------------------------------------------
load16BitImmediate .macro addr, target
    lda #<\addr
    sta \target
    lda #>\addr
    sta \target+1
    .endmacro


; --------------------------------------------------
; This macro prints a string to the screen at a given x and y coordinate. The 
; macro has the following parameters
;
; 1. x coordinate
; 2. y coordinate
; 3. address of text to print
; 4. length of text to print
; 5. address of color information
;--------------------------------------------------
kprint .macro x, y, txtPtr, len, colPtr
     lda #\x                                     ; set x coordinate
     sta kernel.args.display.x
     lda #\y                                     ; set y coordinate
     sta kernel.args.display.y
     #load16BitImmediate \txtPtr, kernel.args.display.text
     lda #\len                                   ; set text length
     sta kernel.args.display.buflen
     #load16BitImmediate \colPtr, kernel.args.display.color
     jsr kernel.Display.DrawRow                  ; print to the screen
     .endmacro