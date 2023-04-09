# Hello Foneix256 Jr.

This project contains source code and information with respect to my first experiences with the 
Fonexix 256 Jr. (Revision B) modern retro computer.

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

## Remarks about the source code

The file `api.asm` contains the API definition of the Tiny Kernel. I took this 
[copy](https://github.com/paulscottrobson/superbasic/blob/main/source/common/api/api.asm) from the `superbasic` source
code because that has to match the Kernel which is installed on my system.

## Setting up the emulator

I am using Ubuntu 22.04 so all the following information is in principle specific to this platform but it should be easy to
replicate these steps on other Linux distros. I have not tried to use these tools on Windows.

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
You can use `64tass --nostart -o hello.bin hello.asm` to assemble this program. The resulting binary `hello.bin` can then be fed 
into the emulator. The emulator must be instructed at start to load the neccessary binaries to their respective memory 
locations. For each file to load we have to add a CLI parameter of the form `file to load@hexaddress`. Let's assume the result of
our assembly run can be found in the file `../../hellojr/hello.bin`. We then start the emulator from its `bin` directory by issuing 
the command `./jr256  ../../hellojr/hello.bin@4000  ../basic.rom@b`. The pseudo address `b` is a shorthand the value $8000. At 
the BASIC prompt we can use `call $4000` to execute our program. 

We could also skip loading the BASIC ROM and only start our program. The emulator can do that through the command 
`./jr256 ../../hellojr/hello.bin@4000 boot@4000`. As we have in this case not loaded the BASIC ROM not much is happening after 
our program has written A to screen memory.

## The same program in BASIC style

The superbasic that comes with the Foenix F256 Jr. can assemble programs into memory from BASIC through the `assemble` command.
When you type in and run the following BASIC program:

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

## The same program Kernel style



## Links

- [Product Home page](https://c256foenix.com/f256-jr/?v=3a52f3c22ed6)
- [Wiki at Foneix Retro Systems](https://wiki.c256foenix.com/index.php?title=F256JR)
- [Kernel for the F256 Jr.](https://github.com/ghackwrench/F256_Jr_Kernel_DOS)
- [Basic implementation](https://github.com/paulscottrobson/superbasic)
- [System Documentation](https://github.com/pweingar/C256jrManual)
- [Product data sheet](https://256-foenix.us-east-1.linodeobjects.com/C256_Foenix_JR_UM_Rev002.pdf)
- [Tool for firmware upload and USB debugging](https://github.com/pweingar/FoenixMgr)
- [The official emulator/Dev suite](https://github.com/Trinity-11/FoenixIDE)
- [Fork of the official emulator](https://github.com/scttgs0/emuF256Jr)
- [Another Emulator](https://github.com/paulscottrobson/junior-emulator)
- The project uses [64tass](https://sourceforge.net/projects/tass64/) as an assembler. The manual can be found [here](http://tass64.sourceforge.net/)

