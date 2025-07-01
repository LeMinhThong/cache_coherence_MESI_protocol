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
  covergroup CG_CDREQ_MESI_COV();
    option.per_instance = 1;

    `CP_STATE_COV

    CP_CDREQ_OP_COV: coverpoint m_txn.cdreq_op {
          bins CB_CDREQ_RD  = {CDREQ_RD};
          bins CB_CDREQ_RFO = {CDREQ_RFO};
          bins CB_CDREQ_MD  = {CDREQ_MD};
          bins CB_CDREQ_WB  = {CDREQ_WB};
    }
    CP_LOOKUP_COV: coverpoint m_txn.Lookup {
          bins CB_HIT           = {HIT};
          bins CB_FILL_INV_BLK  = {FILL_INV_BLK};
          bins CB_EVICT_BLK     = {EVICT_BLK};
    }
    CP_CUREQ_OP_COV: coverpoint m_txn.cureq_op {
          bins CB_CUREQ_RFO = {CUREQ_RFO};
          bins CB_CUREQ_INV = {CUREQ_INV};
    }

    CP_CDRSP_RSP_COV: coverpoint m_txn.cdrsp_rsp {
          bins CB_CDRSP_OKAY  = {CDRSP_OKAY};
    }
    CP_SDREQ_OP_COV: coverpoint m_txn.sdreq_op {
          bins CB_SDREQ_RD  = {SDREQ_RD };
          bins CB_SDREQ_RFO = {SDREQ_RFO};
          bins CB_SDREQ_INV = {SDREQ_INV};
    }
    CP_SURSP_RSP_COV: coverpoint m_txn.sursp_rsp {
          bins CB_SURSP_OKAY  = {SURSP_OKAY};
          bins CB_SURSP_FETCH = {SURSP_FETCH};
          bins CB_SURSP_SNOOP = {SURSP_SNOOP};
    }
    CP_CURSP_RSP_COV: coverpoint m_txn.cursp_rsp {
          bins CB_CURSP_OKAY = {CURSP_OKAY};
    }
    CROSS_SDREQ_OP_X_SURSP_RSP_COV: cross CP_SDREQ_OP_COV, CP_SURSP_RSP_COV {
          illegal_bins CB_ILL_RD_X_OKAY       = binsof(CP_SDREQ_OP_COV) intersect {SDREQ_RD}  && binsof(CP_SURSP_RSP_COV) intersect {SURSP_OKAY};
          illegal_bins CB_ILL_RFO_X_NOT_OKAY  = binsof(CP_SDREQ_OP_COV) intersect {SDREQ_RFO} && binsof(CP_SURSP_RSP_COV) intersect {SURSP_FETCH, SURSP_SNOOP};
          illegal_bins CB_ILL_INV_X_NOT_OKAY  = binsof(CP_SDREQ_OP_COV) intersect {SDREQ_INV} && binsof(CP_SURSP_RSP_COV) intersect {SURSP_FETCH, SURSP_SNOOP};
    }
    CROSS_CDREQ_OP_X_LOOKUP_X_STATE: cross CP_CDREQ_OP_COV, CP_LOOKUP_COV, CP_STATE_COV {
          illegal_bins CB_ILL_INVALID_X_NOT_FILL        = binsof(CP_STATE_COV)    intersect {INVALID} &&
                                                          binsof(CP_LOOKUP_COV)   intersect {HIT, EVICT_BLK};

          illegal_bins CB_ILL_FILL_X_NOT_INVALID        = binsof(CP_STATE_COV)    intersect {EXCLUSIVE, SHARED, MODIFIED, MIGRATED} &&
                                                          binsof(CP_LOOKUP_COV)   intersect {FILL_INV_BLK};

          ignore_bins CB_IGN_L1_FETCH_X_HIT_X_MIGRATED  = binsof(CP_CDREQ_OP_COV) intersect {CDREQ_RD, CDREQ_RFO} &&
                                                          binsof(CP_LOOKUP_COV)   intersect {HIT} &&
                                                          binsof(CP_STATE_COV)    intersect {MIGRATED};

          ignore_bins CB_IGN_WB_X_NOT_MIGRATED          = binsof(CP_CDREQ_OP_COV) intersect {CDREQ_WB} &&
                                                          binsof(CP_LOOKUP_COV)   intersect {HIT} &&
                                                          binsof(CP_STATE_COV)    intersect {INVALID, EXCLUSIVE, SHARED, MODIFIED};

          ignore_bins CB_IGN_MD_X_MISS                  = binsof(CP_CDREQ_OP_COV) intersect {CDREQ_MD} && binsof(CP_LOOKUP_COV) intersect {FILL_INV_BLK, EVICT_BLK};
          ignore_bins CB_IGN_WB_X_MISS                  = binsof(CP_CDREQ_OP_COV) intersect {CDREQ_WB} && binsof(CP_LOOKUP_COV) intersect {FILL_INV_BLK, EVICT_BLK};
    }
  endgroup: CG_CDREQ_MESI_COV

  //-----------------------------------------------------------------
  covergroup CG_CDREQ_CORNER_CASE_COV();
    option.per_instance = 1;

    CP_CURSP_RSP_COV: coverpoint m_txn.cursp_rsp {
          bins        CB_CURSP_ERROR  = {CURSP_ERROR};
          //ignore_bins other           = {CURSP_OKAY};
    }
    CP_L1_FETCH_HIT_MIGRATED_COV: coverpoint m_txn.cdreq_op iff (m_txn.Lookup == HIT && m_txn.State == MIGRATED) {
          bins        CB_RD_HIT_MIGRATE   = {CDREQ_RD};
          bins        CB_RFO_HIT_MIGRATE  = {CDREQ_RFO};
          //ignore_bins other               = {CDREQ_MD, CDREQ_WB};
    }
    CP_WB_X_HIT_NOT_MIGRATED_COV: coverpoint m_txn.State iff (m_txn.cdreq_op == CDREQ_WB && m_txn.Lookup == HIT) {
          bins        CB_WB_HIT_EXCLUSIVE = {EXCLUSIVE};
          bins        CB_WB_HIT_SHARED    = {SHARED};
          bins        CB_WB_HIT_MODIFIED  = {MODIFIED};
          //ignore_bins other               = {INVALID};
    }
    CP_MD_X_MISS_COV: coverpoint m_txn.Lookup iff (m_txn.cdreq_op == CDREQ_MD) {
          bins        CB_MD_FILL  = {FILL_INV_BLK};
          bins        CB_MD_EVICT = {EVICT_BLK};
          //ignore_bins other       = {HIT};
    }
    CP_WB_X_MISS_COV: coverpoint m_txn.Lookup iff (m_txn.cdreq_op == CDREQ_MD) {
          bins        CB_WB_FILL  = {FILL_INV_BLK};
          bins        CB_WB_EVICT = {EVICT_BLK};
          //ignore_bins other       = {HIT};
    }
  endgroup: CG_CDREQ_CORNER_CASE_COV

  //-----------------------------------------------------------------
  covergroup CG_CDREQ_BLK_COV();
    option.per_instance = 1;

    CP_IDX_COV: coverpoint m_txn.Idx {
          bins CB_IDX[] = {[0:`VIP_NUM_IDX-1]};
    }
    CP_WAY_COV: coverpoint m_txn.Way {
          bins CB_WAY[] = {[0:`VIP_NUM_WAY]};
    }
    CROSS_IDX_WAY_COV: cross CP_IDX_COV, CP_WAY_COV;
  endgroup: CG_CDREQ_BLK_COV

  //-----------------------------------------------------------------
  function new(string name="`THIS_CLASS", uvm_component parent);
    super.new(name, parent);
    CG_CDREQ_MESI_COV = new();
    CG_CDREQ_CORNER_CASE_COV = new();
    CG_CDREQ_BLK_COV = new();
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
      CG_CDREQ_MESI_COV.sample();
      CG_CDREQ_CORNER_CASE_COV.sample();
      CG_CDREQ_BLK_COV.sample();
    end
  end
endtask: run_phase

//-------------------------------------------------------------------
function void `THIS_CLASS::report_phase(uvm_phase phase);
  super.report_phase(phase);
  `uvm_info(m_msg_name, $sformatf("CG_CDREQ_MESI_COV=%f", CG_CDREQ_MESI_COV.get_coverage()), UVM_LOW)
  `uvm_info(m_msg_name, $sformatf("CG_CDREQ_CORNER_CASE_COV=%f", CG_CDREQ_CORNER_CASE_COV.get_coverage()), UVM_LOW)
  `uvm_info(m_msg_name, $sformatf("CG_CDREQ_BLK_COV=%f", CG_CDREQ_BLK_COV.get_coverage()), UVM_LOW)
endfunction: report_phase

`undef THIS_CLASS
`endif
