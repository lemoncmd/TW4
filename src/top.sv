`include "types.svh"

module top;
  logic clock = 0;
  logic reset = 0;
  logic [3:0] in = 0;
  logic [3:0] out;
  data_t data;
  addr_t addr;

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
      .out(out)
  );

  memory memory (
      .addr(addr),
      .data(data)
  );

  // リセットをかけてしばらくシミュレーション
  initial begin
    #20 reset = 1;
    #10000 $finish;
  end

  // out が変化したらデバッグ表示
  always_ff @(out) begin
    $display("LED: %d", out);
  end
endmodule
