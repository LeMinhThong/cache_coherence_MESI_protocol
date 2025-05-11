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

  // ----------------------------------------------------------------
  cache_if #(
        .PADDR_WIDTH  (PADDR_WIDTH),
        .BLK_WIDTH    (BLK_WIDTH  ),
        .NUM_BLK      (NUM_BLK    )
  ) cac_if (
        .clk        (clk       ),
        .rst_n      (rst_n     ),

        .cdr_valid  (cdr_valid ),
        .cdr_ready  (cdr_ready ),
        .cdr_op     (cdr_op    ),
        .cdr_addr   (cdr_addr  ),
        .cdr_data   (cdr_data  ),

        .cdt_valid  (cdt_valid ),
        .cdt_ready  (cdt_ready ),
        .cdt_rsp    (cdt_rsp   ),
        .cdt_data   (cdt_data  ),

        .cut_valid  (cut_valid ),
        .cut_ready  (cut_ready ),
        .cut_op     (cut_op    ),
        .cut_addr   (cut_addr  ),

        .cur_valid  (cur_valid ),
        .cur_ready  (cur_ready ),
        .cur_rsp    (cur_rsp   ),
        .cur_data   (cur_data  ),

        .sdt_valid  (sdt_valid ),
        .sdt_ready  (sdt_ready ),
        .sdt_op     (sdt_op    ),
        .sdt_addr   (sdt_addr  ),
        .sdt_data   (sdt_data  ),

        .sdr_valid  (sdr_valid ),
        .sdr_ready  (sdr_ready ),
        .sdr_rsp    (sdr_rsp   ),
        .sdr_data   (sdr_data  ),

        .sur_valid  (sur_valid ),
        .sur_ready  (sur_ready ),
        .sur_op     (sur_op    ),
        .sur_addr   (sur_addr  ),

        .sut_valid  (sut_valid ),
        .sut_ready  (sut_ready ),
        .sut_rsp    (sut_rsp   )
  );

  // ----------------------------------------------------------------
  cache_mem #(
        .PADDR_WIDTH  (PADDR_WIDTH),
        .BLK_WIDTH    (BLK_WIDTH  ),
        .NUM_BLK      (NUM_BLK    )
  ) dut (
        .clk        (clk       ),
        .rst_n      (rst_n     ),

        .cdr_valid  (cdr_valid ),
        .cdr_ready  (cdr_ready ),
        .cdr_op     (cdr_op    ),
        .cdr_addr   (cdr_addr  ),
        .cdr_data   (cdr_data  ),

        .cdt_valid  (cdt_valid ),
        .cdt_ready  (cdt_ready ),
        .cdt_rsp    (cdt_rsp   ),
        .cdt_data   (cdt_data  ),

        .cut_valid  (cut_valid ),
        .cut_ready  (cut_ready ),
        .cut_op     (cut_op    ),
        .cut_addr   (cut_addr  ),

        .cur_valid  (cur_valid ),
        .cur_ready  (cur_ready ),
        .cur_rsp    (cur_rsp   ),
        .cur_data   (cur_data  ),

        .sdt_valid  (sdt_valid ),
        .sdt_ready  (sdt_ready ),
        .sdt_op     (sdt_op    ),
        .sdt_addr   (sdt_addr  ),
        .sdt_data   (sdt_data  ),

        .sdr_valid  (sdr_valid ),
        .sdr_ready  (sdr_ready ),
        .sdr_rsp    (sdr_rsp   ),
        .sdr_data   (sdr_data  ),

        .sur_valid  (sur_valid ),
        .sur_ready  (sur_ready ),
        .sur_op     (sur_op    ),
        .sur_addr   (sur_addr  ),

        .sut_valid  (sut_valid ),
        .sut_ready  (sut_ready ),
        .sut_rsp    (sut_rsp   )
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
