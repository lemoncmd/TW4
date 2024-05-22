CC = g++
CFLAGS = -std=c++20

all: obj_dir/Vtop assembler

obj_dir/Vtop: src/*.sv src/*.svh obj_dir/test.bin
	verilator --binary --trace --trace-params --trace-structs --trace-underscore -Isrc src/top.sv

obj_dir/test.bin: assembler samples/test.asm
	mkdir -p obj_dir
	./assembler samples/test.asm > obj_dir/test.bin

assembler: src/assembler.cpp
	$(CC) $(CFLAGS) -o assembler src/assembler.cpp

run: all
	obj_dir/Vtop

clean:
	rm -r obj_dir
	rm assembler

.PHONY: run clean
