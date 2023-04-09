; target address is $4000
* = $4000

; Save the current MMU setting
lda $0001
pha

; Swap I/O Page 2 into bank 6
lda #$02
sta $0001

; Write ’A’ to the upper left corner
lda #65
sta $C000

; Restore MMU settings
pla
sta $0001

rts