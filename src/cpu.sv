`include "types.svh"

module cpu (
    input logic clock,
    input logic reset,
    output addr_t addr,
    input data_t data,
    input logic [3:0] in,
    output logic [3:0] out
);
  register_t regs;

  always_ff @(posedge clock) begin
    logic [3:0] opcode = data.instruction.opcode;
    logic [3:0] imm = data.instruction.imm;
    addr.virt_addr.addr <= addr.virt_addr.addr + 1;
    unique case (opcode)
      ADD_A_IMM: {regs.c, regs.a} <= {1'b0, regs.a} + {1'b0, imm};
      MOV_A_B: regs.a <= regs.b;
      IN_A: regs.a <= in;
      MOV_A_IMM: regs.a <= imm;

      MOV_B_A: regs.b <= regs.a;
      ADD_B_IMM: {regs.c, regs.b} <= {1'b0, regs.b} + {1'b0, imm};
      IN_B: regs.b <= in;
      MOV_B_IMM: regs.b <= imm;

      // NOP0: ;
      OUT_B:   out <= regs.b;
      // NOP1: ;
      OUT_IMM: out <= imm;

      // NOP2: ;
      // NOP3: ;
      JMP: addr.virt_addr.addr <= imm;
      JNC: if (regs.c) addr.virt_addr.addr <= imm;

      default: ;
    endcase

    if (~reset) begin
      regs.a <= 0;
      regs.b <= 0;
      regs.c <= 0;
      addr.virt_addr.addr <= 0;
      out <= 0;
    end

  end
endmodule

