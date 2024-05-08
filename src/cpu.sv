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

  always_ff @(posedge reset) begin
    a <= 0;
    b <= 0;
    addr.virt_addr.mode <= 0;
    addr.virt_addr.addr <= 0;
    out <= 0;
  end

  always_ff @(posedge clock) begin
    logic imm = data.instruction.imm;
    unique case (data.instruction.opcode)
      ADD_A_IMM: a <= a + imm;
      MOV_A_B: a <= b;
      IN_A: a <= in;
      MOV_A_IMM: a <= imm;

      MOV_B_A: b <= a;
      ADD_B_IMM: b <= b + imm;
      IN_B: b <= in;
      MOV_B_IMM: b <= imm;

      // NOP0: ;
      OUT_B:   out <= b;
      // NOP1: ;
      OUT_IMM: out <= imm;

      // NOP2: ;
      // NOP3: ;
      JMP: addr.virt_addr.addr <= imm;
      JNC: addr.virt_addr.addr <= imm;

      default: ;
    endcase
  end
endmodule

