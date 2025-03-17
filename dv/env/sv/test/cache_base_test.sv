`ifndef CACHE_BASE_TEST_SV
`define CACHE_BASE_TEST_SV
`define THIS_CLASS cache_base_test

class `THIS_CLASS extends uvm_test;
  `uvm_component_utils(`THIS_CLASS);

  cache_env       m_env;
  cache_coverage  m_cov;

  extern  virtual function  void  build_phase(uvm_phase phase);
  extern  virtual function  void  end_of_elaboration_phase(uvm_phase phase);
  extern  virtual task            main_phase(uvm_phase phase);

  function new(string name="`THIS_CLASS", uvm_component component);
    super.new(name, component);
  endfunction: new
endclass: `THIS_CLASS

// ------------------------------------------------------------------
function void `THIS_CLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
  m_env = cache_env::type_id::create("m_env", this);
  m_cov = cache_coverage::type_id::create("m_cov", this);
endfunction: build_phase

// ------------------------------------------------------------------
function void `THIS_CLASS::end_of_elaboration_phase(uvm_phase phase);
  super.build_phase(phase);
  uvm_top.print_topology();
endfunction: end_of_elaboration_phase

// ------------------------------------------------------------------
task `THIS_CLASS::main_phase(uvm_phase phase);
  phase.raise_objection(this);
  `uvm_info(get_type_name(), "Start test", UVM_LOW)
  #100;
  `uvm_info(get_type_name(), "Complete test", UVM_LOW)
  phase.drop_objection(this);
endtask: main_phase

`undef THIS_CLASS
`endif
