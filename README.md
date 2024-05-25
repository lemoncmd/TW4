# TW4
Tokken Warikomi 4bitcpu

## How to build

You can create binary file at `obj_dir/Vtop` with:
```sh
$ make
```

You can also emulate the CPU with:
```sh
$ make run
```

You can change assembly file by:
```sh
$ make ASM=samples/ramentimer.asm
$ # OR
$ make run ASM=samples/ramentimer.asm
```
