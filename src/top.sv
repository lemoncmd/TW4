`include "types.svh"

module top;
  logic clock = 0;
  logic reset = 0;
  logic [3:0] in = 0;
  logic [3:0] out;
  data_t data;
  addr_t addr;
  logic ack;
  // verilator lint_off UNOPTFLAT
  logic irq;
  // verilator lint_on UNOPTFLAT
  logic [3:0] ie;
  logic [3:0] ieo;
  logic irq_in;

  // シミュレーション用のクロック
  always_ff #5 begin
    clock <= ~clock;
  end

  cpu cpu (
      .clock(clock),
      .reset(reset),
      .addr(addr),
      .data(data),
      .in(in),
      .out(out),
      .irq(irq_in),
      .ie(ie),
      .ack(ack)
  );

  memory memory (
      .addr(addr),
      .data(data)
  );

  button button0 (
      .clock(clock),
      .in(in[0]),
      .ack(ack),
      .ie(ie[0]),
      .iei(1),
      .ieo(ieo[0]),
      .irq(irq)
  );

  button button1 (
      .clock(clock),
      .in(in[1]),
      .ack(ack),
      .ie(ie[1]),
      .iei(ieo[0]),
      .ieo(ieo[1]),
      .irq(irq)
  );

  button button2 (
      .clock(clock),
      .in(in[2]),
      .ack(ack),
      .ie(ie[2]),
      .iei(ieo[1]),
      .ieo(ieo[2]),
      .irq(irq)
  );

  button button3 (
      .clock(clock),
      .in(in[3]),
      .ack(ack),
      .ie(ie[3]),
      .iei(ieo[2]),
      .ieo(ieo[3]),
      .irq(irq)
  );

  always_comb begin
    irq_in = irq == 1 ? 1 : 0;
  end

  // リセットをかけてしばらくシミュレーション
  initial begin
    #20 reset = 1;
    #1000 in[0] = 1;
    #250 in[0] = 0;
    #250 in[0] = 1;
    #250 in[0] = 0;
    #250 in[0] = 1;
    #3000 $finish;
  end

  // out が変化したらデバッグ表示
  always_ff @(out) begin
    $display("LED: %d", out);
  end
endmodule
