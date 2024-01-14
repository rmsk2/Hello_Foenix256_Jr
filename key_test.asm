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
    jsr txtio.init
    jsr initEvents

    jsr txtio.cursorOff
    jsr txtio.clear
    #locate 10, 5
    #printString startedTxt, len(startedTxt)
    jsr txtio.newLine
    jsr txtio.newLine

_loop
    ; Peek at the queue to see if anything is pending
    lda kernel.args.events.pending ; Negated count
    bpl _loop
    ; Get the next event.
    jsr kernel.NextEvent
    bcs _loop
    ; Handle the event
    lda myEvent.type    
    cmp #kernel.event.key.PRESSED
    beq _done
    bra _loop
_done
    #printString MSG, len(MSG)
    jsr txtio.newLine
    #printString MSG2, len(MSG2)
    jsr txtio.newLine


    #printString FLAGS, len(FLAGS)
    lda myEvent.key.flags 
    jsr txtio.printByte
    jsr txtio.newLine

    #printString RAW, len(RAW)
    lda myEvent.key.raw 
    jsr txtio.printByte
    jsr txtio.newLine

    #printString ASCII, len(ASCII)
    lda myEvent.key.ascii 
    jsr txtio.printByte
    jsr txtio.newLine

    jsr txtio.cursorOn
    jsr restoreEvents
    rts



.include "khelp.asm"
.include "txtio.asm"

startedTxt .text "Press any key"
MSG   .text "Contents of kernel event:"
MSG2  .text "========================="
FLAGS .text "flags: $"
RAW   .text "raw  : $"
ASCII .text "ascii: $"