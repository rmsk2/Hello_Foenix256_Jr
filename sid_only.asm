; clear SID registers
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


clearSID .macro base
    ldx #0
    lda #0
_loopRegister
    sta \base, x
    inx
    cpx #25
    bne _loopRegister
    .endmacro


; set volume for SID
setGlobalVolume .macro base, volume
    lda #\volume
    and #%00001111
    sta \base + 24
    .endmacro


; set attack, decay, sustain and release                 
setBeepADSR .macro base, timeAttack, timeDecay, volumeSustain, timeRelease, voice 
    lda #\timeAttack                        ; time to reach full volume
    asl
    asl
    asl
    asl
    ora #\timeDecay                         ; time to fall to .volumeSustain
    sta \base + 5 + ((\voice-1) * 7)
    lda #\volumeSustain                     ; volume during sustain
    asl
    asl
    asl
    asl
    ora #\timeRelease                       ; time to reach zero volume after sound is turned off (key bit = 0)
    sta \base + 6 + ((\voice-1) * 7)     
    .endmacro


; switch voice on using the given waveform
turnWaveOn .macro base, waveBit, voice
    lda #\waveBit
    ora #1                                  ; set key bit => turn sound on
    sta \base + 4 + ((\voice-1) * 7)     ; make it happen
    .endmacro


; switch voice off again
turnWaveOff .macro base, waveBit, voice
    lda #\waveBit    
    sta \base + 4 + ((\voice-1) * 7)     ; make it happen
    .endmacro


; set frquency to use
setFrequency .macro base, frequency, voice
    #load16BitImmediate \frequency, \base + ((\voice-1) * 7)
    .endmacro
