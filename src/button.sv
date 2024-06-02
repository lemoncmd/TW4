module button (
    input  logic in,
    input  logic ack,
    input  logic ie,
    input  logic iei,
    // verilator lint_off UNOPTFLAT
    output logic ieo,
    // verilator lint_on UNOPTFLAT
    output logic irq
);

  logic prev_in = 0;
  logic has_irq = 0;

  always_comb begin
    ieo = !has_irq && iei;
  end

  always_ff @(in, negedge ack) begin
    prev_in <= in;
    if (!prev_in && in && ie) has_irq <= 1;
    else if (has_irq && !ack && iei) has_irq <= 0;
  end

  always_comb begin
    irq = has_irq && iei ? 1 : 1'bz;
  end

endmodule
