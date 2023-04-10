.include "api.asm"
; target address is $4000
* = $4000

     lda #0                                     ; set x coordinate
     sta kernel.args.display.x
     lda #0                                     ; set y coordinate
     sta kernel.args.display.y
     lda #<textData                             ; set pointer to text data
     sta kernel.args.display.text
     lda #>textData
     sta kernel.args.display.text+1
     lda #12                                    ; set text length
     sta kernel.args.display.buflen
     lda #<colorData                            ; set pointer to color data (one byte for each byte of text)
     sta kernel.args.display.color
     lda #>colorData
     sta kernel.args.display.color+1
     jsr kernel.Display.DrawRow                 ; print to the screen
     rts

textData .text "Hello World!"
colorData .text x"62" x len(textData)