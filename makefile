all: hello hello_kernel ram_exp sid_test joystick slip uart hires cursor txtio mouse snespad keytest random sprites dma key_repeat tiles prg_parms

hello: hello.bin 
hello_kernel: hello_kernel.bin
ram_exp: ram_exp.bin
sid_test: sid_test.bin
joystick: joystick.bin
slip: slip.bin
uart: uart.bin
hires: hires.bin
cursor: cursor.bin
txtio: txtio.bin
mouse: mouse.bin
snespad: snespad.bin
keytest: keytest.bin
random: random.bin
sprites: sprites.bin
dma: dma.bin
key_repeat: key_repeat.bin
tiles: tiles.bin
prg_parms: prg_parms.pgz

hello.bin: hello.asm
	64tass --nostart -o hello.bin hello.asm

hello_kernel.bin: hello_kernel.asm api.asm
	64tass --nostart -o hello_kernel.bin hello_kernel.asm

ram_exp.bin: test_ramexp.asm api.asm macros.asm khelp.asm
	64tass --nostart -o ram_exp.bin test_ramexp.asm

sid_test.bin: sid_test.asm sid_only.asm api.asm khelp.asm
	64tass --nostart -o sid_test.bin sid_test.asm

joystick.bin: joystick.asm api.asm macros.asm khelp.asm
	64tass --nostart -o joystick.bin joystick.asm

mouse.bin: mouse.asm api.asm macros.asm khelp.asm
	64tass --nostart -o mouse.bin mouse.asm

slip.bin: slip.asm api.asm macros.asm khelp.asm
	64tass --nostart -o slip.bin slip.asm

uart.bin: uart.asm api.asm macros.asm khelp.asm
	64tass --nostart -o uart.bin uart.asm

hires.bin: hires.asm api.asm macros.asm khelp.asm hires_base.asm zeropage.asm
	64tass --nostart -o hires.bin hires.asm

cursor.bin: cursor.asm api.asm macros.asm khelp.asm
	64tass --nostart -o cursor.bin cursor.asm

txtio.bin: test_txtio.asm txtio.asm api.asm macros.asm khelp.asm zeropage.asm
	64tass --nostart -o txtio.bin test_txtio.asm

snespad.bin: snes_pad.asm api.asm macros.asm khelp.asm
	64tass --nostart -o snespad.bin snes_pad.asm

keytest.bin: key_test.asm api.asm txtio.asm khelp.asm macros.asm zeropage.asm
	64tass --nostart -o keytest.bin key_test.asm

random.bin: random.asm api.asm txtio.asm khelp.asm macros.asm zeropage.asm
	64tass --nostart -o random.bin random.asm

sprites.bin: sprites.asm api.asm txtio.asm khelp.asm macros.asm zeropage.asm sprdef.asm
	64tass --nostart -o sprites.bin sprites.asm

dma.bin: dma.asm api.asm macros.asm khelp.asm
	64tass --nostart -o dma.bin dma.asm

key_repeat.bin: key_repeat_test.asm key_repeat.asm txtio.asm api.asm macros.asm khelp.asm zeropage.asm
	64tass --nostart -o key_repeat.bin key_repeat_test.asm

tiles.bin: api.asm macros.asm khelp.asm tiles.asm tiles_base.asm zeropage.asm
	64tass --nostart -o tiles.bin tiles.asm

prg_parms.pgz: prg_parms.asm api.asm zeropage.asm macros.asm txtio.asm khelp.asm
	64tass --nostart -o prg_parms.bin prg_parms.asm
	python3 make_pgz.py prg_parms.bin
	mv prg_parms.bin.pgz prg_parms.pgz

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
	rm txtio.bin
	rm mouse.bin
	rm snespad.bin
	rm keytest.bin
	rm random.bin
	rm sprites.bin
	rm dma.bin
	rm key_repeat.bin
	rm tiles.bin
	rm prg_parms.bin
	rm prg_parms.pgz