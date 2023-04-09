all: hello hello_kernel


hello: hello.bin 
hello_kernel: hello_kernel.bin

hello.bin: hello.asm
	64tass --nostart -o hello.bin hello.asm

hello_kernel.bin: hello_kernel.asm
	64tass --nostart -o hello_kernel.bin  hello_kernel.asm

clean:
	rm hello.bin
	rm hello_kernel.bin
