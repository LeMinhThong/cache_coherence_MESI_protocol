`ifndef CACHE_TYPE_SVH
`define CACHE_TYPE_SVH

typedef reg [`VIP_SADDR_WIDTH-1:0] address_t;

typedef reg [`VIP_BLK_WIDTH-1:0] data_t;

typedef enum {
  L1_REQ  = 0,
  SNP_REQ = 1
} type_e;

typedef enum {
  CDREQ_XFR = 0,
  CURSP_XFR = 1,
  CUREQ_XFR = 2,
  CDRSP_XFR = 3,
  SDREQ_XFR = 4,
  SURSP_XFR = 5,
  SUREQ_XFR = 6,
  SDRSP_XFR = 7,
  ALL_CH    = 8
} xfr_e;

typedef enum reg [2:0] {
  INVALID   = 3'b000,
  EXCLUSIVE = 3'b001,
  MODIFIED  = 3'b011,
  SHARED    = 3'b101
} st_e;

typedef enum reg [2:0] {
  CDREQ_RD  = 3'b000,
  CDREQ_RFO = 3'b001,
  CDREQ_WB  = 3'b010,
  CDREQ_MD  = 3'b011
} cdreq_e;

typedef enum reg [1:0] {
  CURSP_OKAY  = 2'b00,
  CURSP_ERROR = 2'b01
} cursp_e;

typedef enum reg [1:0] {
  CUREQ_RD  = 2'b00,
  CUREQ_RFO = 2'b01,
  CUREQ_INV = 2'b10
} cureq_e;

typedef enum reg [1:0] {
  CDRSP_OKAY  = 2'b00,
  CDRSP_ERROR = 2'b01
} cdrsp_e;

typedef enum reg [2:0] {
  SDREQ_RD  = 3'b000,
  SDREQ_RFO = 3'b001,
  SDREQ_INV = 3'b010,
  SDREQ_WB  = 3'b011
} sdreq_e;

typedef enum reg [2:0] {
  SURSP_OKAY  = 3'b000,
  SURSP_FETCH = 3'b001,
  SURSP_SNOOP = 3'b010,
  SURSP_ERROR = 3'b011
} sursp_e;

typedef enum reg [1:0] {
  SUREQ_RD    = 2'b00,
  SUREQ_RFO   = 2'b01,
  SUREQ_INV   = 2'b10
} sureq_e;

typedef enum reg [1:0] {
  SDRSP_OKAY     = 2'b00,
  SDRSP_INVALID  = 2'b01,
  SDRSP_ERROR    = 2'b10
} sdrsp_e;

`endif
