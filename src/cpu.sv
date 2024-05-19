`include "types.svh"

module cpu (
    input logic clock,
    input logic reset,
    output addr_t addr,
    input data_t data,
    input logic [3:0] in,
    output logic [3:0] out
);
  register_t user_regs, priv_regs;

  logic [3:0] opcode;
  logic [3:0] imm;

  state_t cur, next;

  logic is_priv;

  // オペコードとオペランドをロード
  always_comb begin
    opcode = data.instruction.opcode;
    imm = data.instruction.imm;
  end

  // 現在の状態をバインド
  always_comb begin
    cur.regs = is_priv ? priv_regs : user_regs;
    cur.addr = addr.virt_addr;
  end

  logic do_swap;

  // オペコードから次のクロックの状態を演算
  always_comb begin
    next.addr.addr = cur.addr.addr + 1;
    do_swap = 0;
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

      SWAP: if (is_priv) do_swap = 1;
      // NOP3: ;
      JNC:  if (!cur.regs.c) next.addr.addr = imm;
      JMP:  next.addr.addr = imm;

      default: ;
    endcase
  end

  always_ff @(posedge clock) begin
    if (~reset) begin
      // リセット
      user_regs.a <= 0;
      user_regs.b <= 0;
      user_regs.c <= 0;
      priv_regs.a <= 0;
      priv_regs.b <= 0;
      priv_regs.c <= 0;
      addr.virt_addr.addr <= 0;
      out <= 0;
    end else begin
      // 次の状態をレジスタやCPUからの出力に書き出す
      if (do_swap) begin
        priv_regs.a <= user_regs.a;
        user_regs.a <= priv_regs.a;
      end else if (is_priv) priv_regs <= next.regs;
      else user_regs <= next.regs;
      out <= next.out;
      addr.virt_addr <= next.addr;
    end

  end
endmodule

