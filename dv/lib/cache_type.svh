`ifndef CACHE_TYPE_SVH
`define CACHE_TYPE_SVH

typedef reg [`VIP_SADDR_WIDTH-1:0] address_t;

typedef reg [`VIP_BLK_WIDTH-1:0] data_t;

typedef enum {
  L1_REQ  = 0,
  SNP_REQ = 1
} type_e;

typedef enum reg [2:0] {
  INVALID   = 3'b000,
  EXCLUSIVE = 3'b001,
  MODIFIED  = 3'b011,
  SHARED    = 3'b101
} st_e;

typedef enum reg [2:0] {
  CDR_RD  = 3'b000,
  CDR_RFO = 3'b001,
  CDR_WB  = 3'b010,
  CDR_MD  = 3'b011
} cdr_e;

typedef enum reg [1:0] {
  CDT_OKAY  = 2'b00,
  CDT_ERROR = 2'b01
} cdt_e;

typedef enum reg [1:0] {
  CUT_RD    = 2'b00,
  CUT_INV   = 2'b01,
  CUT_RDINV = 2'b10
} cut_e;

typedef enum reg [1:0] {
  CUR_OKAY  = 2'b00,
  CUR_ERROR = 2'b01
} cur_e;

typedef enum reg [2:0] {
  SDT_RD  = 3'b000,
  SDT_RFO = 3'b001,
  SDT_INV = 3'b010,
  SDT_WB  = 3'b011
} sdt_e;

typedef enum reg [2:0] {
  SDR_OKAY  = 3'b000,
  SDR_FETCH = 3'b001,
  SDR_SNOOP = 3'b010,
  SDR_ERROR = 3'b011
} sdr_e;

typedef enum reg [1:0] {
  SUR_RD    = 2'b00,
  SUR_RFO   = 2'b01,
  SUR_INV   = 2'b10
} sur_e;

typedef enum reg [1:0] {
  SUT_OKAY     = 2'b00,
  SUT_INVALID  = 2'b01,
  SUT_ERROR    = 2'b10
} sut_e;

`endif
