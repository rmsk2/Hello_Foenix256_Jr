.include "api.asm"
; target address is $4000
* = $4000

lda #0
sta kernel.args.display.x
lda #0
sta kernel.args.display.y
lda #<data
sta kernel.args.display.text
lda #>data
sta kernel.args.display.text+1
lda #14
sta kernel.args.display.buflen
lda #5
sta kernel.args.display.color
jsr kernel.Display.DrawRow
rts

data .text "Hello World!"
     .text $0d, $0a
