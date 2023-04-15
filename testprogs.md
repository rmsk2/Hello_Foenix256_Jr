# Hardware tests

## Memory expansion test

In the file `test_ramexp.asm` you will find a small assembly program that tests the presence of the 256K RAM expansion. You can
build the program with `make ram_exp` which results in the binary `ram_exp.bin`. This can then be run as described above.

The program simply writes a byte to memory at 6502 address `$6100` then maps in a page of expanded RAM and writes a different 
value to the same 6502 address. Then the values are read again and checked.

## SID test

The file `testsid.bas` contains a `superbasic` program can be used to test the SIDs As described in the `superbasic` manual the program 
can be stored on a comaptible SD card and loaded from there or it can be uploaded to the F256 Jr. through the following command:

`python3 fnxmgr.zip --port /dev/ttyUSB0 --binary testsid.bas --address 28000`

After the machine resets type `xload` and after that you can list and/or run the program. Please note that after a power on of the F256 Jr.
the first time you try to play a sound on either the left or the right SID does not work. This is probably specific to the Nano SwinSIDs in 
my board or to my speakers. The assembly version can be built with `make sid_test`. The relevant source files are `sid_test.asm` and 
`sid_only.asm`. 
