`ifndef CACHE_BASE_TEST_SV
`define CACHE_BASE_TEST_SV
`define THIS_CLASS cache_base_test_c

class `THIS_CLASS extends uvm_test;
  `uvm_component_utils(`THIS_CLASS);

  cache_env_c m_env;
  cache_cov_c m_cov;

  //cache_base_seq_c  m_seq;

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
  m_env = cache_env_c::type_id::create("env", this);
  m_cov = cache_cov_c::type_id::create("cov", this);
endfunction: build_phase

// ------------------------------------------------------------------
function void `THIS_CLASS::end_of_elaboration_phase(uvm_phase phase);
  super.build_phase(phase);
  uvm_top.print_topology();
endfunction: end_of_elaboration_phase

// ------------------------------------------------------------------
task `THIS_CLASS::main_phase(uvm_phase phase);
  l1_req_seq_c m_l1_seq = new();
  snp_req_seq_c m_snp_seq = new();
  phase.raise_objection(this);
  `uvm_info(get_type_name(), "Start test", UVM_LOW)

  #100ns;
  //for(int i = 0; i < 5; i++) begin
  //  cache_base_seq_c m_seq = new();
  //  m_seq.m_rand_seq = $urandom();
  //  m_seq.start(m_env.m_agt.m_sqr);
  //  #10ns;
  //end

  fork
    begin
      m_l1_seq.config_seq(L1_RD, 32'h10, '0, SNP_FETCH, 32'hff);
      m_l1_seq.start(m_env.m_agt.m_sqr);
    end
    //begin
    //  #10ns;
    //  m_snp_seq.m_rand_seq = 1;
    //  m_snp_seq.m_rand_wr_rate = 0;
    //  m_snp_seq.start(m_env.m_agt.m_sqr);
    //end
  join
  #20ns;
  `uvm_info(get_type_name(), "Complete test", UVM_LOW)
  phase.drop_objection(this);
endtask: main_phase

`undef THIS_CLASS
`endif
