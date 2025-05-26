`ifndef CACHE_MON_BFM
`define CACHE_MON_BFM
`define THIS_CLASS cache_mon_bfm_c
`define M_VIF m_vif.mon_cb

class `THIS_CLASS extends uvm_component;
  `uvm_component_utils(`THIS_CLASS)

  virtual cache_if m_vif;

  extern  virtual function  void  build_phase(uvm_phase phase);
  extern  virtual task            run_phase(uvm_phase phase);
  extern  virtual task            coll_txn();
  extern  virtual function  void  asg_txn(cache_txn_c t);

  function new(string name="`THIS_CLASS", uvm_component parent);
    super.new(name, parent);
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
function void `THIS_CLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(virtual cache_if)::get(this, "", "cac_if", m_vif)) uvm_report_fatal("MONITOR_BFM", "Cannot get virtual cache interface");
endfunction: build_phase

//-------------------------------------------------------------------
task `THIS_CLASS::run_phase(uvm_phase phase);
  fork
    coll_txn();
  join_none
endtask: run_phase

//-------------------------------------------------------------------
task `THIS_CLASS::coll_txn();
  cache_txn_c t;
  cache_txn_c prev_t;
  t = new();
  `uvm_info("MONITOR_BFM", "start collect transaction", UVM_DEBUG)
  forever begin
    @`M_VIF;
    asg_txn(t);
    `uvm_info("MONITOR_BFM", $sformatf("%s", t.convert2string()), UVM_LOW);
  end
endtask: coll_txn

//-------------------------------------------------------------------
function void `THIS_CLASS::asg_txn(cache_txn_c t);
//  t.cdreq_op    = l1_op_e'(`M_VIF.cdreq_op);
//  t.cdreq_addr  = `M_VIF.cdreq_addr;
//  t.cdreq_data  = `M_VIF.cdreq_data;
//  t.tx_l1_wait  = `M_VIF.tx_l1_wait;
//  t.cursp_data  = `M_VIF.cursp_data;
//  t.sureq_op   = snp_op_e'(`M_VIF.sureq_op);
//  t.sureq_addr = `M_VIF.sureq_addr;
//  t.sursp_data = `M_VIF.sursp_data;
//  t.sursp_rsp  = snp_rsp_e'(`M_VIF.sursp_rsp);
//  t.sdreq_op   = snp_op_e'(`M_VIF.sdreq_op);
//  t.sdreq_addr = `M_VIF.sdreq_addr;
//  t.sdrsp_data = `M_VIF.sdrsp_data;
//  t.sdrsp_rsp  = snp_rsp_e'(`M_VIF.sdrsp_rsp);
endfunction: asg_txn

`undef M_VIF
`undef THIS_CLASS
`endif
