`ifndef CACHE_MON_SVH
`define CACHE_MON_SVH
`define THIS_CLASS cache_mon_c
`define M_VIF m_vif.mon_cb

class `THIS_CLASS extends uvm_monitor;
  `uvm_component_utils(`THIS_CLASS);

  uvm_analysis_port #(cache_txn_c)              m_xfr_ap;
  uvm_analysis_port #(cache_txn_c)              m_txn_ap;
  uvm_analysis_imp  #(cache_txn_c, `THIS_CLASS) m_lookup_a_imp;

  virtual cache_if m_vif; 

  string      m_msg_name = "MON";

  bit         cdreq_ot;
  address_t   cdreq_addr_bf;
  lookup_e    cdreq_lookup;
  cache_txn_c l1_xfr_q[$];
  cache_txn_c l1_lookup_q[$];

  bit         sureq_ot;
  address_t   sureq_addr_bf;
  cache_txn_c snp_xfr_q[$];
  cache_txn_c snp_lookup_q[$];

  string      cureq_owner;
  string      sdreq_owner;

  extern  virtual function  void  build_phase(uvm_phase phase);
  extern  virtual task            run_phase(uvm_phase phase);

  extern  virtual function  void  write(cache_txn_c t);
  extern  virtual task            coll_l1_txn();
  extern  virtual task            coll_snp_txn();

  extern  virtual task            coll_cdreq_xfr();
  extern  virtual task            coll_cursp_xfr();
  extern  virtual task            coll_cureq_xfr();
  extern  virtual task            coll_cdrsp_xfr();
  extern  virtual task            coll_sdreq_xfr();
  extern  virtual task            coll_sursp_xfr();
  extern  virtual task            coll_sureq_xfr();
  extern  virtual task            coll_sdrsp_xfr();

  function new(string name="`THIS_CLASS", uvm_component parent);
    super.new(name, parent);
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
function void `THIS_CLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(virtual cache_if)::get(this, "", "cac_if", m_vif)) `uvm_fatal(m_msg_name, "Cannot get virtual cache interface")
  m_xfr_ap        = new("xfr_ap", this);
  m_txn_ap        = new("txn_ap", this);
  m_lookup_a_imp  = new("lookup_a_imp", this);
endfunction: build_phase

//-------------------------------------------------------------------
task `THIS_CLASS::run_phase(uvm_phase phase);
  fork
    coll_l1_txn();  
    coll_snp_txn();

    coll_cdreq_xfr();
    coll_cursp_xfr();
    coll_cureq_xfr();
    coll_cdrsp_xfr();
    coll_sdreq_xfr();
    coll_sursp_xfr();
    coll_sureq_xfr();
    coll_sdrsp_xfr();
  join_none
endtask: run_phase

//-------------------------------------------------------------------
function void `THIS_CLASS::write(cache_txn_c t);
  cache_txn_c lookup = new t;
  if ((lookup.Type == L1_REQ)   && (t.Type_xfr == LOOKUP_XFR)) begin
    cdreq_lookup = lookup.Lookup;
    l1_lookup_q.push_back(lookup);
  end
  else if ((lookup.Type == SNP_REQ)  && (t.Type_xfr == LOOKUP_XFR)) begin
    snp_lookup_q.push_back(lookup);
  end
  else begin
    `uvm_fatal(m_msg_name, $sformatf("can not identify source of lookup package: %s", lookup.convert2string()))
  end
endfunction: write

//-------------------------------------------------------------------
task `THIS_CLASS::coll_l1_txn();
  cache_txn_c xfr;
  cache_txn_c txn;
  cache_txn_c lookup;

  forever begin
    wait(l1_xfr_q.size() > 0);
    xfr = new l1_xfr_q.pop_front();
    if(xfr.Type_xfr == CDREQ_XFR) begin
      txn = new();
      txn.cdreq_op    = xfr.cdreq_op;
      txn.cdreq_addr  = xfr.cdreq_addr;
      txn.cdreq_data  = xfr.cdreq_data;

      wait(l1_lookup_q.size() > 0);
      lookup = l1_lookup_q.pop_front();
      `uvm_info(m_msg_name, $sformatf("lookup: %s", lookup.convert2string()), UVM_DEBUG)
      txn.Lookup      = lookup.Lookup;
      txn.State       = lookup.State;
      txn.Idx         = lookup.Idx;
      txn.Way         = lookup.Way;
      txn.Evict_way   = lookup.Evict_way;
    end
    else if(xfr.Type_xfr == CUREQ_XFR) begin
      txn.cureq_op    = xfr.cureq_op;
      txn.cureq_addr  = xfr.cureq_addr;
    end
    else if(xfr.Type_xfr == CDRSP_XFR) begin
      txn.cdrsp_rsp   = xfr.cdrsp_rsp;
      txn.cdrsp_data  = xfr.cdrsp_data;
    end
    else if(xfr.Type_xfr == SDREQ_XFR) begin
      txn.sdreq_op    = xfr.sdreq_op;
      txn.sdreq_addr  = xfr.sdreq_addr;
      txn.sdreq_data  = xfr.sdreq_data;
    end
    else if(xfr.Type_xfr == SURSP_XFR) begin
      txn.sursp_rsp   = xfr.sursp_rsp;
      txn.sursp_data  = xfr.sursp_data;
    end
    else if(xfr.Type_xfr == CURSP_XFR) begin
      txn.cursp_rsp   = xfr.cursp_rsp;
      txn.cursp_data  = xfr.cursp_data;
      txn.Type        = L1_REQ;
      txn.Type_xfr    = L1_TXN;
      m_txn_ap.write(txn);
    end
    else begin
      `uvm_fatal(m_msg_name, $sformatf("can not identify transfer type: %s", xfr.Type_xfr))
    end
  end
endtask: coll_l1_txn

//-------------------------------------------------------------------
task `THIS_CLASS::coll_snp_txn();
  cache_txn_c xfr;
  cache_txn_c txn;
  cache_txn_c lookup;

  forever begin
    wait(snp_xfr_q.size() > 0);
    xfr = new snp_xfr_q.pop_front();
    if(xfr.Type_xfr == SUREQ_XFR) begin
      txn = new();
      txn.sureq_op    = xfr.sureq_op;
      txn.sureq_addr  = xfr.sureq_addr;

      wait(snp_lookup_q.size() > 0);
      lookup = snp_lookup_q.pop_front();
      `uvm_info(m_msg_name, $sformatf("lookup: %s", lookup.convert2string()), UVM_DEBUG)
      txn.Lookup      = lookup.Lookup;
      txn.State       = lookup.State;
      txn.Idx         = lookup.Idx;
      txn.Way         = lookup.Way;
      txn.Evict_way   = lookup.Evict_way;
    end
    else if(xfr.Type_xfr == CUREQ_XFR) begin
      txn.cureq_op    = xfr.cureq_op;
      txn.cureq_addr  = xfr.cureq_addr;
    end
    else if(xfr.Type_xfr == CDRSP_XFR) begin
      txn.cdrsp_rsp   = xfr.cdrsp_rsp;
      txn.cdrsp_data  = xfr.cdrsp_data;
    end
    else if(xfr.Type_xfr == SDREQ_XFR) begin
      txn.sdreq_op    = xfr.sdreq_op;
      txn.sdreq_addr  = xfr.sdreq_addr;
      txn.sdreq_data  = xfr.sdreq_data;
    end
    else if(xfr.Type_xfr == SURSP_XFR) begin
      txn.sursp_rsp   = xfr.sursp_rsp;
      txn.sursp_data  = xfr.sursp_data;
    end
    else if(xfr.Type_xfr == SDRSP_XFR) begin
      txn.sdrsp_rsp   = xfr.sdrsp_rsp;
      txn.sdrsp_data  = xfr.sdrsp_data;
      txn.Type        = SNP_REQ;
      txn.Type_xfr    = SNP_TXN;
      m_txn_ap.write(txn);
    end
    else begin
      `uvm_fatal(m_msg_name, $sformatf("can not identify transfer type: %s", xfr.Type_xfr))
    end
  end
endtask: coll_snp_txn

//-------------------------------------------------------------------
task `THIS_CLASS::coll_cdreq_xfr();
  cache_txn_c t;
  forever begin
    wait(`M_VIF.cdreq_valid && `M_VIF.cdreq_ready);
    t = new();
    t.Type_xfr    = CDREQ_XFR;
    t.cdreq_op    = cdreq_e'(`M_VIF.cdreq_op);
    t.cdreq_addr  = `M_VIF.cdreq_addr;
    t.cdreq_data  = `M_VIF.cdreq_data;

    `uvm_info(m_msg_name, $sformatf("%s", t.convert2string()), UVM_DEBUG);
    m_xfr_ap.write(t);
    l1_xfr_q.push_back(t);

    cdreq_ot      = 1;
    cdreq_addr_bf = `M_VIF.cdreq_addr;
    @`M_VIF;
  end
endtask: coll_cdreq_xfr

//-------------------------------------------------------------------
task `THIS_CLASS::coll_cursp_xfr();
  cache_txn_c t;
  forever begin
    wait(`M_VIF.cursp_valid && `M_VIF.cursp_ready);
    t = new();
    t.Type_xfr    = CURSP_XFR;
    t.cursp_rsp   = cursp_e'(`M_VIF.cursp_rsp);
    t.cursp_data  = `M_VIF.cursp_data;

    `uvm_info(m_msg_name, $sformatf("%s", t.convert2string()), UVM_DEBUG);
    m_xfr_ap.write(t);
    l1_xfr_q.push_back(t);

    cdreq_ot      = 0;
    cdreq_addr_bf = 0;
    @`M_VIF;
  end
endtask: coll_cursp_xfr

//-------------------------------------------------------------------
task `THIS_CLASS::coll_cureq_xfr();
  cache_txn_c t;
  forever begin
    wait(`M_VIF.cureq_valid && `M_VIF.cureq_ready);
    t = new();
    t.Type_xfr    = CUREQ_XFR;
    t.cureq_op    = cureq_e'(`M_VIF.cureq_op);
    t.cureq_addr  = `M_VIF.cureq_addr;

    `uvm_info(m_msg_name, $sformatf("%s", t.convert2string()), UVM_DEBUG);
    m_xfr_ap.write(t);

    if(sureq_ot && (`M_VIF.cureq_addr == sureq_addr_bf)) begin
      cureq_owner = "SUREQ";
      snp_xfr_q.push_back(t);
    end
    else if(cdreq_ot && (cdreq_lookup == EVICT_BLK)) begin
      cureq_owner = "CDREQ";
      l1_xfr_q.push_back(t);
    end
    else begin
      `uvm_fatal(m_msg_name, $sformatf("cureq_addr=0x%0h is not coresponding to any access, SUREQ=0x%0h", `M_VIF.sdreq_addr, sureq_addr_bf))
    end
    @`M_VIF;
  end
endtask: coll_cureq_xfr

//-------------------------------------------------------------------
task `THIS_CLASS::coll_cdrsp_xfr();
  cache_txn_c t;
  forever begin
    wait(`M_VIF.cdrsp_valid && `M_VIF.cdrsp_ready);
    t = new();
    t.Type_xfr    = CDRSP_XFR;
    t.cdrsp_rsp   = cdrsp_e'(`M_VIF.cdrsp_rsp);
    t.cdrsp_data  = `M_VIF.cdrsp_data;

    `uvm_info(m_msg_name, $sformatf("%s", t.convert2string()), UVM_DEBUG);
    m_xfr_ap.write(t);

    if(cureq_owner == "CDREQ")        l1_xfr_q.push_back(t);
    else if(cureq_owner == "SUREQ")   snp_xfr_q.push_back(t);
    else                              `uvm_fatal("SB_FAIL", "receives SURSP although SDREQ has not sent yet")
    cureq_owner = "NONE";
    @`M_VIF;
  end
endtask: coll_cdrsp_xfr

//-------------------------------------------------------------------
task `THIS_CLASS::coll_sdreq_xfr();
  cache_txn_c t;
  forever begin
    wait(`M_VIF.sdreq_valid && `M_VIF.sdreq_ready);
    t = new();
    t.Type_xfr    = SDREQ_XFR;
    t.sdreq_op    = sdreq_e'(`M_VIF.sdreq_op);
    t.sdreq_addr  = `M_VIF.sdreq_addr;
    t.sdreq_data  = `M_VIF.sdreq_data;

    `uvm_info(m_msg_name, $sformatf("%s", t.convert2string()), UVM_DEBUG);
    m_xfr_ap.write(t);

    if(sureq_ot && (`M_VIF.sdreq_addr == sureq_addr_bf)) begin
      sdreq_owner = "SUREQ";
      snp_xfr_q.push_back(t);
    end
    else if(cdreq_ot) begin
      sdreq_owner = "CDREQ";
      l1_xfr_q.push_back(t);
    end
    else begin
      `uvm_fatal(m_msg_name, $sformatf("sdreq_addr=0x%0h is not coresponding to any access, CDREQ=0x%0h or SUREQ=0x%0h", `M_VIF.sdreq_addr, cdreq_addr_bf, sureq_addr_bf))
    end
    @`M_VIF;
  end
endtask: coll_sdreq_xfr

//-------------------------------------------------------------------
task `THIS_CLASS::coll_sursp_xfr();
  cache_txn_c t;
  forever begin
    wait(`M_VIF.sursp_valid && `M_VIF.sursp_ready);
    t = new();
    t.Type_xfr    = SURSP_XFR;
    t.sursp_rsp   = sursp_e'(`M_VIF.sursp_rsp);
    t.sursp_data  = `M_VIF.sursp_data;

    `uvm_info(m_msg_name, $sformatf("%s", t.convert2string()), UVM_DEBUG);
    m_xfr_ap.write(t);

    if(sdreq_owner == "CDREQ")        l1_xfr_q.push_back(t);
    else if(sdreq_owner == "SUREQ")   snp_xfr_q.push_back(t);
    else                              `uvm_fatal("SB_FAIL", "receives SURSP although SDREQ has not sent yet")
    sdreq_owner = "NONE";
    @`M_VIF;
  end
endtask: coll_sursp_xfr

//-------------------------------------------------------------------
task `THIS_CLASS::coll_sureq_xfr();
  cache_txn_c t;
  forever begin
    wait(`M_VIF.sureq_valid && `M_VIF.sureq_ready);
    t = new();
    t.Type_xfr    = SUREQ_XFR;
    t.sureq_op    = sureq_e'(`M_VIF.sureq_op);
    t.sureq_addr  = `M_VIF.sureq_addr;

    `uvm_info(m_msg_name, $sformatf("%s", t.convert2string()), UVM_DEBUG);
    m_xfr_ap.write(t);
    snp_xfr_q.push_back(t);

    sureq_ot      = 1;
    sureq_addr_bf = `M_VIF.sureq_addr;
    @`M_VIF;
  end
endtask: coll_sureq_xfr

//-------------------------------------------------------------------
task `THIS_CLASS::coll_sdrsp_xfr();
  cache_txn_c t;
  forever begin
    wait(`M_VIF.sdrsp_valid && `M_VIF.sdrsp_ready);
    t = new();
    t.Type_xfr    = SDRSP_XFR;
    t.sdrsp_rsp   = sdrsp_e'(`M_VIF.sdrsp_rsp);
    t.sdrsp_data  = `M_VIF.sdrsp_data;

    `uvm_info(m_msg_name, $sformatf("%s\n", t.convert2string()), UVM_DEBUG);
    m_xfr_ap.write(t);
    snp_xfr_q.push_back(t);

    sureq_ot      = 0;
    sureq_addr_bf = 0;
    @`M_VIF;
  end
endtask: coll_sdrsp_xfr

`undef THIS_CLASS
`endif
