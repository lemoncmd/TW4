`include "types.svh"

module top;
  logic clock = 0;
  logic reset = 0;
  logic [3:0] in = 0;
  logic [3:0] out;
  data_t data;
  addr_t addr;
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

  initial begin
    $finish;
  end
endmodule
