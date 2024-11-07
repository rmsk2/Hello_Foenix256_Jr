.include "api.asm"
.include "macros.asm"
.include "zeropage.asm"

; target address is $4000
* = $4000
.cpu "w65c02"

jmp main

.include "tiles_base.asm"
.include "khelp.asm"

; --------------------------------------------------
; This routine is the entry point of the program
;--------------------------------------------------
main
    jsr initEvents

    #configTileSetAddr TILE_SET_ADDR
    #setBackGroundColour $00FF00

    jsr tiles.on

    #plotTile 0, 0, 1
    ; #plotTile 0, 1, 1
    #plotTile 39, 29, 2
    ; #plotTile 39, 28, 2

    jsr waitForKey

    jsr tiles.off
    
    jsr restoreEvents
    rts


TC1 = 221
TC2 = 122

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