`ifndef CACHE_COV_SUREQ_SVH
`define CACHE_COV_SUREQ_SVH
`define THIS_CLASS cache_cov_sureq_c

class `THIS_CLASS extends uvm_component;
  `uvm_component_utils(`THIS_CLASS)

  uvm_analysis_imp #(cache_txn_c, `THIS_CLASS) m_txn_a_imp;

  string      m_msg_name = "COV_SUREQ";
  cache_txn_c m_txn_q[$];
  cache_txn_c m_txn;

  extern  virtual function  void  build_phase(uvm_phase phase);
  extern  virtual task            run_phase(uvm_phase phase);
  extern  virtual function  void  report_phase(uvm_phase phase);
  extern  virtual function  void  write(cache_txn_c t);

  covergroup CG_SUREQ_MESI_COV();
    option.per_instance = 1;

    CP_SUREQ_OP_COV: coverpoint m_txn.sureq_op {
          bins CB_SUREQ_RD  = {SUREQ_RD };
          bins CB_SUREQ_RFO = {SUREQ_RFO};
          bins CB_SUREQ_INV = {SUREQ_INV};
    }
    CP_LOOKUP_COV: coverpoint m_txn.Lookup {
          bins CP_HIT       = {HIT      };
          bins CP_SNP_MISS  = {SNP_MISS };
    }
    `CP_STATE_COV
    CP_CUREQ_OP_COV: coverpoint m_txn.cureq_op {
          bins CP_CUREQ_RD  = {CUREQ_RD };
          bins CP_CUREQ_RFO = {CUREQ_RFO};
          bins CP_CUREQ_INV = {CUREQ_INV};
    }
    CP_CDRSP_RSP_COV: coverpoint m_txn.cdrsp_rsp {
          bins CP_CDRSP_OKAY  = {CDRSP_OKAY};
    }
    CP_SDREQ_OP_COV: coverpoint m_txn.sdreq_op {
          bins CP_SDREQ_WB = {SDREQ_WB};
    }
    CP_SURSP_RSP_COV: coverpoint m_txn.sursp_rsp {
          bins CP_SURSP_OKAY = {SURSP_OKAY};
    }
    CROSS_SUREQ_OP_X_STATE_COV: cross CP_SUREQ_OP_COV, CP_STATE_COV {
          illegal_bins CP_ILL_INV_X_EXCLUSIVE = binsof(CP_SUREQ_OP_COV) intersect {SUREQ_INV} && binsof(CP_STATE_COV) intersect {EXCLUSIVE};
          illegal_bins CP_ILL_INV_X_MIGRATED  = binsof(CP_SUREQ_OP_COV) intersect {SUREQ_INV} && binsof(CP_STATE_COV) intersect {MIGRATED };
          illegal_bins CP_ILL_INV_X_MODIFIED  = binsof(CP_SUREQ_OP_COV) intersect {SUREQ_INV} && binsof(CP_STATE_COV) intersect {MODIFIED };
    }
    CROSS_SUREQ_OP_X_LOOKUP_COV: cross CP_SUREQ_OP_COV, CP_LOOKUP_COV, CP_STATE_COV;
  endgroup: CG_SUREQ_MESI_COV

  function new(string name="`THIS_CLASS", uvm_component parent);
    super.new(name, parent);
    CG_SUREQ_MESI_COV = new();
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
  if(t_loc.Type == SNP_REQ) begin
    `uvm_info(m_msg_name, $sformatf("sample SUREQ transaction: %s", t_loc.convert2string()), UVM_LOW)
    m_txn_q.push_back(t_loc);
  end
endfunction: write

//-------------------------------------------------------------------
task `THIS_CLASS::run_phase(uvm_phase phase);
  while(1) begin
    wait(m_txn_q.size() > 0);
    while(m_txn_q.size() > 0) begin
      m_txn = m_txn_q.pop_front();
      CG_SUREQ_MESI_COV.sample();
    end
  end
endtask: run_phase

//-------------------------------------------------------------------
function void `THIS_CLASS::report_phase(uvm_phase phase);
  super.report_phase(phase);
  `uvm_info(m_msg_name, $sformatf("CG_SUREQ_MESI_COV=%f", CG_SUREQ_MESI_COV.get_coverage()), UVM_LOW)
endfunction: report_phase

`undef THIS_CLASS
`endif
