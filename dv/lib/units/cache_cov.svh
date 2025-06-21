`ifndef CACHE_COV_SVH
`define CACHE_COV_SVH
`define THIS_CLASS cache_cov_c

class `THIS_CLASS extends uvm_component;
  `uvm_component_utils(`THIS_CLASS)

  uvm_analysis_imp  #(cache_txn_c, `THIS_CLASS) m_a_imp;
  uvm_analysis_port #(cache_txn_c)              m_ap;

  string            m_msg_name = "COV";
  cache_cov_cdreq_c m_cov_cdreq;
  cache_cov_sureq_c m_cov_sureq;

  extern  virtual function  void  build_phase(uvm_phase phase);
  extern  virtual function  void  connect_phase(uvm_phase phase);
  extern  virtual function  void  write(cache_txn_c t);

  function new(string name="`THIS_CLASS", uvm_component parent);
    super.new(name, parent);
    m_a_imp = new("a_imp", this);
    m_ap    = new("ap", this);
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
function void `THIS_CLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
  m_cov_cdreq = cache_cov_cdreq_c::type_id::create("cov_cdreq", this);
  m_cov_sureq = cache_cov_sureq_c::type_id::create("cov_sureq", this);
endfunction: build_phase

//-------------------------------------------------------------------
function void `THIS_CLASS::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  this.m_ap.connect(m_cov_cdreq.m_a_imp);
  this.m_ap.connect(m_cov_sureq.m_a_imp);
endfunction: connect_phase

//-------------------------------------------------------------------
function void `THIS_CLASS::write(cache_txn_c t);
  cache_txn_c t_loc = new t;
  m_ap.write(t_loc);
endfunction: write

`undef THIS_CLASS
`endif
