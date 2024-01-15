.include "api.asm"
.include "macros.asm"
.include "zeropage.asm"

; target address is $4000
* = $4000
.cpu "w65c02"

jmp main

printRand .macro
    lda RAND_DATA
    jsr txtio.printByte
    lda RAND_DATA+1
    jsr txtio.printByte
    jsr txtio.newLine    
.endmacro

init
    jsr kGetTimeStamp
    lda RTC_BUFFER.centis
    sta SEED_VAL_LO
    lda RTC_BUFFER.seconds
    sta SEED_VAL_HI

    lda $D651
    eor SEED_VAL_LO
    sta SEED_VAL_LO

    lda $D659
    eor SEED_VAL_HI
    sta SEED_VAL_HI

    clc
    lda $D01A
    adc SEED_VAL_LO
    sta SEED_VAL_LO

    clc
    lda $D018
    adc SEED_VAL_HI
    sta SEED_VAL_HI

    lda SEED_VAL_LO
    sta RNG_LO
    lda SEED_VAL_HI
    sta RNG_HI
    lda #2
    sta RNG_CTRL

    rts

; This routine is the entry point of the program
;--------------------------------------------------
main
    jsr txtio.init
    jsr init
    jsr initEvents

    jsr txtio.cursorOff
    jsr txtio.clear
    jsr txtio.newLine

    jsr get1
    #printRand

    jsr get2
    #printRand

    jsr get3
    #printRand

    jsr txtio.newLine    
    jsr txtio.cursorOn

    jsr restoreEvents

    rts

.include "khelp.asm"
.include "txtio.asm"

RTC_BUFFER .dstruct kernel.time_t

kGetTimeStamp
    #load16BitImmediate RTC_BUFFER, kernel.args.buf
    lda #size(kernel.time_t)
    sta kernel.args.buflen
    jsr kernel.Clock.GetTime
    rts

SEED_VAL_LO .byte 0
SEED_VAL_HI .byte 0

RNG_LO = $D6A4
RNG_HI = $D6A5
RNG_CTRL = $D6A6

RAND_DATA .byte $FF, $FF


get1
    lda RNG_CTRL
    ora #1
    sta RNG_CTRL
_wait
    lda RNG_CTRL
    beq _wait
    lda RNG_LO
    sta RAND_DATA
    lda RNG_HI
    sta RAND_DATA+1
    rts

get2
    lda #1
    sta RNG_CTRL
_wait
    lda RNG_CTRL
    beq _wait
    lda RNG_LO
    sta RAND_DATA
    lda RNG_HI
    sta RAND_DATA+1
    rts

get3
    lda #1
    sta RNG_CTRL
    lda RNG_LO
    sta RAND_DATA
    lda RNG_HI
    sta RAND_DATA+1
    rts
