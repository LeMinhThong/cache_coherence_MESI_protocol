`ifndef CACHE_PKG_SV
`define CACHE_PKG_SV

package cache_pkg;
  parameter REQ_IDLE          = 3'b000;
  parameter REQ_ALLOCATE      = 3'b001;
  parameter REQ_INIT_SDREQ    = 3'b010;
  parameter REQ_WAIT_SNP_RSP  = 3'b011;
  parameter REQ_RSP_CURSP     = 3'b100;
endpackage: cache_pkg

`endif
