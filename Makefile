all: obj_dir/Vtop

obj_dir/Vtop: src/*.sv src/*.svh
	verilator --binary --trace --trace-params --trace-structs --trace-underscore -Isrc src/top.sv

run: all
	obj_dir/Vtop

clean:
	rm -r obj_dir

.PHONY: run clean
