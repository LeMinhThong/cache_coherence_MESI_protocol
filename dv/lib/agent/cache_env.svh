`ifndef CACHE_ENV_SVH
`define CACHE_ENV_SVH
`define THIS_CLASS cache_env_c

class `THIS_CLASS extends uvm_env;
  `uvm_component_utils(`THIS_CLASS);

  cache_agt_c  m_agt;

  extern function  void  build_phase(uvm_phase phase);
  extern function  void  connect_phase(uvm_phase phase);

  function new(string name="`THIS_CLASS", uvm_component component);
    super.new(name, component);
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
function void `THIS_CLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
  m_agt = cache_agt_c::type_id::create("agt", this);
endfunction: build_phase

//-------------------------------------------------------------------
function void `THIS_CLASS::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction: connect_phase

`undef THIS_CLASS
`endif
