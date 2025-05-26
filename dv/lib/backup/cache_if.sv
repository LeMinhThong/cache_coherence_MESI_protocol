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
      //input wire                    clk,
      //input wire                    rst_n,
      //inout wire                    cr_valid,
      //inout wire                    cr_ready,
      //inout wire [1:0]              rx_l1_op,
      //inout wire [SADDR_WIDTH-1:0]  rx_l1_addr,
      //inout wire [BLK_WIDTH-1:0]    rx_l1_data,
      //inout wire                    ct_valid,
      //inout wire                    ct_ready,
      //inout wire                    tx_l1_wait,
      //inout wire [BLK_WIDTH-1:0]    tx_l1_data,
      //inout wire                    ci_valid,
      //inout wire                    ci_ready,
      //inout wire  [SADDR_WIDTH-1:0] ci_addr,
      //inout wire                    dt_valid,
      //inout wire                    dt_ready,
      //inout wire [2:0]              tx_snp_op,
      //inout wire [SADDR_WIDTH-1:0]  tx_snp_addr,
      //inout wire                    dr_valid,
      //inout wire                    dr_ready,
      //inout wire [BLK_WIDTH-1:0]    rx_snp_data,
      //inout wire [1:0]              rx_snp_rsp,
      //inout wire                    ur_valid,
      //inout wire                    ur_ready,
      //inout wire [2:0]              rx_snp_op,
      //inout wire [SADDR_WIDTH-1:0]  rx_snp_addr,
      //inout wire                    ut_valid,
      //inout wire                    ut_ready,
      //inout wire [BLK_WIDTH-1:0]    tx_snp_data,
      //inout wire [1:0]              tx_snp_rsp
);

  time input_skew   = 0ps;
  time output_skew  = 10ps;

  // ----------------------------------------------------------------
  clocking mon_cb @(negedge clk);
    default input #(input_skew) output #(output_skew);
    input rst_n;
    input cr_valid;
    input cr_ready;
    input rx_l1_op;
    input rx_l1_addr;
    input rx_l1_data;
    input ct_valid;
    input ct_ready;
    input tx_l1_wait;
    input tx_l1_data;
    input ci_valid;
    input ci_ready;
    input ci_addr;
    input dt_valid;
    input dt_ready;
    input tx_snp_op;
    input tx_snp_addr;
    input dr_valid;
    input dr_ready;
    input rx_snp_data;
    input rx_snp_rsp;
    input ur_valid;
    input ur_ready;
    input rx_snp_op;
    input rx_snp_addr;
    input ut_valid;
    input ut_ready;
    input tx_snp_data;
    input tx_snp_rsp;
  endclocking: mon_cb

  // ----------------------------------------------------------------
  clocking drv_cb @(posedge clk);
    default input #(input_skew) output #(output_skew);
    input   rst_n;
    output  cr_valid;
    input   cr_ready;
    output  rx_l1_op;
    output  rx_l1_addr;
    output  rx_l1_data;
    input   ct_valid;
    output  ct_ready;
    input   tx_l1_wait;
    input   tx_l1_data;
    input   ci_valid;
    output  ci_ready;
    input   ci_addr;
    input   dt_valid;
    output  dt_ready;
    input   tx_snp_op;
    input   tx_snp_addr;
    output  dr_valid;
    input   dr_ready;
    output  rx_snp_data;
    output  rx_snp_rsp;
    output  ur_valid;
    input   ur_ready;
    output  rx_snp_op;
    output  rx_snp_addr;
    input   ut_valid;
    output  ut_ready;
    input   tx_snp_data;
    input   tx_snp_rsp;
  endclocking: drv_cb

  // ----------------------------------------------------------------
  modport mon_mp (clocking mon_cb);
  modport drv_mp (clocking drv_cb);

endinterface: cache_if
