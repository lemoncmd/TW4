`include "types.svh"

module memory (
    input  addr_t addr,
    output data_t data
);

  logic [7:0] mem[16];
  always_comb begin
    data.raw_data = mem[addr.phys_addr];
  end
endmodule
