`ifndef CACHE_DEF_V
`define CACHE_DEF_V

// ------------------------------------------------------------------
// Cache state MESI protocol (one-hot FSM style)
// ------------------------------------------------------------------
//`define INVALID   0 // 4'b0001
//`define EXCLUSIVE 1 // 4'b0010
//`define MODIFIED  2 // 4'b0100
//`define SHARED    3 // 4'b1000

`define INVALID   4'b0001 
`define EXCLUSIVE 4'b0010 
`define MODIFIED  4'b0100 
`define SHARED    4'b1000 

// ------------------------------------------------------------------
// Cache hit miss (one-hot FSM style)
// ------------------------------------------------------------------
//`define READ_HIT    0
//`define WRITE_HIT   1
//`define READ_MISS   2
//`define WRITE_MISS  3

`define READ_HIT    4'b0001
`define WRITE_HIT   4'b0010
`define READ_MISS   4'b0100
`define WRITE_MISS  4'b1000

// ------------------------------------------------------------------
// Cache generates requests on BUS
// ------------------------------------------------------------------
`define BUS_NO_REQ          2'b00
`define BUS_INVALIDATE_REQ  2'b01
`define BUS_RWITM_REQ       2'b10
`define BUS_READ_REQ        2'b11

// ------------------------------------------------------------------
// BUS response
// ------------------------------------------------------------------
`define BUS_NO_RSP          2'b00
`define BUS_SNOOP_FOUND_RSP 2'b01
`define BUS_FETCH_MEM_RSP   2'b10

// ------------------------------------------------------------------
// TAG partition of physiscal address
// ------------------------------------------------------------------
`define ADDR_OFFSET  OFFSET_WIDTH-1:0
`define ADDR_INDEX   (INDEX_WIDTH + OFFSET_WIDTH)-1:OFFSET_WIDTH
`define ADDR_TAG     ADDR_WIDTH-1:(INDEX_WIDTH + OFFSET_WIDTH)

// ------------------------------------------------------------------
// TAG partition of cache memory
// ------------------------------------------------------------------
`define STATE_WIDTH 3 //2:SHARED | 1:EXCLUSIVE/MODIFIED | 0: VALID
`define RAM_DATA    LINE_WIDTH-1:0
`define RAM_TAG     (TAG_WIDTH + LINE_WIDTH)-1:LINE_WIDTH
`define RAM_VALID   (TAG_WIDTH + LINE_WIDTH + 1)-1:(TAG_WIDTH + LINE_WIDTH)
`define RAM_STATE   RAM_WIDTH-1:(TAG_WIDTH + LINE_WIDTH)+1

`endif
