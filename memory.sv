module memory (
    input  logic [5:0] addr,
    output logic [7:0] data
);

  logic [7:0] mem[64];
  always_comb begin
    data = mem[addr];
  end
endmodule
