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

    CP_CDREQ_OP_COV: coverpoint m_txn.cdreq_op {
          bins CB_CDREQ_RD  = {CDREQ_RD };
          bins CB_CDREQ_RFO = {CDREQ_RFO};
          bins CB_CDREQ_MD  = {CDREQ_MD };
          bins CB_CDREQ_WB  = {CDREQ_WB };
    }
    CP_LOOKUP_COV: coverpoint m_txn.Lookup {
          bins CP_HIT           = {HIT          };
          bins CP_FILL_INV_BLK  = {FILL_INV_BLK };
          bins CP_EVICT_BLK     = {EVICT_BLK    };
    }
    `CP_STATE_COV
    CP_CUREQ_OP_COV: coverpoint m_txn.cureq_op {
          bins CP_CUREQ_RFO = {CUREQ_RFO};
          bins CP_CUREQ_INV = {CUREQ_INV};
    }
    CP_CDRSP_RSP_COV: coverpoint m_txn.cdrsp_rsp {
          bins CP_CDRSP_OKAY  = {CDRSP_OKAY};
    }
    CP_SDREQ_OP_COV: coverpoint m_txn.sdreq_op {
          bins CB_SDREQ_RD  = {SDREQ_RD };
          bins CB_SDREQ_RFO = {SDREQ_RFO};
          bins CB_SDREQ_INV = {SDREQ_INV};
          //bins CB_SDREQ_WB  = {SDREQ_WB };
    }
    CP_SURSP_RSP_COV: coverpoint m_txn.sursp_rsp {
          bins CB_SURSP_OKAY  = {SURSP_OKAY };
          bins CB_SURSP_FETCH = {SURSP_FETCH};
          bins CB_SURSP_SNOOP = {SURSP_SNOOP};
    }
    CP_CURSP_RSP_COV: coverpoint m_txn.cursp_rsp {
          bins CB_RSP_CURSP_OKAY = {CURSP_OKAY};
    }
    // FIXME cross CP_CDREQ_OP_COV, CP_STATE_COV, CP_LOOKUP_COV
    CROSS_CDREQ_OP_X_STATE_COV: cross CP_CDREQ_OP_COV, CP_STATE_COV {
          // occurred when EVICT WAY
          //illegal_bins CB_ILL_RD_X_MIGRATED   = binsof(CP_CDREQ_OP_COV) intersect {CDREQ_RD } && binsof(CP_STATE_COV)  intersect {MIGRATED  };
          //illegal_bins CB_ILL_RFO_X_MIGRATED  = binsof(CP_CDREQ_OP_COV) intersect {CDREQ_RFO} && binsof(CP_STATE_COV)  intersect {MIGRATED  };
          illegal_bins CB_ILL_MD_X_INVALID    = binsof(CP_CDREQ_OP_COV) intersect {CDREQ_MD } && binsof(CP_STATE_COV)  intersect {INVALID   };
          illegal_bins CB_ILL_WB_X_INVALID    = binsof(CP_CDREQ_OP_COV) intersect {CDREQ_WB } && binsof(CP_STATE_COV)  intersect {INVALID   };
          illegal_bins CB_ILL_WB_X_SHARED     = binsof(CP_CDREQ_OP_COV) intersect {CDREQ_WB } && binsof(CP_STATE_COV)  intersect {SHARED    };
          illegal_bins CB_ILL_WB_X_MODIFIED   = binsof(CP_CDREQ_OP_COV) intersect {CDREQ_WB } && binsof(CP_STATE_COV)  intersect {MODIFIED  };
    }
    CROSS_CDREQ_OP_X_LOOKUP_COV: cross CP_CDREQ_OP_COV, CP_LOOKUP_COV {
          illegal_bins CP_ILL_MD_X_FILL_INV_BLK = binsof(CP_CDREQ_OP_COV) intersect {CDREQ_MD} && binsof(CP_LOOKUP_COV) intersect {FILL_INV_BLK };
          illegal_bins CP_ILL_MD_X_EVICT_BLK    = binsof(CP_CDREQ_OP_COV) intersect {CDREQ_MD} && binsof(CP_LOOKUP_COV) intersect {EVICT_BLK    };
          illegal_bins CP_ILL_WB_X_FILL_INV_BLK = binsof(CP_CDREQ_OP_COV) intersect {CDREQ_WB} && binsof(CP_LOOKUP_COV) intersect {FILL_INV_BLK };
          illegal_bins CP_ILL_WB_X_EVICT_BLK    = binsof(CP_CDREQ_OP_COV) intersect {CDREQ_WB} && binsof(CP_LOOKUP_COV) intersect {EVICT_BLK    };
    }
    CROSS_SDREQ_OP_X_SURSP_RSP_COV: cross CP_SDREQ_OP_COV, CP_SURSP_RSP_COV {
          illegal_bins CB_ILL_RD_X_OKAY   = binsof(CP_SDREQ_OP_COV) intersect {SDREQ_RD  } && binsof(CP_SURSP_RSP_COV) intersect {SURSP_OKAY };
          illegal_bins CB_ILL_RFO_X_FETCH = binsof(CP_SDREQ_OP_COV) intersect {SDREQ_RFO } && binsof(CP_SURSP_RSP_COV) intersect {SURSP_FETCH};
          illegal_bins CB_ILL_RFO_X_SNOOP = binsof(CP_SDREQ_OP_COV) intersect {SDREQ_RFO } && binsof(CP_SURSP_RSP_COV) intersect {SURSP_SNOOP};
          illegal_bins CB_ILL_WB_X_FETCH  = binsof(CP_SDREQ_OP_COV) intersect {SDREQ_WB  } && binsof(CP_SURSP_RSP_COV) intersect {SURSP_FETCH};
          illegal_bins CB_ILL_WB_X_SNOOP  = binsof(CP_SDREQ_OP_COV) intersect {SDREQ_WB  } && binsof(CP_SURSP_RSP_COV) intersect {SURSP_SNOOP};
          illegal_bins CB_ILL_INV_X_FETCH = binsof(CP_SDREQ_OP_COV) intersect {SDREQ_INV } && binsof(CP_SURSP_RSP_COV) intersect {SURSP_FETCH};
          illegal_bins CB_ILL_INV_X_SNOOP = binsof(CP_SDREQ_OP_COV) intersect {SDREQ_INV } && binsof(CP_SURSP_RSP_COV) intersect {SURSP_SNOOP};
    }
    CORSS_STATE_X_LOOKUP_COV: cross CP_STATE_COV, CP_LOOKUP_COV {
          illegal_bins CB_ILL_INVALID_X_HIT             = binsof(CP_STATE_COV) intersect {INVALID   } && binsof(CP_LOOKUP_COV) intersect {HIT         };
          illegal_bins CB_ILL_INVALID_X_EVICT_BLK       = binsof(CP_STATE_COV) intersect {INVALID   } && binsof(CP_LOOKUP_COV) intersect {EVICT_BLK   };
          illegal_bins CB_ILL_EXCLUSIVE_X_FILL_INV_BLK  = binsof(CP_STATE_COV) intersect {EXCLUSIVE } && binsof(CP_LOOKUP_COV) intersect {FILL_INV_BLK};
          illegal_bins CB_ILL_SHARED_X_FILL_INV_BLK     = binsof(CP_STATE_COV) intersect {SHARED    } && binsof(CP_LOOKUP_COV) intersect {FILL_INV_BLK};
          illegal_bins CB_ILL_MODIFIED_X_FILL_INV_BLK   = binsof(CP_STATE_COV) intersect {MODIFIED  } && binsof(CP_LOOKUP_COV) intersect {FILL_INV_BLK};
          illegal_bins CB_ILL_MIGRATED_X_FILL_INV_BLK   = binsof(CP_STATE_COV) intersect {MIGRATED  } && binsof(CP_LOOKUP_COV) intersect {FILL_INV_BLK};
    }
  endgroup: CG_CDREQ_MESI_COV

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
      CG_CDREQ_BLK_COV.sample();
    end
  end
endtask: run_phase

//-------------------------------------------------------------------
function void `THIS_CLASS::report_phase(uvm_phase phase);
  super.report_phase(phase);
  `uvm_info(m_msg_name, $sformatf("CG_CDREQ_MESI_COV=%f", CG_CDREQ_MESI_COV.get_coverage()), UVM_LOW)
  `uvm_info(m_msg_name, $sformatf("CG_CDREQ_BLK_COV=%f", CG_CDREQ_BLK_COV.get_coverage()), UVM_LOW)
endfunction: report_phase

`undef THIS_CLASS
`endif
