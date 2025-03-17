`ifndef CACHE_TEST_PKG_SVH
`define CACHE_TEST_PKG_SVH

package cache_test_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh";

  import cache_lib_pkg::*;

  // Seqs
  `include "cache_base_seq.sv"

  // Test
  `include "cache_base_test.sv";
endpackage

`endif
