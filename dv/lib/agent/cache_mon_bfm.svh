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
  t.rx_l1_op    = l1_op_e'(`M_VIF.rx_l1_op);
  t.rx_l1_addr  = `M_VIF.rx_l1_addr;
  t.rx_l1_data  = `M_VIF.rx_l1_data;
  t.tx_l1_wait  = `M_VIF.tx_l1_wait;
  t.tx_l1_data  = `M_VIF.tx_l1_data;
  t.rx_snp_op   = snp_op_e'(`M_VIF.rx_snp_op);
  t.rx_snp_addr = `M_VIF.rx_snp_addr;
  t.rx_snp_data = `M_VIF.rx_snp_data;
  t.rx_snp_rsp  = snp_rsp_e'(`M_VIF.rx_snp_rsp);
  t.tx_snp_op   = snp_op_e'(`M_VIF.tx_snp_op);
  t.tx_snp_addr = `M_VIF.tx_snp_addr;
  t.tx_snp_data = `M_VIF.tx_snp_data;
  t.tx_snp_rsp  = snp_rsp_e'(`M_VIF.tx_snp_rsp);
endfunction: asg_txn

`undef M_VIF
`undef THIS_CLASS
`endif
