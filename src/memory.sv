`include "types.svh"

module memory (
    input  addr_t addr,
    output data_t data
);

  logic [7:0] mem[16] = {
    8'b1011_0111,
    8'b0000_0001,
    8'b1110_0001,
    8'b0000_0001,
    8'b1110_0011,
    8'b1011_0110,
    8'b0000_0001,
    8'b1110_0110,
    8'b0000_0001,
    8'b1110_1000,
    8'b1011_0000,
    8'b1011_0100,
    8'b0000_0001,
    8'b1110_1010,
    8'b1011_1000,
    8'b1111_1111
  };
  always_comb begin
    data.raw_data = mem[addr.phys_addr];
  end
endmodule
