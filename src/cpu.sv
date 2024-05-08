`include "types.svh"

module cpu (
    input logic clock,
    input logic reset,
    output addr_t addr,
    input data_t data,
    input logic [3:0] in,
    output logic [3:0] out
);

endmodule

