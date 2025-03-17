`ifndef CACHE_DRIVER_SV
`define CACHE_DRIVER_SV
`define THIS_CLASS cache_driver
`define M_VIF m_if.req_drv_cb 

class `THIS_CLASS extends uvm_driver;
  `uvm_component_utils(`THIS_CLASS);
  virtual cache_if m_if;

  extern  function  void  build_phase(uvm_phase phase);
  extern  task            main_phase(uvm_phase phase);

  function new(string name="`THIS_CLASS", uvm_component component);
    super.new(name, component);
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
function void `THIS_CLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(virtual cache_if)::get(this, "", "cac_if", m_if))
    uvm_report_fatal(get_type_name(), "Cannot get virtual cache interface");
endfunction: build_phase

//-------------------------------------------------------------------
task `THIS_CLASS::main_phase(uvm_phase phase);
  phase.raise_objection(this);
  phase.drop_objection(this);
endtask: main_phase

`undef M_VIF
`undef THIS_CLASS
`endif
