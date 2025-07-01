`ifndef CACHE_TEST_PKG_SV
`define CACHE_TEST_PKG_SV

package cache_tests_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import cache_units_pkg::*;

  // Test
  `include "cache_base_test.svh"
  `include "rd_wr_test.svh"
  `include "mesi_test.svh"
  `include "repl_test.svh"
  `include "corner_test.svh"
  `include "rand_test.svh"
endpackage

`endif
