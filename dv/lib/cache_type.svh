`ifndef CACHE_TYPE_SVH
`define CACHE_TYPE_SVH

typedef bit [`VIP_SADDR_WIDTH-1:0] address_t;

typedef bit [`VIP_BLK_WIDTH-1:0] data_t;

typedef enum bit [2:0] {
  INVALID   = 3'b000,
  EXCLUSIVE = 3'b001,
  MODIFIED  = 3'b011,
  SHARED    = 3'b101
} st_e;

typedef enum bit [1:0] {
  L1_NO_REQ = 2'b00,
  L1_RD     = 2'b01,
  L1_WR     = 2'b10
} l1_op_e;

typedef enum bit [2:0] {
  SNP_NO_REQ  = 3'b000,
  SNP_INV     = 3'b001,
  SNP_RWITM   = 3'b010,
  SNP_RD      = 3'b011,
  SNP_WB      = 3'b100
} snp_op_e;

typedef enum bit [1:0] {
  SNP_NO_RSP  = 2'b00,
  SNP_FOUND   = 2'b01,
  SNP_FETCH   = 2'b10
} snp_rsp_e;

`endif
