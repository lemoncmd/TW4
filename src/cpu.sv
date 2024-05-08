`include "types.svh"

module cpu (
    input logic clock,
    input logic reset,
    output addr_t addr,
    input data_t data,
    input logic [3:0] in,
    output logic [3:0] out
);
  logic [3:0] a, b;
  logic c;

  always_ff @(posedge reset) begin
    a <= 0;
    b <= 0;
    c <= 0;
    addr.virt_addr.mode <= 0;
    addr.virt_addr.addr <= 0;
    out <= 0;
  end

  always_ff @(posedge clock) begin
    logic opcode = data.instruction.opcode;
    logic imm = data.instruction.imm;
    addr.virt_addr.addr <= addr.virt_addr.addr + 1;
    unique case (opcode)
      ADD_A_IMM: {c, a} <= {1'b0, a} + {1'b0, imm};
      MOV_A_B: a <= b;
      IN_A: a <= in;
      MOV_A_IMM: a <= imm;

      MOV_B_A: b <= a;
      ADD_B_IMM: {c, b} <= {1'b0, b} + {1'b0, imm};
      IN_B: b <= in;
      MOV_B_IMM: b <= imm;

      // NOP0: ;
      OUT_B:   out <= b;
      // NOP1: ;
      OUT_IMM: out <= imm;

      // NOP2: ;
      // NOP3: ;
      JMP: addr.virt_addr.addr <= imm;
      JNC: if (c) addr.virt_addr.addr <= imm;

      default: ;
    endcase
  end
endmodule

