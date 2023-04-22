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

; value of event buffer at program start (likely set by `superbasic`)
oldEvent .byte 0, 0
; the new event buffer
myEvent .dstruct kernel.event.event_t


; --------------------------------------------------
; This routine saves the current value of the pointer to the kernel event 
; buffer and sets that pointer to the address of myEvent. This in essence
; disconnects superbasic from the kernel event stream.
;--------------------------------------------------
initEvents
    #move16Bit kernel.args.events, oldEvent
    #load16BitImmediate myEvent, kernel.args.events
    rts


; --------------------------------------------------
; This routine restores the pointer to the kernel event buffer to the value
; encountered at program start. This reconnects superbasic to the kernel
; event stream.
;--------------------------------------------------
restoreEvents
    #move16Bit oldEvent, kernel.args.events
    rts

netInit
    rts

netTest
    rts


startedTxt .text "Started"
startedColor .text x"62" x len(startedTxt)