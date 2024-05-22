CC = g++
CFLAGS = -std=c++20

all: obj_dir/Vtop assembler

obj_dir/Vtop: src/*.sv src/*.svh
	verilator --binary --trace --trace-params --trace-structs --trace-underscore -Isrc src/top.sv

assembler: src/assembler.cpp
	$(CC) $(CFLAGS) -o assembler src/assembler.cpp

run: all
	obj_dir/Vtop

clean:
	rm -r obj_dir
	rm assembler

.PHONY: run clean
