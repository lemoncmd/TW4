all: obj_dir/Vtop

obj_dir/Vtop: *.sv *.svh
	verilator --binary --trace --trace-params --trace-structs --trace-underscore top.sv

run: all
	obj_dir/Vtop

clean:
	rm -r obj_dir

.PHONY: run clean
