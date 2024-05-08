`include "types.svh"

module cpu (
    input logic clock,
    input logic reset,
    output addr_t addr,
    input data_t data,
    input logic [3:0] in,
    output logic [3:0] out
);
  logic [3:0] a, b;

  always_ff @(posedge reset) begin
    a <= 0;
    b <= 0;
    addr.virt_addr.mode <= 0;
    addr.virt_addr.addr <= 0;
    out <= 0;
  end
endmodule

