`include "types.svh"

module cpu (
    input logic clock,
    input logic reset,
    output addr_t addr,
    input data_t data,
    input logic [3:0] in,
    output logic [3:0] out,
    input logic irq,
    output logic [3:0] ie,
    output logic ack
);
  register_t user_regs, priv_regs;

  logic is_priv;

  // 特権モードかどうか
  always_comb begin
    is_priv = addr.virt_addr.mode != 0;
  end

  logic [3:0] opcode;
  logic [3:0] imm;

  // オペコードとオペランドをロード
  always_comb begin
    opcode = data.instruction.opcode;
    imm = data.instruction.imm;
  end

  state_t cur, next;

  // 現在の状態をバインド
  always_comb begin
    cur.regs = is_priv ? priv_regs : user_regs;
    cur.addr = addr.virt_addr;
  end

  logic do_swap;
  logic [3:0] saved_ip;
  logic has_exception;

  // オペコードから次のクロックの状態を演算
  always_comb begin
    next.addr.mode = cur.addr.mode;
    {has_exception, next.addr.addr} = {1'b0, cur.addr.addr} + 1;
    do_swap = 0;
    has_exception |= imm != 0
      && opcode !=? 4'b??11
      && opcode !=? 4'b1?1?
      && opcode != ADD_A_IMM
      && opcode != ADD_B_IMM;
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
      OUT_B: next.out = cur.regs.b;
      IMSK: next.imsk = imm;
      OUT_IMM: next.out = imm;

      SWAP: if (is_priv) do_swap = 1;
      SWI_OR_IRET:
      if (cur.addr.mode == 2'b01) begin
        next.addr.mode = 2'b00;
        {has_exception, next.addr.addr} = {1'b0, saved_ip} + 1;
      end else if (is_priv) begin
        next.addr.mode = 2'b00;
        next.addr.addr = saved_ip;
      end else begin
        next.addr.mode = 2'b01;
        {has_exception, next.addr.addr} = 0;
      end
      JNC:  if (!cur.regs.c) {has_exception, next.addr.addr} = {1'b0, imm};
      JMP:  {has_exception, next.addr.addr} = {1'b0, imm};

      default: has_exception = 1;
    endcase
  end

  virt_addr_t exception_addr, irq_addr;

  // 例外ハンドラのアドレス
  always_comb begin
    exception_addr.mode = 2'b10;
    exception_addr.addr = 0;
    irq_addr.mode = 2'b11;
    irq_addr.addr = 0;
  end

  logic is_halted;

  always_ff @(posedge clock) begin
    ack <= 0;
    if (~reset) begin
      // リセット
      user_regs.a <= 0;
      user_regs.b <= 0;
      user_regs.c <= 0;
      priv_regs.a <= 0;
      priv_regs.b <= 0;
      priv_regs.c <= 0;
      addr.phys_addr <= 0;
      out <= 0;
      ie <= 0;
    end else if (!is_priv && irq) begin
      addr.virt_addr <= irq_addr;
      ack <= 1;
      saved_ip <= cur.addr.addr;
    end else if (has_exception) begin
      // 例外時の処理
      if (cur.addr.mode == 2'b10) is_halted <= 1;
      else addr.virt_addr <= exception_addr;
      saved_ip <= cur.addr.addr;
    end else if (!is_halted) begin
      // 次の状態をレジスタやCPUからの出力に書き出す
      if (do_swap) begin
        priv_regs.a <= user_regs.a;
        user_regs.a <= priv_regs.a;
      end else if (is_priv) priv_regs <= next.regs;
      else begin
        user_regs <= next.regs;
        saved_ip  <= cur.addr.addr;
      end
      out <= next.out;
      addr.virt_addr <= next.addr;
      ie <= next.imsk;
    end
  end
endmodule

