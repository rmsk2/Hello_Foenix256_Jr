# Setting up the emulator

**Attention**: This document is here for historical reasons. I recommed to use the 
[official emulator](https://github.com/Trinity-11/FoenixIDE/releases).

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

## Links

- [The official emulator/Dev suite](https://github.com/Trinity-11/FoenixIDE)
- [Fork of the official emulator](https://github.com/scttgs0/emuF256Jr)
- [Emulator used in this project](https://github.com/paulscottrobson/junior-emulator)