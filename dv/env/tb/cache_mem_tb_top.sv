`ifndef CACHE_MEM_TB_TOP_SV
`define CACHE_MEM_TB_TOP_SV

module cache_mem_tb_top;

  import uvm_pkg::*;
  import cache_test_pkg::*;
  
  `include "cache_mem_def.svh"

  reg                   clk;
  reg                   rst_n;
  
  reg                   cpu2cac_rd;
  reg                   cpu2cac_wr;
  reg [`ADDR_WIDTH-1:0] cpu2cac_addr;
  reg [`DATA_WIDTH-1:0] cpu2cac_data;
  
  reg                   cac2cpu_hit;
  reg                   cac2cpu_miss;
  reg [`DATA_WIDTH-1:0] cac2cpu_data;
  
  reg                   cac2bus_rd;
  reg                   cac2bus_wr;
  reg [`ADDR_WIDTH-$clog2(`LINE_SIZE/8)-1:0]  cac2bus_addr;
  reg [`DATA_WIDTH-1:0] cac2bus_data;
  
  cache_mem #(
        .LINE_SIZE      (`LINE_SIZE),
        .NUM_CACHE_LINE (`NUM_CACHE_LINE),
        .ADDR_WIDTH     (`ADDR_WIDTH),
        .DATA_WIDTH     (`DATA_WIDTH)
  ) dut (
      .clk          (clk         ),
      .rst_n        (rst_n       ),
                                  
      .cpu2cac_rd   (cpu2cac_rd  ),
      .cpu2cac_wr   (cpu2cac_wr  ),
      .cpu2cac_addr (cpu2cac_addr),
      .cpu2cac_data (cpu2cac_data),
                                  
      .cac2cpu_hit  (cac2cpu_hit ),
      .cac2cpu_miss (cac2cpu_miss),
      .cac2cpu_data (cac2cpu_data),
                                  
      .cac2bus_rd   (cac2bus_rd  ),
      .cac2bus_wr   (cac2bus_wr  ),
      .cac2bus_addr (cac2bus_addr),
      .cac2bus_data (cac2bus_data)
  );

//-------------------------------------------------------------------

  initial begin
    forever #5 clk = ~clk;
  end
  initial begin
    clk   = 1'b0;
    rst_n = 1'b0;
    repeat (5) @(posedge clk);
    rst_n = 1'b1;
  end

  initial begin
    $display("hello from cache_mem_tb");
    run_test("base_test");
    $display("complete cache_mem_tb");
    $finish;
  end
endmodule: cache_mem_tb_top

`endif
