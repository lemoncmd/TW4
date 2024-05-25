CC = g++
CFLAGS = -std=c++20
ASM ?= samples/test.asm

all: obj_dir/Vtop obj_dir/mem.bin

obj_dir/Vtop: src/*.sv src/*.svh
	verilator --binary --trace --trace-params --trace-structs --trace-underscore -Isrc src/top.sv

obj_dir/mem.bin: assembler $(ASM)
	mkdir -p obj_dir
	./assembler $(ASM) > obj_dir/mem.bin

assembler: src/assembler.cpp
	$(CC) $(CFLAGS) -o assembler src/assembler.cpp

run: all
	obj_dir/Vtop

clean:
	rm -r obj_dir
	rm assembler

.PHONY: run clean obj_dir/mem.bin
