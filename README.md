# Hello Foenix256 Jr.

This project contains source code and information with respect to my first experiences with the 
Foenix 256 Jr. (Revision B) modern retro computer. This is work in progress use at your own risk.

## Hardware setup

### What do you need?

In addition to the board you will need:

- A mini ITX power supply unit (PSU), that plugs into the F256 Jr. board
- A power adapter for this PSU
- A DVI monitor cable
- A PS/2 keyboard or a USB to PS/2 adapter and a USB keyboard
- A jumper to bridge the pin headers of the power on switch (see below)
- A cable to connect the Line out or headphone output to your speakers

Optional but good to have

- SDHC or SDXC cards if you want to use the SD card slot
- A mini USB cable if you want to upload software from your development machine to the F256 Jr. via
the USB debug port

Optional

- A mini ITX case
- An IEC device for instance an original Commodore floppy drive or an SD2IEC like device including the 
corresponding connection cable

### Hardware installation

- The Foenix 256 Jr. motherboard is a mini ITX board. Its power supply socket has 24 Pins. I bought a 
90 watts 20 pin Power supply unit (PSU) which works for me. How is the 20 pin PSU plugged in? If you
look at this [picture](https://wiki.c256foenix.com/images/6/64/Pinout_Jr_December_7th_Trans.png) then the 
leftmost four pins of the 24 pin socket have to remain free.
- The plug of the PSU will not really fit in any other position and I have to say that when I first
installed the PSU I had to exert a certain amount of pressure even in the correct position.
- The board itself has no power switch but there is a pin header which has to be bridged in order to 
connect the power supply to the board. In the picture linked above the pin header in question is shown in 
the lower right where it is labeled with *PW ON SPST Switch*. I used a jumper to permanently
connect the two pins
- If you ordered the ZIF sockets you have to plug them into the SID sockets in such a way that the levers
point to that side of the board where the DVI, IEC and SD sockets are.

### Using an SD-Card 

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

The emulator must be instructed at start to load the neccessary binaries to their respective memory locations. For each file 
to load we have to add a CLI parameter of the form `file to load@hexaddress`. Let's assume that we want to load a program which 
can be found in the file `../../hellojr/hello.bin` relative to the emulator's `bin` directroy. We then start the emulator 
from this  directory by issuing the command `./jr256  ../../hellojr/hello.bin@4000  ../basic.rom@b`. The pseudo address `b` 
is a shorthand for the value $8000. At the BASIC prompt we can use `call $4000` to execute our program. This of course assumes
that the target address used during compliation of `hello.bin` was $4000.

If you want to load a BASIC program, let's call it `test.bas`, into the emulator you can use the command 

`./jr256  test.bas@28000  ../basic.rom@b`

and type `xload` at the BASIC prompt. This first loads the source to the address $28000 and `xload` then reads it from that
location.

We could also skip loading the BASIC ROM and only start our program. The emulator can do that through the command 
`./jr256 ../../hellojr/hello.bin@4000 boot@4000`. As we have in this case not loaded the BASIC ROM not much is happening after 
our program has run.

## A Hello world in assembly

In order to compile the assembly examples you will need an installed version of `64tass` in your path. I used the version from
the Ubuntu repositories which worked fine. If you want to install the latest version you can download it 
[here](https://sourceforge.net/projects/tass64/).

### The first assembly program

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

 As mentioned above you can use `./jr256  path/to/hello.bin@4000  ../basic.rom@b` and `call $4000` to run this program in the
 emulator.

### The same program in BASIC style

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

## Hardware tests

### Memory expansion test

In the file `test_ramexp.asm` you will find a small assembly program that tests the presence of the 256K RAM expansion. You can
build the program with `make ram_exp` which results in the binary `ram_exp.bin`. This can then be run as described above.

The program simply writes a byte to memory at 6502 address `$6100` then maps in a page of expanded RAM and writes a different 
value to the same 6502 address. Then the values are read again and checked.

### SID test

The following `superbasic` program can be used to test the SIDs

```
5     print "SID test program"
6     print "----------------"
7     print 
8     input "Left or right sid? ";s$
10    testsid(s$)
100   end 
500   proc testsid(sidpos$)
505   local sid,n
510   sid=$D500
511   if sidpos$<>"right"then sid=$D400
519   poke sid+24,15
520   poke sid+5,194
530   poke sid+6,90
540   poke sid,180
550   poke sid+1,8
560   poke sid+4,33
570   for n=1 to 15000:next 
580   poke sid+4,32
590   print "done"
1000  endproc 
```

The program as shown above can be used to test both SIDs. Enter `right` for the right SID. Any other value tests the left SID. The source
code can be found in the file `testsid.bas`. As described in the `superbasic` manual the program can be stored on a comaptible SD card and
loaded from there or it can be uploaded to the F256 Jr. through the following command:

`python3 fnxmgr.zip --port /dev/ttyUSB0 --binary testsid.bas --address 28000`

After the machine resets type `xload` and after that you can list and/or run the program. Please note that after a power on of the F256 Jr.
the program needs to be run twice before you can hear any sound. This may be specific to the Nano SwinSIDs in my board or to my speakers. 
The assembly version can be built with `make sid_test`. The relevant source files are `sid_test.asm` and `sid_only.asm`. 

## Useful info

### About colours in text mode

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

### `superbasic` Keyboard shortcuts

| Key combination | Effect |
|-|-|
|`ctrl-c`| Stops a listing or a running program |
|`ctrl-l`| Clears the screen | 
 

### Zero page usage of `superbasic` and the TinyCore MicroKernel

I do not claim that I understand the source code of `superbasic` very well but as far as I understand it I think
it uses the zero page locations $30-$40 and $50-$80. I came to these conclusions by looking at the following files

- `source/common/aa.system/04data.inc`
- `source/output/basic.lst`

So I guess I will use zero page locations from $90 up for my own programs. It has to be noted that the kernel 
additionally uses the addresses $F0-$FF.

### Oddities experienced

- The boot screen shows 4 characters with wrong background color. See [here](https://user-images.githubusercontent.com/13918100/230933468-1fb9ce9a-5362-4bfd-afc1-ab4f00d6e2bb.jpg) 
- The `superbasic` statement `call` is currently not mentioned in the documentation
- The `bload` statement does not print `Completed` when loading is successfull whereas `load` does
- The `superbasic` documentation does not mention that the `proc` keyword is only valid if it occurs after an `end` statement

## Links

- [Product Home page](https://c256foenix.com/f256-jr/?v=3a52f3c22ed6)
- [Wiki at Foenix Retro Systems](https://wiki.c256foenix.com/index.php?title=F256JR)
- [Kernel for the F256 Jr.](https://github.com/ghackwrench/F256_Jr_Kernel_DOS)
- [Alternative kernAl using Commodore interface](https://github.com/ghackwrench/OpenKERNAL)
- [Basic implementation](https://github.com/paulscottrobson/superbasic)
- [System manual](https://github.com/pweingar/C256jrManual)
- [BASIC manual](https://github.com/paulscottrobson/superbasic/blob/main/reference/source/f256jr_basic_ref.pdf)
- [Product data sheet](https://256-foenix.us-east-1.linodeobjects.com/C256_Foenix_JR_UM_Rev002.pdf)
- [Tool for firmware upload and USB debugging](https://github.com/pweingar/FoenixMgr)
- [The official emulator/Dev suite](https://github.com/Trinity-11/FoenixIDE)
- [Fork of the official emulator](https://github.com/scttgs0/emuF256Jr)
- [Emulator used in this project](https://github.com/paulscottrobson/junior-emulator)
- The project uses [64tass](https://sourceforge.net/projects/tass64/) as an assembler. The manual can be found [here](http://tass64.sourceforge.net/)

## Things to do

- Research how to do bitmap graphics