all: hello hello_kernel ram_exp sid_test joystick slip uart hires cursor

hello: hello.bin 
hello_kernel: hello_kernel.bin
ram_exp: ram_exp.bin
sid_test: sid_test.bin
joystick: joystick.bin
slip: slip.bin
uart: uart.bin
hires: hires.bin
cursor: cursor.bin

hello.bin: hello.asm
	64tass --nostart -o hello.bin hello.asm

hello_kernel.bin: hello_kernel.asm api.asm
	64tass --nostart -o hello_kernel.bin  hello_kernel.asm

ram_exp.bin: test_ramexp.asm api.asm macros.asm khelp.asm
	64tass --nostart -o ram_exp.bin test_ramexp.asm

sid_test.bin: sid_test.asm sid_only.asm api.asm khelp.asm
	64tass --nostart -o sid_test.bin sid_test.asm

joystick.bin: joystick.asm api.asm macros.asm khelp.asm
	64tass --nostart -o joystick.bin joystick.asm

slip.bin: slip.asm api.asm macros.asm khelp.asm
	64tass --nostart -o slip.bin slip.asm

uart.bin: uart.asm api.asm macros.asm khelp.asm
	64tass --nostart -o uart.bin uart.asm

hires.bin: hires.asm api.asm macros.asm khelp.asm hires_base.asm
	64tass --nostart -o hires.bin hires.asm

cursor.bin: cursor.asm api.asm macros.asm khelp.asm
	64tass --nostart -o cursor.bin cursor.asm


clean:
	rm hello.bin
	rm hello_kernel.bin
	rm ram_exp.bin
	rm sid_test.bin
	rm joystick.bin
	rm slip.bin
	rm hires.bin
	rm uart.bin
	rm cursor.bin
