.include "api.asm"
.include "macros.asm"

; target address is $4000
* = $4000
.cpu "w65c02"

OUT_LINE = 29

MMU_MEM_CTRL = $0000
MMU_IO_CTRL = $0001
VKY_MSTR_CTRL_0 = $D000
VKY_MSTR_CTRL_1 = $D001

LAYER_REG1 = $D002
LAYER_REG2 = $D003
BITMAP_0_ENABLE = $D100
BITMAP_0_ADDR_LOW = $D101
BITMAP_0_ADDR_MDL = $D102
BITMAP_0_ADDR_HI = $D103

BITMAP_1_ENABLE = $D108
BITMAP_2_ENABLE = $D110

BITMAP_WINDOW = $6000
ZP_GRAPHIC_PTR = $90

; --------------------------------------------------
; This routine is the entry point of the program
;--------------------------------------------------
main
    jsr initEvents
    #kprint 0, OUT_LINE - 3, startedTxt, len(startedTxt), startedColor
    jsr waitForKey

    jsr hiresOn
    jsr waitForKey

    jsr hiresOff
    
    jsr restoreEvents
    rts


.include "khelp.asm"

; waiting for a key press event from the kernel
waitForKey
    ; Peek at the queue to see if anything is pending
    lda kernel.args.events.pending ; Negated count
    bpl waitForKey
    ; Get the next event.
    jsr kernel.NextEvent
    bcs waitForKey
    ; Handle the event
    lda myEvent.type    
    cmp #kernel.event.key.PRESSED
    beq _done
    bra waitForKey
_done
    rts    


; --------------------------------------------------
; This routine turns the bitmap mode on and clears the
; (hires) screen.
;--------------------------------------------------
hiresOn
    ; switch to I/O page 0 
    stz MMU_IO_CTRL

    ; setup layers, we want bitmap 0 in layer 0 and nothing in layer 1 or 2
    ; we therefore only set a value for layer 0
    stz LAYER_REG1  

    ; Explicitly disable BITMAPS 1 and 2
    stz BITMAP_1_ENABLE
    stz BITMAP_2_ENABLE

    ; set address of bitmap 0 memory
    lda #0
    sta BITMAP_0_ADDR_LOW
    lda #0
    sta BITMAP_0_ADDR_MDL
    lda #4
    sta BITMAP_0_ADDR_HI

    ; use color map 0 and turn graphics on
    lda #1
    sta BITMAP_0_ENABLE

    ; turn on graphics mode and turn on bitmaps
    lda #%00001100
    sta VKY_MSTR_CTRL_0
    stz VKY_MSTR_CTRL_1

    jsr clearBitmap

    rts


MAX_256_BYTE_BLOCK .byte 0
COUNT_256_BYTE_BLOCK .byte 0

clearBitmapWindow
    #load16BitImmediate BITMAP_WINDOW, ZP_GRAPHIC_PTR
    stz COUNT_256_BYTE_BLOCK
_nextBlock
    ldy #0
    lda #0
_loopBlock
    sta (ZP_GRAPHIC_PTR), Y
    iny
    bne _loopBlock
    inc ZP_GRAPHIC_PTR+1
    inc COUNT_256_BYTE_BLOCK
    lda COUNT_256_BYTE_BLOCK
    cmp MAX_256_BYTE_BLOCK
    bne _nextBlock
    rts


setBitmapWindow
    clc
    adc #32
    sta 11
    rts


setCodeWindow
    lda #3
    sta 11
    rts


COUNT_WINDOWS .byte 0

clearBitmap
    stz COUNT_WINDOWS
    lda COUNT_WINDOWS
_nextWindow
    jsr setBitmapWindow
    lda #32
    sta MAX_256_BYTE_BLOCK
    jsr clearBitmapWindow
    inc COUNT_WINDOWS
    lda COUNT_WINDOWS
    cmp #9
    bne _nextWindow

    jsr setBitmapWindow

    lda #12
    sta MAX_256_BYTE_BLOCK
    jsr clearBitmapWindow

    jsr setCodeWindow

    rts

; --------------------------------------------------
; This routine turns the bitmap mode off again.
;--------------------------------------------------
hiresOff
    lda #1
    sta VKY_MSTR_CTRL_0
    stz VKY_MSTR_CTRL_1
    rts


XPOS .byte 0, 0
YPOS .byte 0
COLOR .byte 0
; --------------------------------------------------
; This routine sets a pixel in the bitmap using XPOS, YPOS and
; COLOR from above
;--------------------------------------------------
setPixel
    rts

startedTxt .text "Press key to start. Press another to stop"
startedColor .text x"62" x len(startedTxt)