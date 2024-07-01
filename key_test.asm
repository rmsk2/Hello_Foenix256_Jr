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
    jsr txtio.init80x60
    jsr initEvents

    jsr txtio.cursorOff
    jsr txtio.clear
    #locate 10, 5
    #printString startedTxt, len(startedTxt)
    #locate 10, 7
    #printString startedTxt2, len(startedTxt2)
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
    stz TYPE
    lda myEvent.type    
    cmp #kernel.event.key.PRESSED
    beq _done
    cmp #kernel.event.key.RELEASED
    beq _doneUp
    bra _loop
_doneUp
    inc TYPE
_done
    #printString MSG2, len(MSG2)
    jsr txtio.newLine

    lda TYPE
    beq _prDown
    #printString T_UP, len(T_UP)
    bra _goOn
_prDown
    #printString T_DWN, len(T_DWN)
_goOn
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

    lda myEvent.key.ascii
    cmp #3
    beq _stop 
    jmp _loop
_stop
    jsr txtio.cursorOn
    jsr restoreEvents
    rts


TYPE .byte 0

.include "khelp.asm"
.include "txtio.asm"

startedTxt .text "Press keys to see the kernel events which are generated", $0d
startedTxt2 .text "Press Run/Stop or Ctrl+c to stop the program", $0d
MSG2  .text "========================="
T_UP  .text "Type : Up", $0d
T_DWN .text "Type : Down", $0d
FLAGS .text "flags: $"
RAW   .text "raw  : $"
ASCII .text "ascii: $"