`ifndef CACHE_ENV_SV
`define CACHE_ENV_SV
`define THIS_CLASS cache_env

class `THIS_CLASS extends uvm_env;
  `uvm_component_utils(`THIS_CLASS);

  cache_active_agent  m_req_agt;
  cache_passive_agent m_rsp_agt;

  extern function  void  build_phase(uvm_phase phase);
  extern function  void  connect_phase(uvm_phase phase);

  function new(string name="`THIS_CLASS", uvm_component component);
    super.new(name, component);
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
function void `THIS_CLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
  m_req_agt = cache_active_agent::type_id::create("m_req_agt", this);
  m_rsp_agt = cache_passive_agent::type_id::create("m_rsp_agt", this);
endfunction: build_phase

//-------------------------------------------------------------------
function void `THIS_CLASS::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction: connect_phase

`undef THIS_CLASS
`endif
