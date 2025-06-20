`ifndef CACHE_SEQR_SVH
`define CACHE_SEQR_SVH
`define THIS_CLASS cache_seqr_c

class `THIS_CLASS extends uvm_sequencer #(cache_txn_c);
  `uvm_component_utils(`THIS_CLASS);

  function new(string name="`THIS_CLASS", uvm_component component);
    super.new(name, component);
  endfunction: new
endclass: `THIS_CLASS

`undef THIS_CLASS
`endif
