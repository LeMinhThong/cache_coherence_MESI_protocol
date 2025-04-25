`ifndef CACHE_TEST_PKG_SV
`define CACHE_TEST_PKG_SV

package cache_test_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh";

  import cache_vip_pkg::*;

  // Seqs
  `include "cache_base_seq.sv"

  // Test
  `include "cache_base_test.sv";
endpackage

`endif
