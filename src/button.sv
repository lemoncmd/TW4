module button (
    input  logic clock,
    input  logic in,
    input  logic ack,
    input  logic ie,
    input  logic iei,
    output logic ieo,
    output logic irq
);

  logic prev_in, prev_ack;

  always_comb begin
    ieo = !((!prev_in && in && ie) || irq) && iei;
  end

  logic has_irq;

  always_ff @(posedge clock) begin
    prev_in  <= in;
    prev_ack <= ack;
    if (!prev_in && in && ie) begin
      has_irq <= 1;
    end
    if (!prev_ack && ack && iei) has_irq <= 0;
  end

  always_comb begin
    irq = has_irq && iei ? 1 : 1'bz;
  end

endmodule
