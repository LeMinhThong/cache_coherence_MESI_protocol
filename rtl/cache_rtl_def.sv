`ifndef CACHE_DEF_SV
`define CACHE_DEF_SV

// ------------------------------------------------------------------
// Cache state MESI protocol
// ------------------------------------------------------------------
`define STATE_WIDTH 3 // 2:SHARED | 1:EXCLUSIVE/MODIFIED | 0: VALID
`define INVALID     3'b000
`define EXCLUSIVE   3'b001
`define MODIFIED    3'b011
`define SHARED      3'b101

// ------------------------------------------------------------------
// Cache hit miss
// ------------------------------------------------------------------
//`define READ_HIT    0
//`define WRITE_HIT   1
//`define READ_MISS   2
//`define WRITE_MISS  3

//`define READ_HIT    4'b0001
//`define WRITE_HIT   4'b0010
//`define READ_MISS   4'b0100
//`define WRITE_MISS  4'b1000

// ------------------------------------------------------------------
// Cache generates requests on BUS
// ------------------------------------------------------------------
`define BUS_NO_REQ          2'b00
`define BUS_INVALIDATE_REQ  2'b01
`define BUS_RWITM_REQ       2'b10
`define BUS_READ_REQ        2'b11
//define BUS_WRITE_BACK       3'b100

// ------------------------------------------------------------------
// BUS response
// ------------------------------------------------------------------
`define BUS_NO_RSP          2'b00
`define BUS_SNOOP_FOUND_RSP 2'b01
`define BUS_FETCH_MEM_RSP   2'b10

// ------------------------------------------------------------------
// TAG partition of physiscal address
// ------------------------------------------------------------------
`define ADDR_OFFSET   OFFSET_WIDTH-1:0
`define ADDR_INDEX    (INDEX_WIDTH + OFFSET_WIDTH)-1:OFFSET_WIDTH
`define ADDR_TAG      ADDR_WIDTH-1:(INDEX_WIDTH + OFFSET_WIDTH)
`define ADDR_CAC_ADDR ADDR_WIDTH-1:OFFSET_WIDTH

// ------------------------------------------------------------------
// TAG partition of cache memory
// ------------------------------------------------------------------
`define CAC_DATA    LINE_WIDTH-1:0
`define CAC_TAG     (TAG_WIDTH + LINE_WIDTH)-1:LINE_WIDTH
`define CAC_VALID   (TAG_WIDTH + LINE_WIDTH + 1)-1:(TAG_WIDTH + LINE_WIDTH)
`define CAC_STATE   CAC_RAM_WIDTH-1:(TAG_WIDTH + LINE_WIDTH)+1

`endif
