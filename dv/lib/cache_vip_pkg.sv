`ifndef CACHE_VIP_PKG_SV
`define CACHE_VIP_PKG_SV

package cache_vip_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "cache_vip_def.svh"
  `include "cache_type.svh"

  // agent
  `include "cache_txn.svh"
  `include "cache_seqr.svh"
  `include "cache_drv_bfm.svh"
  `include "cache_drv.svh"
  `include "cache_mon.svh"
  `include "cache_model.svh"
  `include "cache_sb.svh"
  `include "cache_agt.svh"
  `include "cache_cov.svh"
  `include "cache_env.svh"

endpackage

`endif
