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

    jsr tiles.on

    #plotTile 0, 0, 1
    #plotTile 0, 1, 1
    #plotTile 39, 29, 2
    #plotTile 39, 28, 2

    jsr waitForKey

    jsr tiles.off
    
    jsr restoreEvents
    rts
