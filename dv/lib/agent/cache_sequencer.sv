`ifndef CACHE_SEQUENCER_SV
`define CACHE_SEQUENCER_SV
`define THIS_CLASS cache_sequencer

class `THIS_CLASS extends uvm_sequencer;
  `uvm_component_utils(`THIS_CLASS);

  extern  function  void  build_phase(uvm_phase phase);

  function new(string name="`THIS_CLASS", uvm_component component);
    super.new(name, component);
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
function void `THIS_CLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction: build_phase

`undef THIS_CLASS
`endif
