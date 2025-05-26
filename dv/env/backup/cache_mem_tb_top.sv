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

  logic                   clk       ;
  logic                   rst_n     ;

  wire                    cdr_valid ;
  wire                    cdr_ready ;
  wire  [2:0]             cdr_op    ;
  wire  [SADDR_WIDTH-1:0] cdr_addr  ;
  wire  [BLK_WIDTH-1:0]   cdr_data  ;

  wire                    cdt_valid ;
  wire                    cdt_ready ;
  wire  [1:0]             cdt_rsp   ;
  wire  [BLK_WIDTH-1:0]   cdt_data  ;

  wire                    cut_valid ;
  wire                    cut_ready ;
  wire  [1:0]             cut_op    ;
  wire  [SADDR_WIDTH-1:0] cut_addr  ;

  wire                    cur_valid ;
  wire                    cur_ready ;
  wire  [1:0]             cur_rsp   ;
  wire  [BLK_WIDTH-1:0]   cur_data  ;

  wire                    sdt_valid ;
  wire                    sdt_ready ;
  wire  [2:0]             sdt_op    ;
  wire  [SADDR_WIDTH-1:0] sdt_addr  ;
  wire  [BLK_WIDTH-1:0]   sdt_data  ;

  wire                    sdr_valid ;
  wire                    sdr_ready ;
  wire  [2:0]             sdr_rsp   ;
  wire  [BLK_WIDTH-1:0]   sdr_data  ;

  wire                    sur_valid ;
  wire                    sur_ready ;
  wire  [1:0]             sur_op    ;
  wire  [SADDR_WIDTH-1:0] sur_addr  ;

  wire                    sut_valid ;
  wire                    sut_ready ;
  wire  [1:0]             sut_rsp   ;
  //wire  [BLK_WIDTH-1:0]   sut_data  
  //wire                    cr_valid;
  //wire                    cr_ready;
  //wire [1:0]              rx_l1_op;
  //wire [SADDR_WIDTH-1:0]  rx_l1_addr;
  //wire [BLK_WIDTH-1:0]    rx_l1_data;

  //wire                    ct_valid;
  //wire                    ct_ready;
  //wire                    tx_l1_wait;
  //wire [BLK_WIDTH-1:0]    tx_l1_data;

  //wire                    ci_valid;
  //wire                    ci_ready;
  //wire  [SADDR_WIDTH-1:0] ci_addr;

  //wire                    dt_valid;
  //wire                    dt_ready;
  //wire [2:0]              tx_snp_op;
  //wire [SADDR_WIDTH-1:0]  tx_snp_addr;

  //wire                    dr_valid;
  //wire                    dr_ready;
  //wire [BLK_WIDTH-1:0]    rx_snp_data;
  //wire [1:0]              rx_snp_rsp;

  //wire                    ur_valid;
  //wire                    ur_ready;
  //wire [2:0]              rx_snp_op;
  //wire [SADDR_WIDTH-1:0]  rx_snp_addr;

  //wire                    ut_valid;
  //wire                    ut_ready;
  //wire [BLK_WIDTH-1:0]    tx_snp_data;
  //wire [1:0]              tx_snp_rsp;

  // ----------------------------------------------------------------
  cache_if #(
        .PADDR_WIDTH  (PADDR_WIDTH),
        .BLK_WIDTH    (BLK_WIDTH  ),
        .NUM_BLK      (NUM_BLK    )
  ) cac_if (
        .clk         (clk         ),
        .rst_n       (rst_n       ),
        .cr_valid    (cr_valid    ),
        .cr_ready    (cr_ready    ),
        .rx_l1_op    (rx_l1_op    ),
        .rx_l1_addr  (rx_l1_addr  ),
        .rx_l1_data  (rx_l1_data  ),
        .ct_valid    (ct_valid    ),
        .ct_ready    (ct_ready    ),
        .tx_l1_wait  (tx_l1_wait  ),
        .tx_l1_data  (tx_l1_data  ),
        .ci_valid    (ci_valid    ),
        .ci_ready    (ci_ready    ),
        .ci_addr     (ci_addr     ),
        .dt_valid    (dt_valid    ),
        .dt_ready    (dt_ready    ),
        .tx_snp_op   (tx_snp_op   ),
        .tx_snp_addr (tx_snp_addr ),
        .dr_valid    (dr_valid    ),
        .dr_ready    (dr_ready    ),
        .rx_snp_data (rx_snp_data ),
        .rx_snp_rsp  (rx_snp_rsp  ),
        .ur_valid    (ur_valid    ),
        .ur_ready    (ur_ready    ),
        .rx_snp_op   (rx_snp_op   ),
        .rx_snp_addr (rx_snp_addr ),
        .ut_valid    (ut_valid    ),
        .ut_ready    (ut_ready    ),
        .tx_snp_data (tx_snp_data ),
        .tx_snp_rsp  (tx_snp_rsp  )
  );

  // ----------------------------------------------------------------
  cache_mem #(
        .PADDR_WIDTH  (PADDR_WIDTH),
        .BLK_WIDTH    (BLK_WIDTH  ),
        .NUM_BLK      (NUM_BLK    )
  ) dut (
        .clk         (clk         ),
        .rst_n       (rst_n       ),
        .cr_valid    (cr_valid    ),
        .cr_ready    (cr_ready    ),
        .rx_l1_op    (rx_l1_op    ),
        .rx_l1_addr  (rx_l1_addr  ),
        .rx_l1_data  (rx_l1_data  ),
        .ct_valid    (ct_valid    ),
        .ct_ready    (ct_ready    ),
        .tx_l1_wait  (tx_l1_wait  ),
        .tx_l1_data  (tx_l1_data  ),
        .ci_valid    (ci_valid    ),
        .ci_ready    (ci_ready    ),
        .ci_addr     (ci_addr     ),
        .dt_valid    (dt_valid    ),
        .dt_ready    (dt_ready    ),
        .tx_snp_op   (tx_snp_op   ),
        .tx_snp_addr (tx_snp_addr ),
        .dr_valid    (dr_valid    ),
        .dr_ready    (dr_ready    ),
        .rx_snp_data (rx_snp_data ),
        .rx_snp_rsp  (rx_snp_rsp  ),
        .ur_valid    (ur_valid    ),
        .ur_ready    (ur_ready    ),
        .rx_snp_op   (rx_snp_op   ),
        .rx_snp_addr (rx_snp_addr ),
        .ut_valid    (ut_valid    ),
        .ut_ready    (ut_ready    ),
        .tx_snp_data (tx_snp_data ),
        .tx_snp_rsp  (tx_snp_rsp  )
  );

  //-------------------------------------------------------------------
  initial begin
    forever #5ns clk = ~clk;
  end

  //-------------------------------------------------------------------
  initial begin
    clk   = 1'b0;
    rst_n = 1'b0;
    repeat (3) @(posedge clk);
    rst_n = 1'b1;
  end

  //-------------------------------------------------------------------
  initial begin
    uvm_pkg::uvm_config_db#(virtual cache_if)::set(null, "*", "cac_if", cac_if);
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
