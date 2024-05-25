`include "types.svh"

module memory (
    input  addr_t addr,
    output data_t data
);
  logic [7:0] mem[64];

  integer fd = 0;
  integer i = 0;
  integer ret = 0;
  initial begin
    fd = $fopen("obj_dir/mem.bin", "r");
    if (fd == 0) begin
      $display("could not open memory file.");
      $finish;
    end

    for (i = 0; i < 64; i = i + 1) begin
      ret = $fscanf(fd, "%b\n", mem[i]);
      if (ret == 0) begin
        $display("end of file reached or error reading file.");
        $finish;
      end
    end

    $fclose(fd);
  end

  // メモリの物理アドレスをロード
  always_comb begin
    data.raw_data = mem[addr.phys_addr];
  end
endmodule
