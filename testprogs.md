# Hardware tests

## Memory expansion test

In the file `test_ramexp.asm` you will find a small assembly program that tests the presence of the 256K RAM expansion. You can
build the program with `make ram_exp` which results in the binary `ram_exp.bin`. This can then be run as described above.

The program simply writes a byte to memory at 6502 address `$6100` then maps in a page of expanded RAM and writes a different 
value to the same 6502 address. Then the values are read again and checked.

## SID test

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
