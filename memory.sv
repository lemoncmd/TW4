`include "types.svh"

module memory (
    input addr_t addr,
    output logic [7:0] data
);

  logic [7:0] mem[64];
  always_comb begin
    data = mem[addr.phys_addr];
  end
endmodule
