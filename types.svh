`ifndef TYPES_SVH
`define TYPES_SVH

typedef struct {
  logic [1:0] mode;
  logic [3:0] addr;
} virt_addr_t;

typedef struct {
  virt_addr_t virt_addr;
  logic [5:0] phys_addr;
} addr_t;

`endif  // TYPES_SVH
