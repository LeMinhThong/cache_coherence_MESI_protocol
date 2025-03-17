`include "cache_vip_def.svh"

// if have changes on interface, then have to adjust these files:
  // cache_if.sv
  // xcache_if.sv
  // cache_tb_top.sv
  // cache_driver.sv

interface cache_if #(
      LINE_WIDTH      = `VIP_LINE_WIDTH,
      NUM_CACHE_LINE  = `VIP_NUM_CACHE_LINE,
      ADDR_WIDTH      = `VIP_ADDR_WIDTH,
      DATA_WIDTH      = `VIP_DATA_WIDTH
) (
      input wire                    clk,
      input wire                    rst_n,

      inout wire                    cpu2cac_rd,
      inout wire                    cpu2cac_wr,
      inout wire  [ADDR_WIDTH-1:0]  cpu2cac_addr,
      inout wire  [DATA_WIDTH-1:0]  cpu2cac_data,

      inout wire                    cac2cpu_wait,
      inout wire  [DATA_WIDTH-1:0]  cac2cpu_data,

      inout wire  [1:0]             bus2cac_bus_req,
      inout wire  [1:0]             bus2cac_bus_rsp,
      inout wire  [ADDR_WIDTH-$clog2(LINE_WIDTH/8)-1:0]  bus2cac_addr,
      inout wire  [LINE_WIDTH-1:0]  bus2cac_data,

      inout wire  [1:0]             cac2bus_bus_req,
      inout wire  [1:0]             cac2bus_bus_rsp,
      inout wire  [ADDR_WIDTH-$clog2(LINE_WIDTH/8)-1:0]  cac2bus_addr,
      inout wire  [LINE_WIDTH-1:0]  cac2bus_data,

      inout wire                    cac2bus_write_back
);

  clocking mon_cb @(negedge clk);
    default input #(0) output #(0);
    input rst_n;

    input cpu2cac_rd;
    input cpu2cac_wr;
    input cpu2cac_addr;
    input cpu2cac_data;

    input cac2cpu_wait;
    input cac2cpu_data;

    input bus2cac_bus_req;
    input bus2cac_bus_rsp;
    input bus2cac_addr;
    input bus2cac_data;

    input cac2bus_bus_req;
    input cac2bus_bus_rsp;
    input cac2bus_addr;
    input cac2bus_data;

    input cac2bus_write_back;
  endclocking: mon_cb

  // ----------------------------------------------------------------
  clocking req_drv_cb @(posedge clk);
    default input #(0) output #(0);
    input rst_n;

    output  cpu2cac_rd;
    output  cpu2cac_wr;
    output  cpu2cac_addr;
    output  cpu2cac_data;

    input   cac2cpu_wait;
    input   cac2cpu_data;

    output  bus2cac_bus_req;
    output  bus2cac_bus_rsp;
    output  bus2cac_addr;
    output  bus2cac_data;

    input   cac2bus_bus_req;
    input   cac2bus_bus_rsp;
    input   cac2bus_addr;
    input   cac2bus_data;

    input   cac2bus_write_back;
  endclocking: req_drv_cb

  // ----------------------------------------------------------------
  modport mon_mp (clocking mon_cb);
  modport req_drv_mp (clocking req_drv_cb);

endinterface: cache_if
