`ifndef CACHE_ACTIVE_MONITOR_SV
`define CACHE_ACTIVE_MONITOR_SV
`define THIS_CLASS cache_active_monitor

class `THIS_CLASS extends uvm_monitor;
  `uvm_component_utils(`THIS_CLASS);

  extern  function  void  build_phase(uvm_phase phase);
  extern  task            main_phase(uvm_phase phase);

  function new(string name="`THIS_CLASS", uvm_component component);
    super.new(name, component);
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
function void `THIS_CLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction: build_phase

//-------------------------------------------------------------------
task `THIS_CLASS::main_phase(uvm_phase phase);
  phase.raise_objection(this);
  phase.drop_objection(this);
endtask: main_phase

`undef THIS_CLASS
`endif
