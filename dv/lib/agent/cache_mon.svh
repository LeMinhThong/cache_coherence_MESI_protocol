`ifndef CACHE_MON_SVH
`define CACHE_MON_SVH
`define THIS_CLASS cache_mon_c

class `THIS_CLASS extends uvm_monitor;
  `uvm_component_utils(`THIS_CLASS);

  //cache_mon_bfm_c m_mon_bfm;

  extern  function  void  build_phase(uvm_phase phase);

  function new(string name="`THIS_CLASS", uvm_component component);
    super.new(name, component);
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
function void `THIS_CLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
  //m_mon_bfm = cache_mon_bfm_c::type_id::create("mon_bfm", this);
endfunction: build_phase

`undef THIS_CLASS
`endif
