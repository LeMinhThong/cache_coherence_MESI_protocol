`ifndef CACHE_LIB_PKG_SVH
`define CACHE_LIB_PKG_SVH

package cache_lib_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh";

  `include "cache_vip_def.svh"
  `include "cache_transaction.sv"

  // agent
  `include "cache_sequencer.sv";
  `include "cache_driver.sv";
  `include "cache_active_monitor.sv";
  `include "cache_passive_monitor.sv";
  `include "cache_active_agent.sv";
  `include "cache_passive_agent.sv";
  `include "cache_coverage.sv";
  `include "cache_env.sv";

endpackage

`endif
