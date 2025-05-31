`ifndef CACHE_VIP_DEF_SVH
`define CACHE_VIP_DEF_SVH

`define VIP_PADDR_WIDTH 64
`define VIP_BLK_WIDTH   512
`define VIP_NUM_BLK     1024
`define VIP_ST_WIDTH    3

`define VIP_SADDR_WIDTH `VIP_PADDR_WIDTH-$clog2(`VIP_BLK_WIDTH/8)
`define VIP_IDX_WIDTH   $clog2(`VIP_NUM_BLK)
`define VIP_TAG_WIDTH   `VIP_SADDR_WIDTH - `VIP_IDX_WIDTH
`define VIP_RAM_WIDTH   `VIP_ST_WIDTH + `VIP_TAG_WIDTH + `VIP_BLK_WIDTH

`define IDX             `VIP_IDX_WIDTH-1:0
`define ADDR_TAG        `VIP_SADDR_WIDTH-1:`VIP_IDX_WIDTH

`define DAT     `VIP_BLK_WIDTH-1:0
`define RAM_TAG (`VIP_TAG_WIDTH + `VIP_BLK_WIDTH)-1:`VIP_BLK_WIDTH
`define ST      `VIP_RAM_WIDTH-1:(`VIP_TAG_WIDTH + `VIP_BLK_WIDTH)

`define SB_ERROR(type_req, message) \
  begin \
    `uvm_error($sformatf("%s_ERROR", type_req), message) \
    if(type_req == "CDREQ")       cdreq_error_count++; \
    else if(type_req == "SUREQ")  sureq_error_count++; \
    else if(type_req == "ALL")    ; \
    else                          `uvm_fatal(m_msg_name, $sformatf("can not identify request type:%s", type_req)) \
  end
`endif
