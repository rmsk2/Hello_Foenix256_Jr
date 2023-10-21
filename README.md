# Hello Foenix256 Jr.

This project contains source code and information with respect to my first steps while developing
a hello world example in assembly language for the Foenix 256 Jr. (Revision B) or the F256 K modern 
retro computers. This is work in progress use at your own risk.

I am using Ubuntu 22.04 so all the following information is in principle specific to this platform 
but it should be easy to replicate these steps on other Linux distros. I have not attempted to use 
these tools on Windows.

In [this document](/emulator.md) you find info about how to set up an F256 Jr. emulator. 

**Note:** The math coprocessor addresses differ between the F256 Jr. (in factory condition as of March 2023) 
and the F256 K (as bought in October 2023). This repo uses the F256 K addresses as a default. You have to 
change the value of `MUL_RES_CO_PROC` from `$DE10` to `$DE04` in the files `hires_base.asm` and `txtio.asm` 
when building for a F256 Jr. in factory condition. Additionally the file `api.asm`, which defines the kernel 
interface, has been updated to a newer version. When building for an original F256 Jr. you may have to use the 
version of `api.asm` which was current when your system was released. I assume it is possible to update
the F256 Jr. to the same state as the F256 K but I have not updated my machine yet.

## Hardware setup

### What do you need?

In addition to the board you will need:

- A mini ITX power supply unit (PSU), that plugs into the F256 Jr. board
- A power adapter for this PSU
- A DVI monitor cable
- A PS/2 keyboard or a USB to PS/2 adapter and a USB keyboard
- A jumper to bridge the pin headers of the power on switch (see below) or
a proper switch that can be connected to the pin headers
- A cable to connect the Line out or headphone output to your speakers
- A CR2032 button cell for the real time clock

Optional but good to have:

- SDHC or SDXC cards if you want to use the SD card slot **OR**
- An IEC device for instance an original Commodore floppy drive or an SD2IEC like device including the 
corresponding connection cable
- A mini USB cable if you want to upload software from your development machine to the F256 Jr. via
the USB debug port

Optional:

- A mini ITX case
- Several (up to four) IDC-10 to DB9 cables. The serial port, the two joystick ports and the game controller 
port are available on the F256 Jr. board in the form of IDC-10 pin headers. You will need a corresponding 
adapter cable in order to be able to connect a serial nullmodem cable or Atari joysticks. For connecting NES or 
SNES game controllers you also need an adapter box available via Foenix retro systems which connects to the
male DB9 socket provided by the adapter cable.

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
when they are turned over point to that side of the board where the DVI, IEC and SD sockets are. When seating
the sockets their lever has to be vertical.
- When inserting the clock battery the side with the engraved `+` sign has to face up, i.e. this side has to 
remain visible after the battery has been inserted into its holder

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

## Uploading programs to the F256 Jr.

The first way to run an assembly program on the real hardware is to mount an appropriately formatted SD card
on your Linux machine and store the program, let's call it `hello.bin` with a target address of $4000,
which you have compiled under Linux, on this card. Then transfer the card to your F256 Jr. and load the file with 
`bload "hello.bin", $4000`. Finally execute it using `call $4000`. 

Using the SD card is satisfactory for distributing finished programs but during dvelopmemt it does not feel very
sustainable to switch a card dozens of times in a few hours over days or weeks. Another way to transfer a binary 
to the F256 Jr. is to upload it to the board via the USB debug port. In the picture linked above this port can be 
found between the power supply socket and the power on pin header and it uses the mini USB form factor.

For uploading software to the board the tool [FoenixMgr](https://github.com/pweingar/FoenixMgr)
can be used. Via `FoenixMgr` it is possible to write a program into the RAM of your F256 Jr. from your development
machine using a USB cable. To upload our program the following command can be used on your Linux machine (as root 
or with `sudo`):

`python3 fnxmgr.zip --port /dev/ttyUSB0 --binary hello.bin --address 4000`

After uploading the F256 Jr. resets and we can start the program using `call $4000`. This repo contains a copy of 
`FoenixMgr` and in order to use it you have to install `pyserial` on your development machine. This library is part of 
the standard Ubuntu repositores as `python3-serial`. The serial port may be different on your machine. The list of
available ports can be generated by `python3 fnxmgr.zip --list-ports`.

## A Hello world in assembly

In order to compile the assembly examples you will need an installed version of `64tass` in your path. I used the version from
the Ubuntu repositories which worked fine. If you want to install the latest version you can download it 
[here](https://sourceforge.net/projects/tass64/).

### The first assembly program

The file `hello.asm` contains a simple assembly program which pokes the character A into the top left corner of the screen memory.
You can use `64tass --nostart -o hello.bin hello.asm` (or `make hello`) to assemble this program. The resulting binary `hello.bin` 
can then be uploaded to the F256 Jr. using the methods described above. 

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

### Additional examples

There are additional examples described in [this document](/testprogs.md) which can be used to test hardware add-ons and
functionality like

- the 256K memory expansion
- the optional SID chips 
- the joystick ports
- SLIP networking
- Serial communication via the UART
- Bitmap graphics
- Simple cursor control in Assembler
- Routines for printing and entering text in assembly 

## Useful info

### `superbasic` keyboard shortcuts

| Key combination | Effect |
|-|-|
|`ctrl-c` or `RUN STOP` on the F256 K| Stops a listing or a running program |
|`ctrl-l`| Clears the screen | 

### About colours in text mode

For your convenience the following table gives the colour codes used in text mode. Any of the 16 colours can appear either as 
background or foreground color. The lower 4 bit of a colour code specifiy the background colour the upper 4 bit set the 
foreground colour. These colour codes can be used with the kernel function `kernel.Display.DrawRow`.

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

### Control characters for cursor and colour control

In BASIC the following character codes can be used with `print` to control the cursor position and colours on the screen.

|Code | Effect |
|-|-|
| chr$(12) | Clear screen and set cursor to upper left corner |
| chr$(16)| Cursor up |
| chr$(14)| Cursor down |
| chr$(2)| Cursor left |
| chr$(6)| Cursor right |
| chr$(1) | Set cursor to leftmost position in current line |
| chr$(5) | Set cursor to righmost position in current line |
| chr$(128) - chr$(143)| Set foreground color. Code 128 is black 143 is white. The rest follows the sequence given above |
| chr$(144) - chr$(159)| Set background color. Code 144 is black 159 is white. The rest follows the sequence given above |

You can peek/read the registers $D014 for the current X-position and $D016 for the current Y-position of the cursor. Setting the cursor position via 
these registers does not work in BASIC but it works in machine language (see [here](/testprogs.md) for an example).

### Zero page usage of `superbasic` and the TinyCore MicroKernel

I do not claim to understand the source code of `superbasic` very well but as far as I understand it I think
it uses the zero page locations $30-$40 and $50-$80. I came to these conclusions by looking at the following files

- `source/common/aa.system/04data.inc`
- `source/output/basic.lst`

So I guess I will use zero page locations from $90 up for my own programs. It has to be noted that the kernel additionally uses 
the addresses $F0-$FF and the system itself uses the zero page addresses $00, $01 and $08-$0F for configuration of the memory 
layout.

### Also noteworthy

- The boot screen shows 4 characters with wrong background color. See [here](https://user-images.githubusercontent.com/13918100/230933468-1fb9ce9a-5362-4bfd-afc1-ab4f00d6e2bb.jpg) 
- The `superbasic` statement `call` is currently not mentioned in the documentation
- The `bload` statement does not print `Completed` when loading is successfull whereas `load` does
- The `superbasic` documentation does not mention that the `proc` keyword is only valid if it occurs after an `end` statement
- When using the variant of the `if` statement that allows for a multline `if` block and an optional `else` block the `then` statement 
must be omitted. This is explained in the section about structured programming of the basic reference manual.

## Links

- [Product Home page](https://c256foenix.com/f256-jr/?v=3a52f3c22ed6)
- [Wiki at Foenix Retro Systems](https://wiki.c256foenix.com/index.php?title=F256JR)
- [Kernel for the F256 Jr.](https://github.com/ghackwrench/F256_Jr_Kernel_DOS)
- [Readme for Kernel](https://github.com/ghackwrench/F256_Jr_Kernel_DOS/tree/main/kernel#readme)
- [Alternative kernAl using Commodore interface](https://github.com/ghackwrench/OpenKERNAL)
- [Basic implementation](https://github.com/paulscottrobson/superbasic)
- [Fork of BASIC in FoenixRetro Repo](https://github.com/FoenixRetro/f256-superbasic)
- [System manual](https://github.com/pweingar/C256jrManual)
- [BASIC manual](https://github.com/paulscottrobson/superbasic/blob/main/reference/source/f256jr_basic_ref.pdf)
- [Product data sheet](https://256-foenix.us-east-1.linodeobjects.com/C256_Foenix_JR_UM_Rev002.pdf)
- [Tool for firmware upload and USB debugging](https://github.com/pweingar/FoenixMgr)
- [The official emulator/Dev suite](https://github.com/Trinity-11/FoenixIDE)
- [Fork of the official emulator](https://github.com/scttgs0/emuF256Jr)
- [Emulator used in this project](https://github.com/paulscottrobson/junior-emulator)
- The project uses [64tass](https://sourceforge.net/projects/tass64/) as an assembler. The manual can be found [here](http://tass64.sourceforge.net/)

## What do I think about the F256 Jr.?

I think it is a great little machine and I like it a lot. On top of that (and in contrast to other similar projects) it is real! The hardware is 
sitting on my desk **today** and works reliably. When compared to the Commander X16 the F256 Jr. is a more ambitious design. The memory management
is much more flexible, it features a math coprocessor for fast multiplication and includes a DMA Controller (i.e. a Blitter) which should 
make it, at least in that respect, a more capable retro gaming system than the X16. The kernel even provides a SLIP based TCP stack which
should make it possible to connect the F256 Jr. to the internet without adding the optional WiFi module, but I have not tried that, yet.

Due to the fact that the F256 Jr. deviates much further from the Commodore line of 8 bit computers than the X16 the learning curve for the aspiring
retro programmer coming from a Commodore background is also steeper but on the other hand there is also more to discover.

I like the BASIC that comes with the F256 Jr. as it enables you to explore the system and its features in an interactive way. It is much 
more advanced than the Commodore BASIC V2 but that also means that not all of your potential previous knowledge carries over to this new
platform.

While the documentation could be improved (see section `Also notworthy` above) it mostly works at least for me as a reference for the system. 
What is missing is in my opinion tutorial syle material that guides you through the first steps on the system from hardware installation to a running 
hello world program. This information mostly is already available but split between different sources.

Another thing that is not ideal from my point of view is the situation with respect to an emulator. I was not able to get the official emulator 
to boot to a BASIC prompt, but maybe I should try that again as I now know quite a bit more about the F256 Jr than I did in the beginning. The 
fork of `scttgs0` does not work for me. The emulator of Paul Robson boots to a BASIC prompt and is usable but makes no use of the 
kernel ROM which limits what kind of software can be tested. As the development cycle is fairly smooth when using the upload mechanism a nice 
emulator is not a necessity for me as a programmer but it could be a tool to get people interested in the platform.

I wish the people behind the F256 Jr. the commercial success that the product deserves.

## A slightly more complex example

Look [here](https://github.com/rmsk2/F256_Mandelbrot) for a slightly more complex programming example for the F256: A simple Mandelbrot
set viewer that makes use of bitmap graphics and the integer math coprocessor.

## Things to do
- We'll see ...