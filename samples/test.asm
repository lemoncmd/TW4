.section user
  imsk 0001
  out 0111
  swi
  out 0110
  swi
loop:
  out 0000
  out 0100
  add a, 1
  jnc loop
  out 1000

.section swi
loop1:
  add a, 1
  jnc loop1
loop2:
  add a, 1
  jnc loop2
  iret

.section exception
loop:
  out 1010
  add a, 0
  out 0101
  jmp loop

.section irq
  out 1001
  iret
