all: hello hello_kernel ram_exp sid_test


hello: hello.bin 
hello_kernel: hello_kernel.bin
ram_exp: ram_exp.bin
sid_test: sid_test.bin

hello.bin: hello.asm
	64tass --nostart -o hello.bin hello.asm

hello_kernel.bin: hello_kernel.asm
	64tass --nostart -o hello_kernel.bin  hello_kernel.asm

ram_exp.bin: test_ramexp.asm
	64tass --nostart -o ram_exp.bin test_ramexp.asm

sid_test.bin: sid_test.asm
	64tass --nostart -o sid_test.bin sid_test.asm


clean:
	rm hello.bin
	rm hello_kernel.bin
	rm ram_exp.bin
	rm sid_test.bin
