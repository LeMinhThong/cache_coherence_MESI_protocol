`ifndef CACHE_MEM_TB_TOP_SV
`define CACHE_MEM_TB_TOP_SV

module cache_mem_tb_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh";

  import cache_test_pkg::*;

  // ----------------------------------------------------------------
  localparam PADDR_WIDTH = 64;
  localparam BLK_WIDTH   = 512;
  localparam NUM_BLK     = 1024;

  localparam SADDR_WIDTH = PADDR_WIDTH-$clog2(BLK_WIDTH/8);

  logic                   clk;
  logic                   rst_n;

  wire  [1:0]             rx_l1_op;
  wire  [SADDR_WIDTH-1:0] rx_l1_addr;
  wire  [BLK_WIDTH-1:0]   rx_l1_data;

  wire                    tx_l1_wait;
  wire  [BLK_WIDTH-1:0]   tx_l1_data;

  wire  [2:0]             rx_snp_op;
  wire  [SADDR_WIDTH-1:0] rx_snp_addr;
  wire  [BLK_WIDTH-1:0]   rx_snp_data;
  wire  [1:0]             rx_snp_rsp;

  wire  [2:0]             tx_snp_op;
  wire  [SADDR_WIDTH-1:0] tx_snp_addr;
  wire  [BLK_WIDTH-1:0]   tx_snp_data;
  wire  [1:0]             tx_snp_rsp;
  
  // ----------------------------------------------------------------
  cache_if #(
        .PADDR_WIDTH  (PADDR_WIDTH),
        .BLK_WIDTH    (BLK_WIDTH  ),
        .NUM_BLK      (NUM_BLK    )
  ) cac_if (
        .clk          (clk        ),
        .rst_n        (rst_n      ),
                                  
        .rx_l1_op     (rx_l1_op   ),
        .rx_l1_addr   (rx_l1_addr ),
        .rx_l1_data   (rx_l1_data ),
                                  
        .tx_l1_wait   (tx_l1_wait ),
        .tx_l1_data   (tx_l1_data ),
                                  
        .rx_snp_op    (rx_snp_op  ),
        .rx_snp_addr  (rx_snp_addr),
        .rx_snp_data  (rx_snp_data),
        .rx_snp_rsp   (rx_snp_rsp ),
                                  
        .tx_snp_op    (tx_snp_op  ),
        .tx_snp_addr  (tx_snp_addr),
        .tx_snp_data  (tx_snp_data),
        .tx_snp_rsp   (tx_snp_rsp )
  );

  // ----------------------------------------------------------------
  cache_mem #(
        .PADDR_WIDTH  (PADDR_WIDTH),
        .BLK_WIDTH    (BLK_WIDTH  ),
        .NUM_BLK      (NUM_BLK    )
  ) dut (
        .clk          (clk        ),
        .rst_n        (rst_n      ),
                                  
        .rx_l1_op     (rx_l1_op   ),
        .rx_l1_addr   (rx_l1_addr ),
        .rx_l1_data   (rx_l1_data ),
                                  
        .tx_l1_wait   (tx_l1_wait ),
        .tx_l1_data   (tx_l1_data ),
                                  
        .rx_snp_op    (rx_snp_op  ),
        .rx_snp_addr  (rx_snp_addr),
        .rx_snp_data  (rx_snp_data),
        .rx_snp_rsp   (rx_snp_rsp ),
                                  
        .tx_snp_op    (tx_snp_op  ),
        .tx_snp_addr  (tx_snp_addr),
        .tx_snp_data  (tx_snp_data),
        .tx_snp_rsp   (tx_snp_rsp )
  );

  //-------------------------------------------------------------------
  initial begin
    forever #5ns clk = ~clk;
  end

  //-------------------------------------------------------------------
  initial begin
    clk   = 1'b0;
    rst_n = 1'b0;
    repeat (5) @(posedge clk);
    rst_n = 1'b1;
  end

  //-------------------------------------------------------------------
  initial begin
    uvm_pkg::uvm_config_db#(virtual cache_if)::set(null, "uvm_test_top.*", "cac_if", cac_if);
  end

  //-------------------------------------------------------------------
  initial begin
    $display("hello from cache_mem_tb");
    run_test("cache_base_test_c");
    $display("complete cache_mem_tb");
    $finish;
  end
endmodule: cache_mem_tb_top

`endif
