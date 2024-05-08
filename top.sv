module top;
  logic clock = 0;
  logic reset = 0;
  logic [3:0] in = 0;
  logic [3:0] out;
  logic [7:0] data;
  logic [5:0] addr;
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

endmodule
