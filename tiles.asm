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

    #plotTile 1, 1, 1
    #plotTile 2, 1, 0
    #plotTile 3, 1, 2

    jsr waitForKey

    jsr tiles.off
    
    jsr restoreEvents
    rts
