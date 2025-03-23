`ifndef CACHE_MEM_SV
`define CACHE_MEM_SV

`include "cache_rtl_def.sv"

module cache_mem #(
      parameter LINE_WIDTH      = 64*8,
      parameter NUM_CACHE_LINE  = 1024,
      parameter ADDR_WIDTH      = 64,
      parameter DATA_WIDTH      = 32
) (
      // System signals
      input   logic                   clk,
      input   logic                   rst_n,

      // Procelogic ssor side
      input   logic                   cpu2cac_rd,
      input   logic                   cpu2cac_wr,
      input   logic [ADDR_WIDTH-1:0]  cpu2cac_addr,
      input   logic [DATA_WIDTH-1:0]  cpu2cac_data,

      output  logic                   cac2cpu_wait,
      output  logic [DATA_WIDTH-1:0]  cac2cpu_data,

      // Bus slogic ide
      input   logic [1:0]             bus2cac_bus_req,
      input   logic [1:0]             bus2cac_bus_rsp,
      input   logic [ADDR_WIDTH-$clog2(LINE_WIDTH/8)-1:0]  bus2cac_addr,
      input   logic [LINE_WIDTH-1:0]  bus2cac_data,

      output  logic [1:0]             cac2bus_bus_req,
      output  logic [1:0]             cac2bus_bus_rsp,
      output  logic                   cac2bus_write_back,
      output  logic [ADDR_WIDTH-$clog2(LINE_WIDTH/8)-1:0]  cac2bus_addr,
      output  logic [LINE_WIDTH-1:0]  cac2bus_data
);

  // ----------------------------------------------------------------
  // FIXME
  // ----------------------------------------------------------------
  // merge write back into cac2bus_req
  // change port name
  //    cpu2cac_* --> cpu_rx_*
  //    cac2cpu_* --> cpu_tx_*
  //    bus2cac_* --> bus_rx_*
  //    cac2bus_* --> bus_tx_*

  // ----------------------------------------------------------------
  // Parameter
  // ----------------------------------------------------------------
  // TAG structure
  localparam  OFFSET_WIDTH  = $clog2(LINE_WIDTH/2),
              INDEX_WIDTH   = $clog2(NUM_CACHE_LINE),
              TAG_WIDTH     = ADDR_WIDTH-INDEX_WIDTH-OFFSET_WIDTH;

  // ----------------------------------------------------------------
  // Cache memory
  // ----------------------------------------------------------------
  // |          --  Cache RAM width --
  // |State   |Tag                |Data          |
  // |~3bits  |TAG_WIDTH          |LINE_WIDTH   0|
  localparam  CAC_RAM_WIDTH = `STATE_WIDTH + TAG_WIDTH + LINE_WIDTH;

  logic [CAC_RAM_WIDTH-1:0] cac_mem [0:NUM_CACHE_LINE-1];

  // ----------------------------------------------------------------
  // Definitioin
  // ----------------------------------------------------------------
  logic [2:0] cpu_req_cac_cur_state = cac_mem[cpu2cac_addr[`ADDR_INDEX]][`CAC_STATE];
  logic [2:0] bus_req_cac_cur_state = cac_mem[bus2cac_addr[`ADDR_INDEX]][`CAC_STATE];
  logic [2:0] cpu_req_cac_nxt_state;
  logic [2:0] bus_req_cac_nxt_state;

  logic cpu_req_write_back;
  logic bus_req_write_back;

  // ----------------------------------------------------------------
  // Determine CPU request hit or miss
  // ----------------------------------------------------------------
  logic is_cpu_wr   = (cpu2cac_wr && ~cpu2cac_rd);
  logic is_cpu_rd   = (~cpu2cac_wr && cpu2cac_rd);
  logic is_cpu_req  = is_cpu_wr || is_cpu_rd;

  logic is_line_valid = cac_mem[cpu2cac_addr[`ADDR_INDEX]][`CAC_VALID];
  logic is_tag_match  = (cpu2cac_addr[`ADDR_TAG] == cac_mem[cpu2cac_addr[`ADDR_INDEX]][`CAC_TAG]) ? 1'b1 : 1'b0;

  logic wr_hit  = is_cpu_wr && is_line_valid && is_tag_match;
  logic rd_hit  = is_cpu_rd && is_line_valid && is_tag_match;
  logic wr_miss = is_cpu_wr && (!is_line_valid || !is_tag_match);
  logic rd_miss = is_cpu_rd && (!is_line_valid || !is_tag_match);

  // ----------------------------------------------------------------
  // Determine Snoop match
  // ----------------------------------------------------------------
  logic bus_req_match = (cac_mem[bus2cac_addr[`ADDR_INDEX]][`CAC_VALID] == 1'b1)
                        && (bus2cac_addr[`ADDR_TAG] == cac_mem[bus2cac_addr[`ADDR_INDEX]][`CAC_TAG]);

  // ----------------------------------------------------------------
  // Internal port
  // ----------------------------------------------------------------
  // CPU side
  logic       _cac2cpu_wait;
  // Bus side
  logic [1:0] _cac2bus_bus_rsp;
  logic [1:0] _cac2bus_bus_req;

  // ----------------------------------------------------------------
  // CPU side output
  // ----------------------------------------------------------------
  assign cac2cpu_wait = _cac2cpu_wait;
  assign cac2cpu_data = cac_mem[cpu2cac_addr[`ADDR_INDEX]][`CAC_DATA];

  // ----------------------------------------------------------------
  // BUS side output
  // ----------------------------------------------------------------
  assign cac2bus_bus_req = _cac2bus_bus_req;
  assign cac2bus_bus_rsp = (bus_req_match == 1'b1) ? _cac2bus_bus_rsp : `BUS_NO_RSP;
  assign cac2bus_write_back = cpu_req_write_back || bus_req_write_back;
  assign cac2bus_addr = ((bus_req_write_back == 1'b1) || (cac2bus_bus_rsp == `BUS_SNOOP_FOUND_RSP)) ? bus2cac_addr[`ADDR_CAC_ADDR] : cpu2cac_addr[`ADDR_CAC_ADDR];
  assign cac2bus_data = cac_mem[bus2cac_addr[`ADDR_INDEX]][`CAC_DATA];

  // ----------------------------------------------------------------
  // CPU request controller
  // ----------------------------------------------------------------
  fsm_cpu_req_ctrl cpu_req_crtl (
        .cur_state    (cpu_req_cac_cur_state),
        .cpu_wr_hit   (wr_hit               ),
        .cpu_rd_hit   (rd_hit               ),
        .cpu_wr_miss  (wr_miss              ),
        .cpu_rd_miss  (rd_miss              ),
        .bus_rsp      (bus2cac_bus_rsp      ),

        .nxt_state    (cpu_req_cac_nxt_state),
        .cpu_wait     (_cac2cpu_wait        ),
        .write_back   (cpu_req_write_back   ),
        .send_bus_req (_cac2bus_bus_req     )
  );

  // ----------------------------------------------------------------
  // Snoop request controller
  // ----------------------------------------------------------------
  fsm_bus_req_ctrl bus_req_crtl (
        .cur_state    (bus_req_cac_cur_state),
        .bus_req      (bus2cac_bus_req      ),

        .nxt_state    (bus_req_cac_nxt_state),
        .write_back   (bus_req_write_back   ),
        .send_bus_rsp (_cac2bus_bus_rsp     )
  );

  // ----------------------------------------------------------------
  // Update cache state when CPU send request or Snoop match 
  // ----------------------------------------------------------------
  always_ff @(posedge clk) begin
    if(!rst_n) begin
      for(int i = 0; i < NUM_CACHE_LINE; i++) begin
        cac_mem[i][`CAC_STATE] <= `INVALID;
      end
    end else begin
      if(is_cpu_req)
        cac_mem[cpu2cac_addr[`ADDR_INDEX]][`CAC_STATE] <= cpu_req_cac_nxt_state;
      else if(bus_req_match)
        cac_mem[bus2cac_addr[`ADDR_INDEX]][`CAC_STATE] <= bus_req_cac_nxt_state;
    end
  end

  // ----------------------------------------------------------------
  // Update Tag when CPU request miss
  // ----------------------------------------------------------------
  logic bus_return_data = (bus2cac_bus_rsp == `BUS_SNOOP_FOUND_RSP) || (bus2cac_bus_rsp == `BUS_FETCH_MEM_RSP);

  always_ff @(posedge clk) begin
    if(!rst_n) begin
      for(int i = 0; i < NUM_CACHE_LINE; i++) begin
        cac_mem[i][`CAC_TAG] <= {TAG_WIDTH{1'b0}};
      end
    end else begin
      if(bus_return_data)
        cac_mem[cpu2cac_addr[`ADDR_INDEX]][`CAC_TAG] <= cpu2cac_addr[`ADDR_TAG];
    end
  end

  // ----------------------------------------------------------------
  // Update data
  // ----------------------------------------------------------------
  always_ff @(posedge clk) begin
    if(!rst_n) begin
      for(int i = 0; i < NUM_CACHE_LINE; i++) begin
        cac_mem[i][`CAC_DATA] <= {LINE_WIDTH{1'b0}};
      end
    end else begin
      if(wr_hit)
        cac_mem[cpu2cac_addr[`ADDR_INDEX]][`CAC_DATA] <= cpu2cac_data;
      else if(bus_return_data)
        cac_mem[cpu2cac_addr[`ADDR_INDEX]][`CAC_DATA] <= bus2cac_data;
    end
  end
endmodule // cache_mem

`endif
