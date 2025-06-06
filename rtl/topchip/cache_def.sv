`ifndef CACHE_DEF_SV
`define CACHE_DEF_SV

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
