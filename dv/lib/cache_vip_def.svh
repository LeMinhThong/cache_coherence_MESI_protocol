`ifndef CACHE_VIP_DEF_SVH
`define CACHE_VIP_DEF_SVH

`define VIP_PADDR_WIDTH 64
`define VIP_BLK_WIDTH   512
`define VIP_NUM_BLK     1024

`define VIP_SADDR_WIDTH `VIP_PADDR_WIDTH-$clog2(`VIP_BLK_WIDTH/8)

`endif
