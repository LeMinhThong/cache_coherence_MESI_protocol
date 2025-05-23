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

// ------------------------------------------------------------------
// print log
// ------------------------------------------------------------------
`define rtl_print(addr, message) \
  $display("%0t ns: [0x%0h] %s", $time, addr, message);

`define rtl_print_if_dff(var_1, var_2, addr, message) \
  begin \
    if(var_1 != var_2) \
      $display("%0tns: RTL_INTER [Set=0x%0h] %s: 0x%0h --> 0x%0h", $time, addr, message, var_1, var_2); \
  end
`endif
