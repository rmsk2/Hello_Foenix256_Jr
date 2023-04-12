; target address is $4000
* = $4000

GETIN    = $FFE4
SID_BASE = $D400

TRIANGLE = 16
SAWTOOTH = 32
SQUARE = 64
NOISE = 128

; --------------------------------------------------
; load16BitImmediate loads the 16 bit value given in the first argument 
; into the memory location given the second argument
; --------------------------------------------------
load16BitImmediate .macro addr, target
    lda #<\addr
    sta \target
    lda #>\addr
    sta \target+1
    .endmacro

.include "sid_only.asm"

main
    #clearSID

    ; global volume to maximum
    #setGlobalVolume 15
    ; set envelope
    #setBeepADSR 0, 0, 8, 0, 1
    ; set frequency
    #setFrequency $211c, 1

    jsr waitForKey

    #turnWaveOn TRIANGLE, 1

    jsr waitForKey
 
    #turnWaveOff TRIANGLE, 1

    rts


; --------------------------------------------------
; Wait for a key and return ASCII Code of key in Accumulator
; 
; INPUT:  None
; OUTPUT: ASCII code of read character in accumulator
; --------------------------------------------------
waitForKey
    jsr GETIN         ; get key from keyboard
    cmp #0            ; if 0, no key pressed
    beq waitForKey    ; loop if no key pressed

    rts               ; ASCII Code of pressed key is now in accumulator

