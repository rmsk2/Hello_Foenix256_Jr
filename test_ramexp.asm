.include "api.asm"
; target address is $4000
* = $4000
.cpu "w65c02"

colorOK = $B2
colorERR = $D2
startY = 20

; MLUTaddress bankNum startAddr - endAddr
; 8  0: 0000 - 1FFF
; 9  1: 2000 - 3FFF
; 10 2: 4000 - 5FFF
; 11 3: 6000 - 7FFF
; 12 4: 8000 - 9FFF
; 13 5: A000 - BFFF
; 14 6: C000 - DFFF
; 15 7: E000 - FFFF
;
; RAM expansion 
; 0x100000 - 0x13FFFF

bank3Addr = 11
addr6502 = $6100
mlutExp = $81                                    ; 0x102100 DIV 0x002000 = 0x81

.include "macros.asm"

; --------------------------------------------------
; This is the main routine
; --------------------------------------------------
start
    ; write 42 to physical address $006100
    lda #42
    sta addr6502
    
    ; write 43 to physical address 0x102100
    jsr pageRamExpIn
    lda #43
    sta addr6502    

    ; read byte from pyhsical address $006100
    jsr pageRamExpOut
    lda addr6502
    sta bytePage3

    ; read byte from physical address 0x102100
    jsr pageRamExpIn
    lda addr6502
    sta bytePage81

    ; restore original MLUT
    jsr pageRamExpOut

    ; check whether correct values were read
    lda bytePage3
    cmp #42
    bne notOK

    lda bytePage81
    cmp #43
    bne notOK

    #kprint 0, startY+3, ramDetected, len(ramDetected), colorRamDetected
    rts
notOK
    #kprint 0, startY+3, ramNotDetected, len(ramNotDetected), colorRamNotDetected
    rts


; --------------------------------------------------
; This routine changes the MLUT in such a way that the memory beginning at physical
; address 0x102000 is mapped to the 6502 address space beginning at 0x6000. It saves
; the current MLUT value at the location oldPage.
; --------------------------------------------------
pageRamExpIn
    lda bank3Addr
    sta oldPage
    lda #mlutExp
    sta bank3Addr
    rts


; --------------------------------------------------
; This routine restores the MLUT to the state that was encountered when calling 
; pageRamExpIn.
; --------------------------------------------------
pageRamExpOut
    lda oldPage
    sta bank3Addr
    rts


oldPage .byte 0
bytePage3 .byte 0
bytePage81 .byte 0

ramDetected .text "OK: RAM expansion detected"
colorRamDetected .text colorOK x len(ramDetected)

ramNotDetected .text "ERROR: RAM expansion not detected"
colorRamNotDetected .text colorERR x len(ramNotDetected)
