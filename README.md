# Hello Foenix256 Jr.

This project contains source code and information with respect to my first experiences with the 
Foenix 256 Jr. (Revision B) modern retro computer. This is work in progress use at your own risk.

## Hardware setup

- The Foenix 256 Jr. motherboard is a mini ITX board. Its power supply socket has 24 Pins. I bought a 
90 watts 20 pin Power supply unit (PSU) which works for me. How is the 20 pin PSU plugged in? If you
look at this [picture](https://c256foenix.com/f256-jr/?v=3a52f3c22ed6) then the leftmost four pins of
the 24 pin socket have to remain free.
- The plug of the PSU will not really fit in any other position and I have to say that when I first
installed the PSU I had to exert a certain amount of pressure even in the correct position.
- The board itself has no power switch but there is a pin header which has to be bridged in order to 
connect the power supply to the board. In the picture linked above the pin header in question is shown in 
the lower right where it is labeled with *Permanently ON/OFF Switch for PS*. I used a jumper to permanently
connect the two pins.

## Using an SD-Card 

Information mostly taken from [here](https://github.com/ghackwrench/F256_Jr_Kernel_DOS/blob/main/ReleaseNotes.txt).

- The kernel is only probing the SD Card once, at startup; for now, you will need to reboot when you swap cards. 
Removing and re-inserting the same card without a reboot will not work!
- The SPI layer is presently only supporting V2 SD Cards (these are modern HC and XC cards). Older V1 cards won't work 
(this is primarily a software limitation)
- The FAT layer won't handle off-the-shelf format parameters; you will need to format the card from the Foenix to 
ensure compatibility.

In order to format an SD card enter the DOS utility by typing the command `/DOS` at the BASIC prompt. In the DOS
CLI use the `mkfs`command in order to format an SD card.

## Setting up the emulator

I am using Ubuntu 22.04 so all the following information is in principle specific to this platform but it should be easy to
replicate these steps on other Linux distros. I have not attempted to use these tools on Windows.

I have tried all emulators listed below and for the purpose of this experiment the emulator of paulscottrobson worked best for me. 
I cloned the repo available at 
[https://github.com/paulscottrobson/junior-emulator](https://github.com/paulscottrobson/junior-emulator)
and installed `64tass` and the header files for `SDL2` (both were available in the Ubuntu 22.04 repos). I changed into the 
directory created by the clone and issued the command `make all`. After the build succeeds you will find the emulator in 
the `bin` directory. In order to start the emulator into a basic prompt issue the command `./jr256   ../basic.rom@b` from 
the `bin` directory. The emulator can be stopped by pressing `Escape`. Clicking on the close button in the window title bar
did not work for me.

The emulator expects a British keyboard layout. This resulted in the problem that I could not type certain characters at all 
(for instance the `"` character) because I use a german keyboard. Thus I had to additionally install the British keyboard 
layout and activate it while using the emulator.

## The first assembly program

The file `hello.asm` contains a simple assembly program which pokes the character A into the top left corner of the screen memory.
You can use `64tass --nostart -o hello.bin hello.asm` (or `make hello`) to assemble this program. The resulting binary `hello.bin` 
can then be fed into the emulator. 

```
; target address is $4000
* = $4000

; Save the current MMU setting
lda $0001
pha

; Swap I/O Page 2 into bank 6
lda #$02
sta $0001

; Write ’A’ to the upper left corner
lda #65
sta $C000

; Restore MMU settings
pla
sta $0001

rts
```

The emulator must be instructed at start to load the neccessary binaries to their respective memory 
locations. For each file to load we have to add a CLI parameter of the form `file to load@hexaddress`. Let's assume the result of
our assembly run can be found in the file `../../hellojr/hello.bin` relative to the emulator's `bin` directroy. We then start the 
emulator from this  directory by issuing the command `./jr256  ../../hellojr/hello.bin@4000  ../basic.rom@b`. The pseudo address `b` 
is a shorthand for the value $8000. At the BASIC prompt we can use `call $4000` to execute our program. 

We could also skip loading the BASIC ROM and only start our program. The emulator can do that through the command 
`./jr256 ../../hellojr/hello.bin@4000 boot@4000`. As we have in this case not loaded the BASIC ROM not much is happening after 
our program has written the A to screen memory.

## The same program in BASIC style

The superbasic that comes with the Foenix F256 Jr. can assemble programs into memory from BASIC through the `assemble` command.
When you type it in and run the following BASIC program:

```
10 assemble $4000,0
20 lda 1
30 pha
40 lda #2
50 sta 1
60 lda #65
70 sta $c000
80 pla
90 sta 1
100 rts
```

you can execute the resulting assembly subroutine through the command `call $4000`.

## Using the real hardware

The first way to run our example program on the real hardware is to mount an appropriately formatted SD card
on your Linux machine and store `hello.bin` on this card. Then transfer the card to your F256 Jr. and load the
file with `bload "hello.bin", $4000`. Finally execute it using `call $4000`. 

Using the SD card is satisfactory for distributing finished programs but during dvelopmemt it does not feel very
sustainable to switch a card dozens of times in a few hours over days or weeks. Another way to transfer a binary 
to the F256 Jr. is to upload it to the board via the USB debug port. In the picture linked above this port can be 
found between the power supply socket and the power on pin header and it uses the mini USB form factor.

For uploading software to the board the tool [FoenixMgr](https://github.com/pweingar/FoenixMgr)
can be used. Via `FoenixMgr` it is possible to write a program into the RAM of your F256 Jr. from your development
machine using a USB cable. To upload our program the following command can be used (as root or with `sudo`):

`python3 fnxmgr.zip --port /dev/ttyUSB0 --binary hello.bin --address 4000`

After uploading the machine resets and we can start the program using `call $4000`. This repo contains a copy of 
`FoenixMgr` and in order to use it you have to install `pyserial` on your development machine. This library is part of 
the standard Ubuntu repositores as `python3-serial`. The serial port may be different on your machine. The list of
available ports can be generated by `python3 fnxmgr.zip --list-ports`.

## Hello world Kernel style

This program should print `Hello World!` in the upper left corner of the screen without relying on
any BASIC functionality. It can be built by `64tass --nostart -o hello_kernel.bin  hello_kernel.asm` or `make hello_kernel`.
The file `api.asm` contains the API definition of the TinyCore Kernel. I took this 
[copy](https://github.com/paulscottrobson/superbasic/blob/main/source/common/api/api.asm) from the `superbasic` source
code because that has to match the Kernel which is installed on my system.


```
.include "api.asm"
; target address is $4000
* = $4000

     lda #0                                     ; set x coordinate
     sta kernel.args.display.x
     lda #0                                     ; set y coordinate
     sta kernel.args.display.y
     lda #<textData                             ; set pointer to text data
     sta kernel.args.display.text
     lda #>textData
     sta kernel.args.display.text+1
     lda #12                                    ; set text length
     sta kernel.args.display.buflen
     lda #<colorData                            ; set pointer to color data (one byte for each byte of text)
     sta kernel.args.display.color
     lda #>colorData
     sta kernel.args.display.color+1
     jsr kernel.Display.DrawRow                 ; print to the screen
     rts

textData .text "Hello World!"
colorData .text x"62" x len(textData)
```

**Remark**: The program does not work in the emulator. Either I have used the wrong API description or the emulator simply
does not implement enough of the system for it to work. But the program works on a real machine.

## Memory expansion

In the file `test_ramexp.asm` you will find a small assembly program that tests the presence of the 256K RAM expansion. You can
build the program with `make ram_exp` which results in the binary `ram_exp.bin`. This can then be run as described above.

The programm simply writes a byte to memory at 6502 address `$6100` then maps in a page of expanded RAM and writes a different 
value to the same 6502 address. Then the values are read again and checked.

## About colours in text mode

For your convenience the following table gives the colour codes used in text mode. Any of the 16 colours can appear either as 
background or foreground color. The lower 4 bit of a colour code specifiy the backround colour.

| Colour code | Colour |
|-|-|
| 0 | Black|
| 1 | Grey|
| 2 | Dark blue (default background colour)|
| 3 | Green |
| 4 | Purple |
| 5 | Brown |
| 6 | Orange |
| 7 | Light blue |
| 8 | Dark grey |
| 9 | Light grey (default foreground colour) |
| 10 | Blue |
| 11 | Light green|
| 12 | Light purple |
| 13 | Red |
| 14 | Yellow |
| 15 | White |

## SID test

For the purpose of trying out the two (SwinSID) SID-replacements I have bought for use with the F256 Jr. I have written a test program 
called `sid_test.asm` (use `make sid_test`to build it). Unfortunately the program does not work (yet, I hope) on my system. I have switched
on the DIP switch 5 and I am pretty sure that the ZIF sockets as well as the SIDs in them are seated properly and I am using the 
speaker/headphone output. Neither the left nor the right SID work so I seem to be missing something quite fundamental as it seems 
to be fairly unlikely that both SwinSIDs are broken or improperly seated, apart from the fundamental orientation of course but I am
also pretty sure that I got that right. The SwinSID also does not care about being feed 9V or 12V so I did not change corresponding jumpers.

## Links

- [Product Home page](https://c256foenix.com/f256-jr/?v=3a52f3c22ed6)
- [Wiki at Foenix Retro Systems](https://wiki.c256foenix.com/index.php?title=F256JR)
- [Kernel for the F256 Jr.](https://github.com/ghackwrench/F256_Jr_Kernel_DOS)
- [Basic implementation](https://github.com/paulscottrobson/superbasic)
- [System Documentation](https://github.com/pweingar/C256jrManual)
- [Product data sheet](https://256-foenix.us-east-1.linodeobjects.com/C256_Foenix_JR_UM_Rev002.pdf)
- [Tool for firmware upload and USB debugging](https://github.com/pweingar/FoenixMgr)
- [The official emulator/Dev suite](https://github.com/Trinity-11/FoenixIDE)
- [Fork of the official emulator](https://github.com/scttgs0/emuF256Jr)
- [Another Emulator](https://github.com/paulscottrobson/junior-emulator)
- The project uses [64tass](https://sourceforge.net/projects/tass64/) as an assembler. The manual can be found [here](http://tass64.sourceforge.net/)

## Things to do

- Get SIDs working
- Research the save zero page locations to use in combination with `superbasic`.