`include "cache_vip_def.svh"

interface cache_if #(
      PADDR_WIDTH = `VIP_PADDR_WIDTH,
      BLK_WIDTH   = `VIP_BLK_WIDTH,
      NUM_BLK     = `VIP_NUM_BLK,

      SADDR_WIDTH = PADDR_WIDTH-$clog2(BLK_WIDTH/8)
) (
      input wire                    clk       ,
      input wire                    rst_n     ,

      inout wire                    cdreq_valid ,
      inout wire  [2:0]             cdreq_op    ,
      inout wire  [SADDR_WIDTH-1:0] cdreq_addr  ,
      inout wire  [BLK_WIDTH-1:0]   cdreq_data  ,
      inout wire                    cdreq_ready ,

      inout wire                    cursp_valid ,
      inout wire  [1:0]             cursp_rsp   ,
      inout wire  [BLK_WIDTH-1:0]   cursp_data  ,
      inout wire                    cursp_ready ,

      inout wire                    cureq_valid ,
      inout wire  [1:0]             cureq_op    ,
      inout wire  [SADDR_WIDTH-1:0] cureq_addr  ,
      inout wire                    cureq_ready ,

      inout wire                    cdrsp_valid ,
      inout wire  [1:0]             cdrsp_rsp   ,
      inout wire  [BLK_WIDTH-1:0]   cdrsp_data  ,
      inout wire                    cdrsp_ready ,

      inout wire                    sdreq_valid ,
      inout wire  [2:0]             sdreq_op    ,
      inout wire  [SADDR_WIDTH-1:0] sdreq_addr  ,
      inout wire  [BLK_WIDTH-1:0]   sdreq_data  ,
      inout wire                    sdreq_ready ,

      inout wire                    sursp_valid ,
      inout wire  [2:0]             sursp_rsp   ,
      inout wire  [BLK_WIDTH-1:0]   sursp_data  ,
      inout wire                    sursp_ready ,

      inout wire                    sureq_valid ,
      inout wire  [1:0]             sureq_op    ,
      inout wire  [SADDR_WIDTH-1:0] sureq_addr  ,
      inout wire                    sureq_ready ,

      inout wire                    sdrsp_valid ,
      inout wire  [1:0]             sdrsp_rsp   ,
      inout wire  [BLK_WIDTH-1:0]   sdrsp_data  ,
      inout wire                    sdrsp_ready
);

  time input_skew   = 0ps;
  time output_skew  = 10ps;

  // ----------------------------------------------------------------
  clocking mon_cb @(negedge clk);
    default input #(input_skew) output #(output_skew);
    input rst_n       ;

    input cdreq_valid ;
    input cdreq_op    ;
    input cdreq_addr  ;
    input cdreq_data  ;
    input cdreq_ready ;

    input cursp_valid ;
    input cursp_rsp   ;
    input cursp_data  ;
    input cursp_ready ;

    input cureq_valid ;
    input cureq_op    ;
    input cureq_addr  ;
    input cureq_ready ;

    input cdrsp_valid ;
    input cdrsp_rsp   ;
    input cdrsp_data  ;
    input cdrsp_ready ;

    input sdreq_valid ;
    input sdreq_op    ;
    input sdreq_addr  ;
    input sdreq_data  ;
    input sdreq_ready ;

    input sursp_valid ;
    input sursp_rsp   ;
    input sursp_data  ;
    input sursp_ready ;

    input sureq_valid ;
    input sureq_op    ;
    input sureq_addr  ;
    input sureq_ready ;

    input sdrsp_valid ;
    input sdrsp_rsp   ;
    input sdrsp_data  ;
    input sdrsp_ready ;
  endclocking: mon_cb

  // ----------------------------------------------------------------
  clocking drv_cb @(posedge clk);
    default input #(input_skew) output #(output_skew);
    input   rst_n       ;

    output  cdreq_valid ;
    output  cdreq_op    ;
    output  cdreq_addr  ;
    output  cdreq_data  ;
    input   cdreq_ready ;

    input   cursp_valid ;
    input   cursp_rsp   ;
    input   cursp_data  ;
    output  cursp_ready ;

    input   cureq_valid ;
    input   cureq_op    ;
    input   cureq_addr  ;
    output  cureq_ready ;

    output  cdrsp_valid ;
    output  cdrsp_rsp   ;
    output  cdrsp_data  ;
    input   cdrsp_ready ;

    input   sdreq_valid ;
    input   sdreq_op    ;
    input   sdreq_addr  ;
    input   sdreq_data  ;
    output  sdreq_ready ;

    output  sursp_valid ;
    output  sursp_rsp   ;
    output  sursp_data  ;
    input   sursp_ready ;

    output  sureq_valid ;
    output  sureq_op    ;
    output  sureq_addr  ;
    input   sureq_ready ;

    input   sdrsp_valid ;
    input   sdrsp_rsp   ;
    input   sdrsp_data  ;
    output  sdrsp_ready ;
  endclocking: drv_cb

  // ----------------------------------------------------------------
  modport mon_mp (clocking mon_cb);
  modport drv_mp (clocking drv_cb);

endinterface: cache_if
