`ifndef CACHE_COV_SUREQ_SVH
`define CACHE_COV_SUREQ_SVH
`define THIS_CLASS cache_cov_sureq_c

class `THIS_CLASS extends uvm_component;
  `uvm_component_utils(`THIS_CLASS)

  uvm_analysis_imp #(cache_txn_c, `THIS_CLASS) m_a_imp;

  string      m_msg_name = "COV_CDREQ";
  cache_txn_c trans[$];
  cache_txn_c trans_obj;

  extern  virtual function  void  build_phase(uvm_phase phase);
  extern  virtual task            run_phase(uvm_phase phase);
  extern  virtual function  void  report_phase(uvm_phase phase);
  extern  virtual function  void  write(cache_txn_c t);

  covergroup CG_SUREQ_OP_COV();
    option.per_instance = 1;

    CP_SUREQ_OP_COV: coverpoint trans_obj.sureq_op {
          bins CB_SUREQ_RD  = {SUREQ_RD };
          bins CB_SUREQ_RFO = {SUREQ_RFO};
          bins CB_SUREQ_INV = {SUREQ_INV};
    }
  endgroup: CG_SUREQ_OP_COV

  function new(string name="`THIS_CLASS", uvm_component parent);
    super.new(name, parent);
    m_a_imp = new("a_imp", this);
    CG_SUREQ_OP_COV = new();
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
function void `THIS_CLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction: build_phase

//-------------------------------------------------------------------
function void `THIS_CLASS::write(cache_txn_c t);
  cache_txn_c t_loc = new t;
  if(t_loc.Type_xfr == SUREQ_XFR) begin
    trans.push_back(t_loc);
  end
endfunction: write

//-------------------------------------------------------------------
task `THIS_CLASS::run_phase(uvm_phase phase);
  while(1) begin
    wait(trans.size() > 0);
    while(trans.size() > 0) begin
      trans_obj = trans.pop_front();
      CG_SUREQ_OP_COV.sample();
    end
  end
endtask: run_phase

//-------------------------------------------------------------------
function void `THIS_CLASS::report_phase(uvm_phase phase);
  super.report_phase(phase);
  `uvm_info(m_msg_name, $sformatf("CG_SUREQ_OP_COV=%f", CG_SUREQ_OP_COV.get_coverage()), UVM_LOW)
endfunction: report_phase

`undef THIS_CLASS
`endif
