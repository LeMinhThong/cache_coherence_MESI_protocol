`ifndef CACHE_BASE_TEST_SV
`define CACHE_BASE_TEST_SV
`define THIS_CLASS cache_base_test_c
`define M_VIF m_vif.drv_cb

`define START_SEQ(seq) seq.start(m_env.m_agt.m_sqr);

class `THIS_CLASS extends uvm_test;
  `uvm_component_utils(`THIS_CLASS);

  virtual cache_if m_vif;

  cache_env_c m_env;

  time m_timeout = 100us;

  extern  virtual task            send_l1_rd  (address_t addr, sursp_e sursp_rsp=SURSP_OKAY);
  extern  virtual task            send_l1_rfo (address_t addr);
  extern  virtual task            send_l1_md  (address_t addr);
  extern  virtual task            send_l1_wb  (address_t addr);

  extern  virtual task            send_snp_rd (address_t addr);
  extern  virtual task            send_snp_rfo(address_t addr);
  extern  virtual task            send_snp_inv(address_t addr);

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
    begin
      #m_timeout `uvm_fatal(get_type_name(), "Test main phase reached timeout")
    end

    begin
      #50ns;
      run_seq();
    end
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

// ------------------------------------------------------------------
task `THIS_CLASS::send_l1_rd(address_t addr, sursp_e sursp_rsp=SURSP_OKAY);
  l1_req_seq_c m_seq  = new();

  m_seq.m_op          = CDREQ_RD;
  m_seq.m_addr        = addr;
  m_seq.m_sursp_rsp   = sursp_rsp;
  //std::randomize(m_seq.m_sursp_data);
  `START_SEQ(m_seq);
endtask: send_l1_rd

// ------------------------------------------------------------------
task `THIS_CLASS::send_l1_rfo(address_t addr);
  l1_req_seq_c m_seq  = new();

  m_seq.m_op          = CDREQ_RFO;
  m_seq.m_addr        = addr;
  //std::randomize(m_seq.m_sursp_data);
  `START_SEQ(m_seq);
endtask: send_l1_rfo

// ------------------------------------------------------------------
task `THIS_CLASS::send_l1_md(address_t addr);
  l1_req_seq_c m_seq  = new();

  m_seq.m_op          = CDREQ_MD;
  m_seq.m_addr        = addr;
  `START_SEQ(m_seq);
endtask: send_l1_md

// ------------------------------------------------------------------
task `THIS_CLASS::send_l1_wb(address_t addr);
  l1_req_seq_c m_seq  = new();

  m_seq.m_op          = CDREQ_WB;
  m_seq.m_addr        = addr;
  //if(data == -1)
  //  std::randomize(m_seq.m_cdreq_data);
  //else
  //  m_seq.m_cdreq_data = data;
  `START_SEQ(m_seq);
endtask: send_l1_wb

// ------------------------------------------------------------------
task `THIS_CLASS::send_snp_rd(address_t addr);
  snp_req_seq_c m_seq = new();

  m_seq.m_op    = SUREQ_RD;
  m_seq.m_addr  = addr;
  //std::randomize(m_seq.m_cdrsp_data);
  `START_SEQ(m_seq);
endtask: send_snp_rd

// ------------------------------------------------------------------
task `THIS_CLASS::send_snp_rfo(address_t addr);
  snp_req_seq_c m_seq = new();

  m_seq.m_op    = SUREQ_RFO;
  m_seq.m_addr  = addr;
  //std::randomize(m_seq.m_seq.m_cdrsp_data);
  `START_SEQ(m_seq);
endtask: send_snp_rfo

// ------------------------------------------------------------------
task `THIS_CLASS::send_snp_inv(address_t addr);
  snp_req_seq_c m_seq = new();

  m_seq.m_op    = SUREQ_INV;
  m_seq.m_addr  = addr;
  `START_SEQ(m_seq);
endtask: send_snp_inv

`undef THIS_CLASS
`endif
