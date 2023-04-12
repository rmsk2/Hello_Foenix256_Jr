; clear SID registers
clearSID .macro 
    ldx #0
    lda #0
_loopRegister
    sta SID_BASE, x
    inx
    cpx #25
    bne _loopRegister
    .endmacro


; set volume for SID
setGlobalVolume .macro volume
    lda #\volume
    and #%00001111
    sta SID_BASE + 24
    .endmacro


; set attack, decay, sustain and release                 
setBeepADSR .macro timeAttack, timeDecay, volumeSustain, timeRelease, voice 
    lda #\timeAttack                        ; time to reach full volume
    asl
    asl
    asl
    asl
    ora #\timeDecay                         ; time to fall to .volumeSustain
    sta SID_BASE + 5 + ((\voice-1) * 7)
    lda #\volumeSustain                     ; volume during sustain
    asl
    asl
    asl
    asl
    ora #\timeRelease                       ; time to reach zero volume after sound is turned off (key bit = 0)
    sta SID_BASE + 6 + ((\voice-1) * 7)     
    .endmacro


; switch voice on using the given waveform
turnWaveOn .macro waveBit, voice
    lda SID_BASE + 4 + ((\voice-1) * 7)
    and #%00001111
    ora #\waveBit
    ora #1                                  ; set key bit => turn sound on
    sta SID_BASE + 4 + ((\voice-1) * 7)     ; make it happen
    .endmacro


; switch voice off again
turnWaveOff .macro waveBit, voice
    lda SID_BASE + 4 + ((\voice-1) * 7)
    and #%00001110
    ora #\waveBit                           ; key bit was cleared in line above
    sta SID_BASE + 4 + ((\voice-1) * 7)     ; make it happen
    .endmacro


; set frquency to use
setFrequency .macro frequency, voice
    #load16BitImmediate \frequency, SID_BASE + ((\voice-1) * 7)
    .endmacro
