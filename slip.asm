.include "api.asm"
.include "macros.asm"

; target address is $4000
* = $4000
.cpu "w65c02"

OUT_LINE = 29


; --------------------------------------------------
; This routine is the entry point of the program
;--------------------------------------------------
main
    jsr initEvents

    #kprint 0, OUT_LINE - 3, startedTxt, len(startedTxt), startedColor
    jsr netInit
    jsr netTest

    jsr restoreEvents
    rts

netInit
    rts

netTest
    rts


.include "khelp.asm"

startedTxt .text "Started"
startedColor .text x"62" x len(startedTxt)