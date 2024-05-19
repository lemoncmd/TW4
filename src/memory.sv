`include "types.svh"

module memory (
    input  addr_t addr,
    output data_t data
);
  logic [7:0] mem[64] = {
    // 通常モード
    8'b1011_0111,
    8'b1101_0000,
    8'b1011_0110,
    8'b1101_0000,
    8'b1011_0000,
    8'b1011_0100,
    8'b0000_0001,
    8'b1110_0100,
    8'b1011_1000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    // ソフトウェア割り込み
    8'b0000_0001,
    8'b1110_0000,
    8'b0000_0001,
    8'b1110_0010,
    8'b1101_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    // 例外
    8'b1011_1010,
    8'b0000_0000,
    8'b1011_0101,
    8'b1111_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    // ハードウェア割り込み
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000,
    8'b0000_0000
  };

  // メモリの物理アドレスをロード
  always_comb begin
    data.raw_data = mem[addr.phys_addr];
  end
endmodule
