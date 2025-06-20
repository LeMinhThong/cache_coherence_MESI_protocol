`ifndef CACHE_MON_SVH
`define CACHE_MON_SVH
`define THIS_CLASS cache_mon_c
`define M_VIF m_vif.mon_cb

class `THIS_CLASS extends uvm_monitor;
  `uvm_component_utils(`THIS_CLASS);

  uvm_analysis_port #(cache_txn_c) default_ap;

  virtual cache_if m_vif; 

  string m_msg_name = "MON";

  extern  virtual function  void  build_phase(uvm_phase phase);
  extern  virtual task            run_phase(uvm_phase phase);

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
  default_ap = new("default_ap", this);
  if(!uvm_config_db#(virtual cache_if)::get(this, "", "cac_if", m_vif)) uvm_report_fatal("MONITOR_BFM", "Cannot get virtual cache interface");
endfunction: build_phase

//-------------------------------------------------------------------
task `THIS_CLASS::run_phase(uvm_phase phase);
  fork
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
    default_ap.write(t);
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
    default_ap.write(t);
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
    default_ap.write(t);
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
    default_ap.write(t);
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
    default_ap.write(t);
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
    default_ap.write(t);
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
    default_ap.write(t);
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
    default_ap.write(t);
    @`M_VIF;
  end
endtask: coll_sdrsp_xfr

`undef THIS_CLASS
`endif
