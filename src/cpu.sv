`include "types.svh"

module cpu (
    input logic clock,
    input logic reset,
    output addr_t addr,
    input data_t data,
    input logic [3:0] in,
    output logic [3:0] out
);
  register_t user_regs;

  logic [3:0] opcode;
  logic [3:0] imm;

  always_comb begin
    opcode = data.instruction.opcode;
    imm = data.instruction.imm;
  end

  function static void execute(input logic [3:0] in, ref register_t regs);
    addr.virt_addr.addr <= addr.virt_addr.addr + 1;
    unique case (opcode)
      ADD_A_IMM: {regs.c, regs.a} = {1'b0, regs.a} + {1'b0, imm};
      MOV_A_B: regs.a = regs.b;
      IN_A: regs.a = in;
      MOV_A_IMM: regs.a = imm;

      MOV_B_A: regs.b = regs.a;
      ADD_B_IMM: {regs.c, regs.b} = {1'b0, regs.b} + {1'b0, imm};
      IN_B: regs.b = in;
      MOV_B_IMM: regs.b = imm;

      // NOP0: ;
      OUT_B:   out <= regs.b;
      // NOP1: ;
      OUT_IMM: out <= imm;

      // NOP2: ;
      // NOP3: ;
      JNC: if (!regs.c) addr.virt_addr.addr <= imm;
      JMP: addr.virt_addr.addr <= imm;

      default: ;
    endcase
  endfunction

  function static void reset_regs(ref register_t regs);
    regs.a = 0;
    regs.b = 0;
    regs.c = 0;
  endfunction

  always_ff @(posedge clock, negedge reset) begin
    if (~reset) begin
      reset_regs(user_regs);
      addr.virt_addr.addr <= 0;
      out <= 0;
    end else begin
      execute(in, user_regs);
    end

  end
endmodule

