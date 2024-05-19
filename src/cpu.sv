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

  logic [3:0] opcode;
  logic [3:0] imm;

  always_comb begin
    opcode = data.instruction.opcode;
    imm = data.instruction.imm;
  end

  state_t cur, next;

  always_comb begin
    cur.regs = regs;
    cur.addr = addr.virt_addr;
  end

  always_comb begin
    next.addr.addr = cur.addr.addr + 1;
    unique case (opcode)
      ADD_A_IMM: {next.regs.c, next.regs.a} = {1'b0, cur.regs.a} + {1'b0, imm};
      MOV_A_B: next.regs.a = cur.regs.b;
      IN_A: next.regs.a = in;
      MOV_A_IMM: next.regs.a = imm;

      MOV_B_A: next.regs.b = cur.regs.a;
      ADD_B_IMM: {next.regs.c, next.regs.b} = {1'b0, cur.regs.b} + {1'b0, imm};
      IN_B: next.regs.b = in;
      MOV_B_IMM: next.regs.b = imm;

      // NOP0: ;
      OUT_B:   next.out = cur.regs.b;
      // NOP1: ;
      OUT_IMM: next.out = imm;

      // NOP2: ;
      // NOP3: ;
      JNC: if (!cur.regs.c) next.addr.addr = imm;
      JMP: next.addr.addr = imm;

      default: ;
    endcase
  end

  always_ff @(posedge clock, negedge reset) begin
    if (~reset) begin
      regs.a <= 0;
      regs.b <= 0;
      regs.c <= 0;
      addr.virt_addr.addr <= 0;
      out <= 0;
    end else begin
      regs <= next.regs;
      out <= next.out;
      addr.virt_addr <= next.addr;
    end

  end
endmodule

