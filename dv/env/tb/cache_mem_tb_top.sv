`ifndef CACHE_MEM_TB_TOP_SV
`define CACHE_MEM_TB_TOP_SV

module cache_mem_tb_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh";

  import cache_tests_pkg::*;
  import cache_pkg::*;
  `include "cache_def.sv"

  // ----------------------------------------------------------------
  localparam PADDR_WIDTH = 64;
  localparam BLK_WIDTH   = 512;
  localparam NUM_BLK     = 1024;

  localparam SADDR_WIDTH = PADDR_WIDTH-$clog2(BLK_WIDTH/8);

  logic                   clk       ;
  logic                   rst_n     ;

  wire                    cdreq_valid ;
  wire  [2:0]             cdreq_op    ;
  wire  [SADDR_WIDTH-1:0] cdreq_addr  ;
  wire  [BLK_WIDTH-1:0]   cdreq_data  ;
  wire                    cdreq_ready ;

  wire                    cursp_valid ;
  wire  [1:0]             cursp_rsp   ;
  wire  [BLK_WIDTH-1:0]   cursp_data  ;
  wire                    cursp_ready ;

  wire                    cureq_valid ;
  wire  [1:0]             cureq_op    ;
  wire  [SADDR_WIDTH-1:0] cureq_addr  ;
  wire                    cureq_ready ;

  wire                    cdrsp_valid ;
  wire  [1:0]             cdrsp_rsp   ;
  wire  [BLK_WIDTH-1:0]   cdrsp_data  ;
  wire                    cdrsp_ready ;

  wire                    sdreq_valid ;
  wire  [2:0]             sdreq_op    ;
  wire  [SADDR_WIDTH-1:0] sdreq_addr  ;
  wire  [BLK_WIDTH-1:0]   sdreq_data  ;
  wire                    sdreq_ready ;

  wire                    sursp_valid ;
  wire  [2:0]             sursp_rsp   ;
  wire  [BLK_WIDTH-1:0]   sursp_data  ;
  wire                    sursp_ready ;

  wire                    sureq_valid ;
  wire  [1:0]             sureq_op    ;
  wire  [SADDR_WIDTH-1:0] sureq_addr  ;
  wire                    sureq_ready ;

  wire                    sdrsp_valid ;
  wire  [1:0]             sdrsp_rsp   ;
  wire  [BLK_WIDTH-1:0]   sdrsp_data  ;
  wire                    sdrsp_ready ;

  // ----------------------------------------------------------------
  cache_if #(
        .PADDR_WIDTH  (PADDR_WIDTH),
        .BLK_WIDTH    (BLK_WIDTH  ),
        .NUM_BLK      (NUM_BLK    )
  ) cac_if (
        .clk        (clk       ),
        .rst_n      (rst_n     ),

        .cdreq_valid  (cdreq_valid ),
        .cdreq_op     (cdreq_op    ),
        .cdreq_addr   (cdreq_addr  ),
        .cdreq_data   (cdreq_data  ),
        .cdreq_ready  (cdreq_ready ),

        .cursp_valid  (cursp_valid ),
        .cursp_rsp    (cursp_rsp   ),
        .cursp_data   (cursp_data  ),
        .cursp_ready  (cursp_ready ),

        .cureq_valid  (cureq_valid ),
        .cureq_op     (cureq_op    ),
        .cureq_addr   (cureq_addr  ),
        .cureq_ready  (cureq_ready ),

        .cdrsp_valid  (cdrsp_valid ),
        .cdrsp_rsp    (cdrsp_rsp   ),
        .cdrsp_data   (cdrsp_data  ),
        .cdrsp_ready  (cdrsp_ready ),

        .sdreq_valid  (sdreq_valid ),
        .sdreq_op     (sdreq_op    ),
        .sdreq_addr   (sdreq_addr  ),
        .sdreq_data   (sdreq_data  ),
        .sdreq_ready  (sdreq_ready ),

        .sursp_valid  (sursp_valid ),
        .sursp_rsp    (sursp_rsp   ),
        .sursp_data   (sursp_data  ),
        .sursp_ready  (sursp_ready ),

        .sureq_valid  (sureq_valid ),
        .sureq_op     (sureq_op    ),
        .sureq_addr   (sureq_addr  ),
        .sureq_ready  (sureq_ready ),

        .sdrsp_valid  (sdrsp_valid ),
        .sdrsp_ready  (sdrsp_ready ),
        .sdrsp_rsp    (sdrsp_rsp   ),
        .sdrsp_data   (sdrsp_data  )
  );

  // ----------------------------------------------------------------
  cache_mem #(
        .PADDR_WIDTH  (PADDR_WIDTH),
        .BLK_WIDTH    (BLK_WIDTH  ),
        .NUM_BLK      (NUM_BLK    )
  ) dut (
        .clk        (clk       ),
        .rst_n      (rst_n     ),

        .cdreq_valid  (cdreq_valid ),
        .cdreq_op     (cdreq_op    ),
        .cdreq_addr   (cdreq_addr  ),
        .cdreq_data   (cdreq_data  ),
        .cdreq_ready  (cdreq_ready ),

        .cursp_valid  (cursp_valid ),
        .cursp_rsp    (cursp_rsp   ),
        .cursp_data   (cursp_data  ),
        .cursp_ready  (cursp_ready ),

        .cureq_valid  (cureq_valid ),
        .cureq_op     (cureq_op    ),
        .cureq_addr   (cureq_addr  ),
        .cureq_ready  (cureq_ready ),

        .cdrsp_valid  (cdrsp_valid ),
        .cdrsp_rsp    (cdrsp_rsp   ),
        .cdrsp_data   (cdrsp_data  ),
        .cdrsp_ready  (cdrsp_ready ),

        .sdreq_valid  (sdreq_valid ),
        .sdreq_op     (sdreq_op    ),
        .sdreq_addr   (sdreq_addr  ),
        .sdreq_data   (sdreq_data  ),
        .sdreq_ready  (sdreq_ready ),

        .sursp_valid  (sursp_valid ),
        .sursp_rsp    (sursp_rsp   ),
        .sursp_data   (sursp_data  ),
        .sursp_ready  (sursp_ready ),

        .sureq_valid  (sureq_valid ),
        .sureq_op     (sureq_op    ),
        .sureq_addr   (sureq_addr  ),
        .sureq_ready  (sureq_ready ),

        .sdrsp_valid  (sdrsp_valid ),
        .sdrsp_rsp    (sdrsp_rsp   ),
        .sdrsp_data   (sdrsp_data  ),
        .sdrsp_ready  (sdrsp_ready )
  );

  //-------------------------------------------------------------------
  initial begin
    clk   = 1'b0;
    forever #5ns clk = ~clk;
  end

  //-------------------------------------------------------------------
  initial begin
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
