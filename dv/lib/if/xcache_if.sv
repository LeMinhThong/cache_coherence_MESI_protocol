`include "cache_vip_def.svh"

interface xcache_if #(
      LINE_WIDTH      = `VIP_LINE_WIDTH,
      NUM_CACHE_LINE  = `VIP_NUM_CACHE_LINE,
      ADDR_WIDTH      = `VIP_ADDR_WIDTH,
      DATA_WIDTH      = `VIP_DATA_WIDTH
) (
      input wire                    clk,
      input wire                    rst_n,

      input wire                    cpu2cac_rd,
      input wire                    cpu2cac_wr,
      input wire  [ADDR_WIDTH-1:0]  cpu2cac_addr,
      input wire  [DATA_WIDTH-1:0]  cpu2cac_data,

      input wire                    cac2cpu_wait,
      input wire  [DATA_WIDTH-1:0]  cac2cpu_data,

      input wire  [1:0]             bus2cac_bus_req,
      input wire  [1:0]             bus2cac_bus_rsp,
      input wire  [ADDR_WIDTH-$clog2(LINE_WIDTH/8)-1:0]  bus2cac_addr,
      input wire  [LINE_WIDTH-1:0]  bus2cac_data,

      input wire  [1:0]             cac2bus_bus_req,
      input wire  [1:0]             cac2bus_bus_rsp,
      input wire  [ADDR_WIDTH-$clog2(LINE_WIDTH/8)-1:0]  cac2bus_addr,
      input wire  [LINE_WIDTH-1:0]  cac2bus_data,

      input wire                    cac2bus_write_back
);

endinterface: xcache_if
