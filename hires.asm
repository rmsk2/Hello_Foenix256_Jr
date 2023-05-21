.include "api.asm"
.include "macros.asm"
.include "zeropage.asm"

; target address is $4000
* = $4000
.cpu "w65c02"


; --------------------------------------------------
; This routine is the entry point of the program
;--------------------------------------------------
main
    jsr initEvents

    lda #0
    sta hires.backgroundColor
    jsr hires.On

    lda #0
    sta hires.setPixelArgs.y
_loopLine
    ldy #0
    stz hires.setPixelArgs.x+1
_loopColor
    sty hires.setPixelArgs.x
    sty hires.setPixelArgs.col
    jsr hires.setPixel
    ldy hires.setPixelArgs.col
    iny
    bne _loopColor
    inc hires.setPixelArgs.y
    lda hires.setPixelArgs.y
    cmp #240
    bne _loopLine

    jsr waitForKey

    jsr hires.Off
    jsr hires.setCodeWindow
    
    jsr restoreEvents
    rts


.include "khelp.asm"
.include "hires_base.asm"