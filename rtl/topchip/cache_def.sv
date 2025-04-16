`ifndef CACHE_DEF_SV
`define CACHE_DEF_SV

// ------------------------------------------------------------------
// Cache state MESI protocol
// ------------------------------------------------------------------
// STATE 2:SHARED | 1:EXCLUSIVE/MODIFIED | 0: VALID
`define INVALID     3'b000
`define EXCLUSIVE   3'b001
`define MODIFIED    3'b011
`define SHARED      3'b101

// ------------------------------------------------------------------
// Cache generates requests on Snooping Bus
// ------------------------------------------------------------------
`define SNP_NO_REQ  3'b000
`define SNP_INV     3'b001
`define SNP_RWITM   3'b010
`define SNP_RD      3'b011
`define SNP_WB      3'b100

// ------------------------------------------------------------------
// Snoop response
// ------------------------------------------------------------------
`define SNP_NO_RSP  2'b00
`define SNP_FOUND   2'b01
`define SNP_FETCH   2'b10

// ------------------------------------------------------------------
// partition of physiscal address
// ------------------------------------------------------------------
`define IDX       IDX_WIDTH-1:0
`define ADDR_TAG  SADDR_WIDTH-1:IDX_WIDTH

// ------------------------------------------------------------------
// partition of cache memory
// ------------------------------------------------------------------
`define DAT     BLK_WIDTH-1:0
`define RAM_TAG (TAG_WIDTH + BLK_WIDTH)-1:BLK_WIDTH
`define VALID   (TAG_WIDTH + BLK_WIDTH + 1)-1:(TAG_WIDTH + BLK_WIDTH)
`define ST      RAM_WIDTH-1:(TAG_WIDTH + BLK_WIDTH)

`endif
