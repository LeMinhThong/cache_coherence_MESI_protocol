`ifndef CACHE_PASSIVE_AGENT_SV
`define CACHE_PASSIVE_AGENT_SV
`define THIS_CLASS cache_passive_agent

class `THIS_CLASS extends uvm_agent;
  `uvm_component_utils(`THIS_CLASS);

  cache_passive_monitor m_mon;

  extern  function  void  build_phase(uvm_phase phase);
  extern  function  void  connect_phase(uvm_phase phase);

  function new(string name="`THIS_CLASS", uvm_component component);
    super.new(name, component);
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
function void `THIS_CLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
  m_mon = cache_passive_monitor::type_id::create("m_mon", this);
endfunction: build_phase

//-------------------------------------------------------------------
function void `THIS_CLASS::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction: connect_phase

`undef THIS_CLASS
`endif
