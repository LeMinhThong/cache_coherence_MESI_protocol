`ifndef CACHE_PKG_SV
`define CACHE_PKG_SV

package cache_pkg;
  // ----------------------------------------------------------------
  // MESI cache states
  // ----------------------------------------------------------------
  // 2:SHARED | 1:EXCLUSIVE/MODIFIED | 0: VALID
  parameter INVALID   = 3'b000;
  parameter EXCLUSIVE = 3'b001;
  parameter MODIFIED  = 3'b011;
  parameter SHARED    = 3'b101;
  //parameter OWNED     = 3'b111;

  // ----------------------------------------------------------------
  // request status
  // ----------------------------------------------------------------
  parameter READ_HIT   = 0;
  parameter WRITE_HIT  = 1;
  parameter READ_MISS  = 2;
  parameter WRITE_MISS = 3;

  // ----------------------------------------------------------------
  // downstream cache request processing states
  // ----------------------------------------------------------------
  parameter REQ_IDLE        = 3'b000;
  parameter REQ_ALLOCATE    = 3'b001;
  parameter REQ_INIT_SDREQ  = 3'b010;
  parameter REQ_WAIT_SURSP  = 3'b011;
  parameter REQ_RSP_CURSP   = 3'b100;

  // ----------------------------------------------------------------
  // cdreq_op encode
  // ----------------------------------------------------------------
  parameter CDREQ_RD  = 3'b000;
  parameter CDREQ_RFO = 3'b001;
  parameter CDREQ_WB  = 3'b010;
  parameter CDREQ_MD  = 3'b011;
  
  // ----------------------------------------------------------------
  // cursp_rsp encode
  // ----------------------------------------------------------------
  parameter CURSP_OKAY  = 2'b00;
  parameter CURSP_ERROR = 2'b01;
  
  // ----------------------------------------------------------------
  // cureq_op encode
  // ----------------------------------------------------------------
  parameter CUREQ_RD    = 2'b00;
  parameter CUREQ_INV   = 2'b01;
  parameter CUREQ_RDINV = 2'b10;
  
  // ----------------------------------------------------------------
  // cdrsp_rsp encode
  // ----------------------------------------------------------------
  parameter CDRSP_OKAY  = 2'b00;
  parameter CDRSP_ERROR = 2'b01;
  
  // ----------------------------------------------------------------
  // sdreq_op encode
  // ----------------------------------------------------------------
  parameter SDREQ_RD  = 3'b000;
  parameter SDREQ_RFO = 3'b001;
  parameter SDREQ_INV = 3'b010;
  parameter SDREQ_WB  = 3'b011;
  
  // ----------------------------------------------------------------
  // sursp_rsp encode
  // ----------------------------------------------------------------
  parameter SURSP_OKAY  = 3'b000;
  parameter SURSP_FETCH = 3'b001;
  parameter SURSP_SNOOP = 3'b010;
  parameter SURSP_ERROR = 3'b011;
  
  // ----------------------------------------------------------------
  // sureq_op encode
  // ----------------------------------------------------------------
  parameter SUREQ_RD  = 2'b00;
  parameter SUREQ_RFO = 2'b01;
  parameter SUREQ_INV = 2'b10;
  
  // ----------------------------------------------------------------
  // sdrsp_rsp encode
  // ----------------------------------------------------------------
  parameter SDRSP_OKAY  = 2'b00;
  parameter SDRSP_INV   = 2'b01;
  parameter SDRSP_ERROR = 2'b10;
endpackage: cache_pkg

`endif
