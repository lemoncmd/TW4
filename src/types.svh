`ifndef TYPES_SVH
`define TYPES_SVH

typedef struct packed {logic [3:0] addr;} virt_addr_t;

typedef union {
  virt_addr_t virt_addr;
  logic [3:0] phys_addr;
} addr_t;

typedef enum logic [3:0] {
  ADD_A_IMM,
  MOV_A_B,
  IN_A,
  MOV_A_IMM,

  MOV_B_A,
  ADD_B_IMM,
  IN_B,
  MOV_B_IMM,

  NOP0,
  OUT_B,
  NOP1,
  OUT_IMM,

  NOP2,
  NOP3,
  JNC,
  JMP
} opcode_t;

typedef struct packed {
  opcode_t opcode;
  logic [3:0] imm;
} instruction_t;

typedef union {
  instruction_t instruction;
  logic [7:0]   raw_data;
} data_t;

typedef struct {
  logic [3:0] a;
  logic [3:0] b;
  logic c;
} register_t;

`endif  // TYPES_SVH
