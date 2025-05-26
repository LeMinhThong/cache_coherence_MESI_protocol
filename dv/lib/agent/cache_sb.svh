`ifndef CACHE_SB_SVH
`define CACHE_SB_SVH
`define THIS_CLASS cache_sb_c
`define M_VIF m_vif.mon_cb

class `THIS_CLASS extends uvm_scoreboard;
  `uvm_component_utils(`THIS_CLASS)

  uvm_analysis_imp #(cache_txn_c, `THIS_CLASS) default_a_imp;

  virtual cache_if m_vif;

  string      m_msg_name = "SB";
  string      sdreq_owner = "NONE";
  address_t   cdreq_addr_loc = -1;
  address_t   sureq_addr_loc = -1;

  cache_txn_c l1_xfr_q[$];
  cache_txn_c snp_xfr_q[$];

  extern  virtual function  void  build_phase(uvm_phase phase);
  extern  virtual task            run_phase(uvm_phase phase);
  extern  virtual task            check_cdreq();
  extern  virtual task            check_sureq();
  extern  virtual function  void  write(cache_txn_c t);

  function new(string name="`THIS_CLASS", uvm_component parent);
    super.new(name, parent);
    if(!uvm_config_db#(virtual cache_if)::get(this, "", "cac_if", m_vif)) uvm_report_fatal(m_msg_name, "Cannot get virtual cache interface");
  endfunction: new
endclass: `THIS_CLASS

// ------------------------------------------------------------------
function void `THIS_CLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
  default_a_imp = new("default_a_imp", this);
endfunction: build_phase

// ------------------------------------------------------------------
task `THIS_CLASS::run_phase(uvm_phase phase);
  fork
    check_cdreq();
    check_sureq();
  join_none
endtask: run_phase

// ------------------------------------------------------------------
task `THIS_CLASS::check_cdreq();
  cache_txn_c t;
  forever begin
    @`M_VIF;
    while(l1_xfr_q.size() > 0) begin
      t = l1_xfr_q.pop_front();
    end
  end
endtask: check_cdreq

// ------------------------------------------------------------------
task `THIS_CLASS::check_sureq();
  cache_txn_c t;
  forever begin
    @`M_VIF;
    while(snp_xfr_q.size() > 0) begin
      t = snp_xfr_q.pop_front();
    end
  end
endtask: check_sureq

// ------------------------------------------------------------------
function void `THIS_CLASS::write(cache_txn_c t);
  cache_txn_c t_loc = new t;

  if(t_loc.Type_xfr inside {CDREQ_XFR, CURSP_XFR}) begin
    if(t_loc.Type_xfr == CDREQ_XFR) begin
      cdreq_addr_loc = t_loc.cdreq_addr;
    end
    l1_xfr_q.push_back(t_loc);
  end

  else if(t_loc.Type_xfr inside {SUREQ_XFR, SDRSP_XFR, CUREQ_XFR, CDRSP_XFR}) begin
    if(t_loc.Type_xfr == SUREQ_XFR) begin
      sureq_addr_loc = t_loc.sureq_addr;
    end
    snp_xfr_q.push_back(t_loc);
  end

  else if(t_loc.Type_xfr == SDREQ_XFR) begin
    if(t_loc.sdreq_addr == cdreq_addr_loc) begin
      sdreq_owner = "CDREQ";
      l1_xfr_q.push_back(t_loc);
    end
    else if(t_loc.sdreq_addr == sureq_addr_loc) begin
      sdreq_owner = "SUREQ";
      snp_xfr_q.push_back(t_loc);
    end
    else
      `uvm_fatal(m_msg_name, $sformatf("sdreq_addr=0x%0h is not coresponding to any access, CDREQ=0x%0h or SUREQ=0x%0h", t_loc.sdreq_addr, cdreq_addr_loc, sureq_addr_loc))
  end
  
  else if(t_loc.Type_xfr == SURSP_XFR) begin
    if(sdreq_owner == "CDREQ")
      l1_xfr_q.push_back(t_loc);
    else if(sdreq_owner == "SUREQ")
      snp_xfr_q.push_back(t_loc);
    else
      `uvm_fatal(m_msg_name, "receives SURSP although SDREQ has not sent yet")

    sdreq_owner = "NONE";
    cdreq_addr_loc = -1;
    sureq_addr_loc = -1;
  end

  else
  `uvm_fatal(m_msg_name, "can not define transfer type")
endfunction: write

`undef THIS_CLASS
`endif
