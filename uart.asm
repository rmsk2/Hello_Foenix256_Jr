.include "api.asm"
.include "macros.asm"

; target address is $4000
* = $4000
.cpu "w65c02"

OUT_LINE = 29

; DLAB = 0
; Read

UART_BASE = $D630
RBR = UART_BASE
IER = UART_BASE + 1
IIR = UART_BASE + 2
LCR = UART_BASE + 3
MCR = UART_BASE + 4
LSRR = UART_BASE + 5
MSR = UART_BASE + 6
SCR = UART_BASE + 7

; DLAB = 0
; Write

THR = UART_BASE
FCR = UART_BASE + 2

; DLAB = 1
; Read + Write

DLL = UART_BASE
DLM = UART_BASE + 1

DATA_BITS8 = %00000011
STOP_BIT1 = 0
NO_PARITY = 0
BRK_SIG = %01000000
NO_BRK_SIG = %0000000
DLAB = $80

BPS_2400 = 655
BPS_38400 = 40
BPS_115200 = 13

setDLAB .macro 
    lda LCR
    ora #$80
    sta LCR
    .endmacro

clearDLAB .macro
    lda LCR
    and #%01111111
    sta LCR
    .endmacro

; --------------------------------------------------
; This routine is the entry point of the program
;--------------------------------------------------
main
    #kprint 0, OUT_LINE-1, startedTxt, len(startedTxt), startedColor
    jsr initEvents
    
    jsr initUart
    lda #65
    jsr sendByte
    jsr receiveByte
    sta echoText

    #kprint 0, OUT_LINE, echoText, len(echoText), echoColor

    jsr restoreEvents
    #kprint 0, OUT_LINE+1, doneTxt, len(doneTxt), doneColor
    rts

.include "khelp.asm"

initUart
    ; 8 bits, no parity, 1 stop bit
    lda #DATA_BITS8 | STOP_BIT1 | NO_PARITY
    sta LCR
    #setDLAB
    ; set baud rate to 2400 BPS
    lda #<BPS_115200
    sta DLL
    lda #>BPS_115200
    sta DLM
    #clearDLAB

    rts

; ******************** BEWARE ********************
; These routines
; 
; 1. Are inefficient (they are synchronous and make suboptimal use of the FIFO of the UART)
; 2. Do no error checking and reporting
; ******************** BEWARE ********************

sendByte
    sta THR
_waitSend
    lda LSRR
    and #%01000000
    beq _waitSend
    rts

receiveByte
    lda LSRR
    and #%00000001
    beq receiveByte
    lda RBR
    rts

startedTxt .text "Started"
startedColor .text x"62" x len(startedTxt)
doneTxt .text "Done"
doneColor .text x"62" x len(doneTxt)
echoText .text " "
echoColor .text x"32" x len(echoText)