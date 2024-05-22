`include "types.svh"

module memory (
    input  addr_t addr,
    output data_t data
);
  logic [7:0] mem[64];

  initial begin
    $readmemb("obj_dir/test.bin", mem);
  end

  // メモリの物理アドレスをロード
  always_comb begin
    data.raw_data = mem[addr.phys_addr];
  end
endmodule
