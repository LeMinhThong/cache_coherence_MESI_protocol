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
// cdr_op encode
// ------------------------------------------------------------------
`define CDR_RD    3'b000
`define CDR_RFO   3'b001
`define CDR_WB    3'b010
`define CDR_MD    3'b011

// ------------------------------------------------------------------
// cdt_rsp encode
// ------------------------------------------------------------------
`define CDT_OKAY  2'b00
`define CDT_ERROR 2'b01

// ------------------------------------------------------------------
// cut_op encode
// ------------------------------------------------------------------
`define CUT_RD    2'b00
`define CUT_INV   2'b01
`define CUT_RDINV 2'b10

// ------------------------------------------------------------------
// cur_rsp encode
// ------------------------------------------------------------------
`define CUR_OKAY  2'b00
`define CUR_ERROR 2'b01

// ------------------------------------------------------------------
// sdt_op encode
// ------------------------------------------------------------------
`define SDT_RD    3'b000
`define SDT_RFO   3'b001
`define SDT_INV   3'b010
`define SDT_WB    3'b011

// ------------------------------------------------------------------
// sdr_rsp encode
// ------------------------------------------------------------------
`define SDR_OKAY  3'b000
`define SDR_FETCH 3'b001
`define SDR_SNOOP 3'b010
`define SDR_ERROR 3'b011

// ------------------------------------------------------------------
// sur_op encode
// ------------------------------------------------------------------
`define SUR_RD    2'b00
`define SUR_RFO   2'b01
`define SUR_INV   2'b10

// ------------------------------------------------------------------
// sut_rsp encode
// ------------------------------------------------------------------
`define SUT_OKAY  2'b00
`define SUT_INV   2'b01
`define SUT_ERROR 2'b10

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
