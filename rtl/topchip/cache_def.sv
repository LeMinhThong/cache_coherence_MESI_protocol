`ifndef CACHE_DEF_SV
`define CACHE_DEF_SV

// ------------------------------------------------------------------
// Cache state MESI protocol
// ------------------------------------------------------------------
// 2:SHARED | 1:EXCLUSIVE/MODIFIED | 0: VALID
`define INVALID     3'b000
`define EXCLUSIVE   3'b001
`define MODIFIED    3'b011
`define SHARED      3'b101

// ------------------------------------------------------------------
// cdreq_op encode
// ------------------------------------------------------------------
`define CDREQ_RD    3'b000
`define CDREQ_RFO   3'b001
`define CDREQ_WB    3'b010
`define CDREQ_MD    3'b011

// ------------------------------------------------------------------
// cursp_rsp encode
// ------------------------------------------------------------------
`define CURSP_OKAY  2'b00
`define CURSP_ERROR 2'b01

// ------------------------------------------------------------------
// cureq_op encode
// ------------------------------------------------------------------
`define CUREQ_RD    2'b00
`define CUREQ_INV   2'b01
`define CUREQ_RDINV 2'b10

// ------------------------------------------------------------------
// cdrsp_rsp encode
// ------------------------------------------------------------------
`define CDRSP_OKAY  2'b00
`define CDRSP_ERROR 2'b01

// ------------------------------------------------------------------
// sdreq_op encode
// ------------------------------------------------------------------
`define SDREQ_RD    3'b000
`define SDREQ_RFO   3'b001
`define SDREQ_INV   3'b010
`define SDREQ_WB    3'b011

// ------------------------------------------------------------------
// sursp_rsp encode
// ------------------------------------------------------------------
`define SURSP_OKAY  3'b000
`define SURSP_FETCH 3'b001
`define SURSP_SNOOP 3'b010
`define SURSP_ERROR 3'b011

// ------------------------------------------------------------------
// sureq_op encode
// ------------------------------------------------------------------
`define SUREQ_RD    2'b00
`define SUREQ_RFO   2'b01
`define SUREQ_INV   2'b10

// ------------------------------------------------------------------
// sdrsp_rsp encode
// ------------------------------------------------------------------
`define SDRSP_OKAY  2'b00
`define SDRSP_INV   2'b01
`define SDRSP_ERROR 2'b10

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
