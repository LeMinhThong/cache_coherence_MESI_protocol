`ifndef CACHE_SB_BASE_SVH
`define CACHE_SB_BASE_SVH
`define THIS_CLASS cache_sb_base_c
`define M_VIF m_vif.mon_cb

class `THIS_CLASS extends uvm_scoreboard;
  `uvm_component_utils(`THIS_CLASS)

  uvm_analysis_imp #(cache_txn_c, `THIS_CLASS) default_a_imp;

  virtual cache_if      m_vif;
          cache_model_c m_cache;

  string                    m_msg_name  = "SB";
  string                    sdreq_owner = "NONE";
  string                    hdl_path;

  bit                       cdreq_ot;
  int                       cdreq_error_count;
  cdreq_e                   cdreq_op_req_bf;
  address_t                 cdreq_addr_req_bf;
  data_t                    cdreq_data_req_bf;
  st_e                      cdreq_st_prev;
  tag_t                     cdreq_tag_prev;
  data_t                    cdreq_data_prev;

  bit                       sureq_ot;
  int                       sureq_error_count;
  sureq_e                   sureq_op_req_bf;
  address_t                 sureq_addr_req_bf;
  st_e                      sureq_st_prev;
  tag_t                     sureq_tag_prev;
  data_t                    sureq_data_prev;

  bit                       reset_check;
  cache_txn_c               l1_xfr_q[$];
  cache_txn_c               snp_xfr_q[$];

  extern  virtual function  void  build_phase(uvm_phase phase);
  extern  virtual function  void  check_phase(uvm_phase phase);

  extern  virtual task            wait_nxt_l1_xfr(ref cache_txn_c t);
  extern  virtual task            wait_nxt_snp_xfr(ref cache_txn_c t);
  extern  virtual function  void  comp_model_vs_rtl(string type_req="ALL", address_t addr=0);
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
  m_cache       = cache_model_c::type_id::create("cache", this);
endfunction: build_phase

// ------------------------------------------------------------------
function void `THIS_CLASS::check_phase(uvm_phase phase);
  super.check_phase(phase);
  comp_model_vs_rtl("ALL");
endfunction: check_phase

// ------------------------------------------------------------------
task `THIS_CLASS::wait_nxt_l1_xfr(ref cache_txn_c t);
  while(l1_xfr_q.size() == 0) begin
    @`M_VIF;
  end
  t = l1_xfr_q.pop_front();
  `uvm_info(m_msg_name, $sformatf("send xfr:%s", t.convert2string()), UVM_MEDIUM)
endtask: wait_nxt_l1_xfr

// ------------------------------------------------------------------
task `THIS_CLASS::wait_nxt_snp_xfr(ref cache_txn_c t);
  while(snp_xfr_q.size() == 0) begin
    @`M_VIF;
  end
  t = snp_xfr_q.pop_front();
  `uvm_info(m_msg_name, $sformatf("send xfr:%s", t.convert2string()), UVM_MEDIUM)
endtask: wait_nxt_snp_xfr

// ------------------------------------------------------------------
function void `THIS_CLASS::comp_model_vs_rtl(string type_req="ALL", address_t addr=0);
  int                       error_count;
  bit [`VIP_RAM_WIDTH-1:0]  read_rtl_blk;

  if(!(type_req inside {"ALL", "CDREQ", "SUREQ"}))
    `uvm_fatal(m_msg_name, $sformatf("can not identify type of request:%s", type_req))
  else begin
    for(int i = 0; i < `VIP_NUM_BLK; i++) begin
      hdl_path = $sformatf("cache_mem_tb_top.dut.mem[%0d]", i);
      if(!uvm_hdl_read(hdl_path, read_rtl_blk))
        `uvm_fatal(m_msg_name, "uvm_hdl_read fail")
      else begin
        if((type_req == "ALL") || ((type_req inside {"CDREQ", "SUREQ"}) && (i == addr[`IDX]))) begin
          if(st_e'(read_rtl_blk[`ST]) != m_cache.m_cache[i].state) begin
            `SB_ERROR(type_req, $sformatf("[block=%0d] state mismatch rtl_mem=0x%0h  model_mem=0x%s", i, st_e'(read_rtl_blk[`ST]), m_cache.m_cache[i].state))
            error_count++;
          end
          if(read_rtl_blk[`RAM_TAG] != m_cache.m_cache[i].tag) begin
            `SB_ERROR(type_req, $sformatf("[block=%0d] tag mismatch rtl_mem=0x%0h  model_mem=0x%0h", i, read_rtl_blk[`RAM_TAG], m_cache.m_cache[i].tag))
            error_count++;
          end
          if(read_rtl_blk[`DAT] != m_cache.m_cache[i].data) begin
            `SB_ERROR(type_req, $sformatf("[block=%0d] data mismatch rtl_mem=0x%0h  model_mem=0x%0h", i, read_rtl_blk[`DAT], m_cache.m_cache[i].data))
            error_count++;
          end
        end
      end
    end
    if(error_count == 0) begin
      if(type_req inside {"CDREQ", "SUREQ"})
        `uvm_info(m_msg_name, $sformatf("no mismatch between RTL and MODEL at: block[%0h]", addr[`IDX]), UVM_LOW)
      else
        `uvm_info(m_msg_name, $sformatf("no mismatch between RTL and MODEL at all blocks"), UVM_LOW)
    end
    else
      `uvm_error(m_msg_name, $sformatf("has %0d mismatch between RTL and MODEL", error_count))
  end
endfunction: comp_model_vs_rtl

// ------------------------------------------------------------------
function void `THIS_CLASS::write(cache_txn_c t);
  cache_txn_c t_loc = new t;

  if(t_loc.Type_xfr inside {CDREQ_XFR, CURSP_XFR}) begin
    l1_xfr_q.push_back(t_loc);
  end
  else if(t_loc.Type_xfr inside {SUREQ_XFR, SDRSP_XFR, CUREQ_XFR, CDRSP_XFR}) begin
    snp_xfr_q.push_back(t_loc);
  end
  else if(t_loc.Type_xfr == SDREQ_XFR) begin
    if(cdreq_ot && (t_loc.sdreq_addr == cdreq_addr_req_bf)) begin
      sdreq_owner = "CDREQ";
      l1_xfr_q.push_back(t_loc);
    end
    else if(sureq_ot && (t_loc.sdreq_addr == sureq_addr_req_bf)) begin
      sdreq_owner = "SUREQ";
      snp_xfr_q.push_back(t_loc);
    end
    else
      `uvm_fatal("SB_FAIL", $sformatf("sdreq_addr=0x%0h is not coresponding to any access, CDREQ=0x%0h or SUREQ=0x%0h", t_loc.sdreq_addr, cdreq_addr_req_bf, sureq_addr_req_bf))
  end
  else if(t_loc.Type_xfr == SURSP_XFR) begin
    if(sdreq_owner == "CDREQ")
      l1_xfr_q.push_back(t_loc);
    else if(sdreq_owner == "SUREQ")
      snp_xfr_q.push_back(t_loc);
    else
      `uvm_fatal("SB_FAIL", "receives SURSP although SDREQ has not sent yet")
    sdreq_owner = "NONE";
  end
  else
    `uvm_fatal("SB_FAIL", "can not define transfer type")
endfunction: write

`undef THIS_CLASS
`endif
