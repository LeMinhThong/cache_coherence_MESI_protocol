`ifndef CACHE_MEM_V
`define CACHE_MEM_V
`define THIS_MODULE cache_mem

`define OFFSET_RANGE  OFFSET_WIDTH-1:0
`define SET_RANGE     SET_WIDTH+OFFSET_WIDTH-1:OFFSET_WIDTH
`define TAG_RANGE     ADDR_WIDTH-1:SET_WIDTH+OFFSET_WIDTH

module `THIS_MODULE #(
      parameter LINE_SIZE       = 64*8,
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

      output                    cac2cpu_hit,
      output                    cac2cpu_miss,
      output  [DATA_WIDTH-1:0]  cac2cpu_data,

      // Bus side
      input   [LINE_SIZE-1:0]   bus2cac_data,

      output                    cac2bus_rd,
      output                    cac2bus_wr,
      output  [ADDR_WIDTH-$clog2(LINE_SIZE/8)-1:0]  cac2bus_addr,
      output  [DATA_WIDTH-1:0]  cac2bus_data
);

  // ----------------------------------------------------------------
  // Parameter
  // Cache states (one-hot FSM style)
  localparam  INVALID   = 0,  // 4'b0001
              EXCLUSIVE = 1,  // 4'b0010
              MODIFIED  = 2,  // 4'b0100
              SHARED    = 3;  // 4'b1000

  // TAG structure
  localparam  OFFSET_WIDTH  = $clog2(LINE_SIZE/2),
              SET_WIDTH     = $clog2(NUM_CACHE_LINE/4), // 4-way set associative
              TAG_WIDTH     = ADDR_WIDTH-SET_WIDTH-OFFSET_WIDTH;

  // ----------------------------------------------------------------
  // TAG RAM & DATA RAM register definition
  // way 0
  reg                 valid_0 [0:(NUM_CACHE_LINE/4)-1];
  reg                 dirty_0 [0:(NUM_CACHE_LINE/4)-1];
  reg [TAG_WIDTH-1:0] tag_0   [0:(NUM_CACHE_LINE/4)-1];
  reg [LINE_SIZE-1:0] mem_0   [0:(NUM_CACHE_LINE/4)-1];

  // way 1
  reg                 valid_1 [0:(NUM_CACHE_LINE/4)-1];
  reg                 dirty_1 [0:(NUM_CACHE_LINE/4)-1];
  reg [TAG_WIDTH-1:0] tag_1   [0:(NUM_CACHE_LINE/4)-1];
  reg [LINE_SIZE-1:0] mem_1   [0:(NUM_CACHE_LINE/4)-1];

  // way 2
  reg                 valid_2 [0:(NUM_CACHE_LINE/4)-1];
  reg                 dirty_2 [0:(NUM_CACHE_LINE/4)-1];
  reg [TAG_WIDTH-1:0] tag_2   [0:(NUM_CACHE_LINE/4)-1];
  reg [LINE_SIZE-1:0] mem_2   [0:(NUM_CACHE_LINE/4)-1];

  // way 3
  reg                 valid_3 [0:(NUM_CACHE_LINE/4)-1];
  reg                 dirty_3 [0:(NUM_CACHE_LINE/4)-1];
  reg [TAG_WIDTH-1:0] tag_3   [0:(NUM_CACHE_LINE/4)-1];
  reg [LINE_SIZE-1:0] mem_3   [0:(NUM_CACHE_LINE/4)-1];

  // ----------------------------------------------------------------
  // BUS side controller
  assign cac2bus_addr = cpu2cac_addr[ADDR_WIDTH-1:OFFSET_WIDTH];

  // ----------------------------------------------------------------
  // FSM
  always @(posedge clk)
  begin
    if (!rst_n)
    begin
    end else
    begin
    end
  end

endmodule: `THIS_MODULE

`undef THIS_MODULE
`endif
