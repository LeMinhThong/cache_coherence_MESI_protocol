`include "cache_vip_def.svh"

interface cache_if #(
      PADDR_WIDTH = `VIP_PADDR_WIDTH,
      BLK_WIDTH   = `VIP_BLK_WIDTH,
      NUM_BLK     = `VIP_NUM_BLK,

      SADDR_WIDTH = PADDR_WIDTH-$clog2(BLK_WIDTH/8)
) (
      input wire                    clk       ,
      input wire                    rst_n     ,

      inout wire                    cdr_valid ,
      inout wire                    cdr_ready ,
      inout wire  [2:0]             cdr_op    ,
      inout wire  [SADDR_WIDTH-1:0] cdr_addr  ,
      inout wire  [BLK_WIDTH-1:0]   cdr_data  ,

      inout wire                    cdt_valid ,
      inout wire                    cdt_ready ,
      inout wire  [1:0]             cdt_rsp   ,
      inout wire  [BLK_WIDTH-1:0]   cdt_data  ,

      inout wire                    cut_valid ,
      inout wire                    cut_ready ,
      inout wire  [1:0]             cut_op    ,
      inout wire  [SADDR_WIDTH-1:0] cut_addr  ,

      inout wire                    cur_valid ,
      inout wire                    cur_ready ,
      inout wire  [1:0]             cur_rsp   ,
      inout wire  [BLK_WIDTH-1:0]   cur_data  ,

      inout wire                    sdt_valid ,
      inout wire                    sdt_ready ,
      inout wire  [2:0]             sdt_op    ,
      inout wire  [SADDR_WIDTH-1:0] sdt_addr  ,
      inout wire  [BLK_WIDTH-1:0]   sdt_data  ,

      inout wire                    sdr_valid ,
      inout wire                    sdr_ready ,
      inout wire  [2:0]             sdr_rsp   ,
      inout wire  [BLK_WIDTH-1:0]   sdr_data  ,

      inout wire                    sur_valid ,
      inout wire                    sur_ready ,
      inout wire  [1:0]             sur_op    ,
      inout wire  [SADDR_WIDTH-1:0] sur_addr  ,

      inout wire                    sut_valid ,
      inout wire                    sut_ready ,
      inout wire  [1:0]             sut_rsp   ,
      inout wire  [BLK_WIDTH-1:0]   sut_data  
);

  time input_skew   = 0ps;
  time output_skew  = 10ps;

  // ----------------------------------------------------------------
  clocking mon_cb @(negedge clk);
    default input #(input_skew) output #(output_skew);
    input rst_n     ;

    input cdr_valid ;
    input cdr_ready ;
    input cdr_op    ;
    input cdr_addr  ;
    input cdr_data  ;

    input cdt_valid ;
    input cdt_ready ;
    input cdt_rsp   ;
    input cdt_data  ;

    input cut_valid ;
    input cut_ready ;
    input cut_op    ;
    input cut_addr  ;

    input cur_valid ;
    input cur_ready ;
    input cur_rsp   ;
    input cur_data  ;

    input sdt_valid ;
    input sdt_ready ;
    input sdt_op    ;
    input sdt_addr  ;
    input sdt_data  ;

    input sdr_valid ;
    input sdr_ready ;
    input sdr_rsp   ;
    input sdr_data  ;

    input sur_valid ;
    input sur_ready ;
    input sur_op    ;
    input sur_addr  ;

    input sut_valid ;
    input sut_ready ;
    input sut_rsp   ;
    input sut_data  ;
  endclocking: mon_cb

  // ----------------------------------------------------------------
  clocking drv_cb @(posedge clk);
    default input #(input_skew) output #(output_skew);
    output  rst_n     ;

    output  cdr_valid ;
    input   cdr_ready ;
    output  cdr_op    ;
    output  cdr_addr  ;
    output  cdr_data  ;

    input   cdt_valid ;
    output  cdt_ready ;
    input   cdt_rsp   ;
    input   cdt_data  ;

    input   cut_valid ;
    output  cut_ready ;
    input   cut_op    ;
    input   cut_addr  ;

    output  cur_valid ;
    input   cur_ready ;
    output  cur_rsp   ;
    output  cur_data  ;

    input   sdt_valid ;
    output  sdt_ready ;
    input   sdt_op    ;
    input   sdt_addr  ;
    input   sdt_data  ;

    output  sdr_valid ;
    input   sdr_ready ;
    output  sdr_rsp   ;
    output  sdr_data  ;

    output  sur_valid ;
    input   sur_ready ;
    output  sur_op    ;
    output  sur_addr  ;

    input   sut_valid ;
    output  sut_ready ;
    input   sut_rsp   ;
    input   sut_data  ;
  endclocking: drv_cb

  // ----------------------------------------------------------------
  modport mon_mp (clocking mon_cb);
  modport drv_mp (clocking drv_cb);

endinterface: cache_if
