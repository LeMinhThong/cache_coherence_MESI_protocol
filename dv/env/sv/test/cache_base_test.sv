`ifndef CACHE_BASE_TEST_SV
`define CACHE_BASE_TEST_SV
`define THIS_CLASS cache_base_test_c
`define M_VIF m_vif.drv_cb

`define START_SEQ(seq) seq.start(m_env.m_agt.m_sqr);

class `THIS_CLASS extends uvm_test;
  `uvm_component_utils(`THIS_CLASS);

  virtual cache_if m_vif;

  cache_env_c m_env;
  cache_cov_c m_cov;

  time m_timeout = 100us;

  extern  virtual function  void  build_phase(uvm_phase phase);
  extern  virtual function  void  end_of_elaboration_phase(uvm_phase phase);
  extern  virtual task            main_phase(uvm_phase phase);
  extern  virtual task            run_seq();

  function new(string name="`THIS_CLASS", uvm_component component);
    super.new(name, component);
  endfunction: new
endclass: `THIS_CLASS

// ------------------------------------------------------------------
function void `THIS_CLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
  m_env = cache_env_c::type_id::create("env", this);
  m_cov = cache_cov_c::type_id::create("cov", this);
  if(!uvm_config_db#(virtual cache_if)::get(this, "", "cac_if", m_vif)) uvm_report_fatal(get_type_name(), "Cannot get virtual cache interface");
endfunction: build_phase

// ------------------------------------------------------------------
function void `THIS_CLASS::end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase);
  uvm_top.print_topology();
  fork
    forever begin
      #1us; `uvm_info("HEARTBEAT", "every 1us uints", UVM_DEBUG)
    end
  join_none
endfunction: end_of_elaboration_phase

// ------------------------------------------------------------------
task `THIS_CLASS::main_phase(uvm_phase phase);
  phase.raise_objection(this);
  `uvm_info(get_type_name(), "Start test", UVM_LOW)

  fork
    #m_timeout `uvm_fatal(get_type_name(), "Test main phase reached timeout")

    run_seq();
  join_any

  #50ns;

  `uvm_info(get_type_name(), "Complete test", UVM_LOW)
  phase.drop_objection(this);
endtask: main_phase

// ------------------------------------------------------------------
task `THIS_CLASS::run_seq();
  `uvm_info(get_type_name(), "hello from base run_seq", UVM_LOW)
  #50ns;
endtask: run_seq

`undef THIS_CLASS
`endif
