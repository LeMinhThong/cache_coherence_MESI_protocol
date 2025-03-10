`ifndef CACHE_MEM_V
`define CACHE_MEM_V

`include "cache_def.v"

module cache_mem #(
      parameter LINE_WIDTH      = 64*8,
      parameter NUM_CACHE_LINE  = 1024,
      parameter ADDR_WIDTH      = 64,
      parameter DATA_WIDTH      = 32
) (
      // System signals
      input                     clk,
      input                     rst_n,

      // Processor side
      input                     cpu2cac_rd,
      input                     cpu2cac_wr,
      input   [ADDR_WIDTH-1:0]  cpu2cac_addr,
      input   [DATA_WIDTH-1:0]  cpu2cac_data,

      output                    cac2cpu_wait,
      output  [DATA_WIDTH-1:0]  cac2cpu_data,

      // Bus side
      input   [1:0]             bus2cac_bus_req,
      input   [1:0]             bus2cac_bus_rsp,
      input   [ADDR_WIDTH-$clog2(LINE_WIDTH/8)-1:0]  bus2cac_addr,
      input   [LINE_WIDTH-1:0]  bus2cac_data,

      output  [1:0]             cac2bus_bus_req,
      output  [1:0]             cac2bus_bus_rsp,
      output  [ADDR_WIDTH-$clog2(LINE_WIDTH/8)-1:0]  cac2bus_addr,
      output  [LINE_WIDTH-1:0]  cac2bus_data,

      output                    cac2bus_write_back
);

  // ----------------------------------------------------------------
  // Parameter
  // ----------------------------------------------------------------
  // TAG structure
  localparam  OFFSET_WIDTH  = $clog2(LINE_WIDTH/2),
              INDEX_WIDTH   = $clog2(NUM_CACHE_LINE/4), // 4-way set associative
              TAG_WIDTH     = ADDR_WIDTH-INDEX_WIDTH-OFFSET_WIDTH;

  localparam  RAM_WIDTH     = `STATE_WIDTH + TAG_WIDTH + LINE_WIDTH;

  // ----------------------------------------------------------------
  // TAG RAM & DATA RAM register definition
  // ----------------------------------------------------------------
  reg [RAM_WIDTH-1:0] cac_mem [0:NUM_CACHE_LINE-1];

  // ----------------------------------------------------------------
  //
  // ----------------------------------------------------------------
  wire cpu_req_cac_state = cac_mem[cpu2cac_addr[`ADDR_OFFSET]][`RAM_STATE];

  wire is_cpu_wr      = (cpu2cac_wr && ~cpu2cac_rd) ? 1'b1 : 1'b0;
  wire is_line_valid  = cac_mem[cpu2cac_addr[`ADDR_OFFSET]][`RAM_VALID] ? 1'b1 : 1'b0;
  wire is_tag_match   = (cpu2cac_addr[`ADDR_TAG] == cac_mem[cpu2cac_addr[`ADDR_OFFSET]][`RAM_TAG]) ? 1'b1 : 1'b0;

  assign wr_hit   = is_cpu_wr && is_line_valid && is_tag_match;
  assign rd_hit   = !is_cpu_wr && is_line_valid && is_tag_match;
  assign wr_miss  = is_cpu_wr && (!is_line_valid || !is_tag_match);
  assign rd_miss  = !is_cpu_wr && (!is_line_valid || !is_tag_match);

  // ----------------------------------------------------------------
  // BUS side controller
  // ----------------------------------------------------------------
  assign cac2bus_addr = cpu2cac_addr[ADDR_WIDTH-1:OFFSET_WIDTH];

  // ----------------------------------------------------------------
  // Instances
  // ----------------------------------------------------------------
  fsm_cpu_req_ctrl cpu_req_crtl (
        .cur_state    (cpu_req_cac_state  ),
        .cpu_wr_hit   (wr_hit             ),
        .cpu_rd_hit   (rd_hit             ),
        .cpu_wr_miss  (wr_miss            ),
        .cpu_rd_miss  (rd_miss            ),
        .bus_rsp      (bus2cac_bus_rsp    ),

        .nxt_state    (),
        .cpu_wait     (cac2cpu_wait       ),
        .write_back   (cac2bus_write_back ),
        .send_bus_req (cac2bus_bus_req    )
  );

  fsm_bus_req_ctrl bus_req_crtl (
        .cur_state    (),
        .bus_req      (),

        .nxt_state    (),
        .write_back   (),
        .send_bus_rsp ()
  );
endmodule // cache_mem

`endif
