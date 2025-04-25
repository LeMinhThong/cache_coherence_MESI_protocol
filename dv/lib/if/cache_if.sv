`include "cache_vip_def.svh"

// if have changes on interface, then have to adjust these files:
  // cache_if.sv
  // xcache_if.sv
  // cache_tb_top.sv
  // cache_driver.sv

interface cache_if #(
      PADDR_WIDTH = `VIP_PADDR_WIDTH,
      BLK_WIDTH   = `VIP_BLK_WIDTH,
      NUM_BLK     = `VIP_NUM_BLK,

      SADDR_WIDTH = PADDR_WIDTH-$clog2(BLK_WIDTH/8)
) (
      input wire                    clk,
      input wire                    rst_n,

      inout wire [1:0]              rx_l1_op,
      inout wire [SADDR_WIDTH-1:0]  rx_l1_addr,
      inout wire [BLK_WIDTH-1:0]    rx_l1_data,

      inout wire                    tx_l1_wait,
      inout wire [BLK_WIDTH-1:0]    tx_l1_data,

      inout wire [2:0]              rx_snp_op,
      inout wire [SADDR_WIDTH-1:0]  rx_snp_addr,
      inout wire [BLK_WIDTH-1:0]    rx_snp_data,
      inout wire [1:0]              rx_snp_rsp,

      inout wire [2:0]              tx_snp_op,
      inout wire [SADDR_WIDTH-1:0]  tx_snp_addr,
      inout wire [BLK_WIDTH-1:0]    tx_snp_data,
      inout wire [1:0]              tx_snp_rsp
);

  time input_skew   = 0ps;
  time output_skew  = 10ps;

  // ----------------------------------------------------------------
  clocking mon_cb @(negedge clk);
    default input #(input_skew) output #(output_skew);
    input rst_n;

    input rx_l1_op;
    input rx_l1_addr;
    input rx_l1_data;

    input tx_l1_wait;
    input tx_l1_data;

    input rx_snp_op;
    input rx_snp_addr;
    input rx_snp_data;
    input rx_snp_rsp;

    input tx_snp_op;
    input tx_snp_addr;
    input tx_snp_data;
    input tx_snp_rsp;
  endclocking: mon_cb

  // ----------------------------------------------------------------
  clocking drv_cb @(posedge clk);
    default input #(input_skew) output #(output_skew);
    input   rst_n;

    output  rx_l1_op;
    output  rx_l1_addr;
    output  rx_l1_data;

    input   tx_l1_wait;
    input   tx_l1_data;

    output  rx_snp_op;
    output  rx_snp_addr;
    output  rx_snp_data;
    output  rx_snp_rsp;

    input   tx_snp_op;
    input   tx_snp_addr;
    input   tx_snp_data;
    input   tx_snp_rsp;
  endclocking: drv_cb

  // ----------------------------------------------------------------
  modport mon_mp (clocking mon_cb);
  modport drv_mp (clocking drv_cb);

endinterface: cache_if
