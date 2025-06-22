`ifndef CACHE_COV_CDREQ_SVH
`define CACHE_COV_CDREQ_SVH
`define THIS_CLASS cache_cov_cdreq_c

class `THIS_CLASS extends uvm_component;
  `uvm_component_utils(`THIS_CLASS)

  uvm_analysis_imp #(cache_txn_c, `THIS_CLASS) m_txn_a_imp;

  string      m_msg_name = "COV_CDREQ";
  cache_txn_c m_txn_q[$];
  cache_txn_c m_txn;

  extern  virtual function  void  build_phase(uvm_phase phase);
  extern  virtual task            run_phase(uvm_phase phase);
  extern  virtual function  void  report_phase(uvm_phase phase);
  extern  virtual function  void  write(cache_txn_c t);

  //-----------------------------------------------------------------
  covergroup CG_CDREQ_OP_COV();
    option.per_instance = 1;

    CP_CDREQ_OP_COV: coverpoint m_txn.cdreq_op {
          bins CB_CDREQ_RD  = {CDREQ_RD };
          bins CB_CDREQ_RFO = {CDREQ_RFO};
          bins CB_CDREQ_MD  = {CDREQ_MD };
          bins CB_CDREQ_WB  = {CDREQ_WB };
    }
  endgroup: CG_CDREQ_OP_COV

  //-----------------------------------------------------------------
  covergroup CG_CDREQ_IDX_COV();
    option.per_instance = 1;

    CP_CDREQ_IDX_COV: coverpoint m_txn.cdreq_addr[`IDX] {
          bins CB_CDREQ_IDX[] = {[0:`VIP_NUM_IDX-1]};
    }
  endgroup: CG_CDREQ_IDX_COV

  //-----------------------------------------------------------------
  function new(string name="`THIS_CLASS", uvm_component parent);
    super.new(name, parent);
    CG_CDREQ_OP_COV = new();
    CG_CDREQ_IDX_COV = new();
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
function void `THIS_CLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
  m_txn_a_imp = new("txn_a_imp", this);
endfunction: build_phase

//-------------------------------------------------------------------
function void `THIS_CLASS::write(cache_txn_c t);
  cache_txn_c t_loc = new t;
  if(t_loc.Type == L1_REQ) begin
    `uvm_info(m_msg_name, $sformatf("sample CDREQ transaction: %s", t_loc.convert2string()), UVM_LOW)
    m_txn_q.push_back(t_loc);
  end
endfunction: write

//-------------------------------------------------------------------
task `THIS_CLASS::run_phase(uvm_phase phase);
  while(1) begin
    wait(m_txn_q.size() > 0);
    while(m_txn_q.size() > 0) begin
      m_txn = m_txn_q.pop_front();
      CG_CDREQ_OP_COV.sample();
      CG_CDREQ_IDX_COV.sample();
    end
  end
endtask: run_phase

//-------------------------------------------------------------------
function void `THIS_CLASS::report_phase(uvm_phase phase);
  super.report_phase(phase);
  `uvm_info(m_msg_name, $sformatf("CG_CDREQ_OP_COV=%f", CG_CDREQ_OP_COV.get_coverage()), UVM_LOW)
endfunction: report_phase

`undef THIS_CLASS
`endif
