`ifndef TYPES_SVH
`define TYPES_SVH

typedef struct {
  logic [1:0] mode;
  logic [3:0] addr;
} virt_addr_t;

typedef union {
  virt_addr_t virt_addr;
  logic [5:0] phys_addr;
} addr_t;

typedef struct {
  logic [3:0] opcode;
  logic [3:0] imm;
} instruction_t;

typedef union {
  instruction_t instruction;
  logic [7:0]   raw_data;
} data_t;

`endif  // TYPES_SVH
