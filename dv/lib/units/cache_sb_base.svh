`ifndef CACHE_SB_BASE_SVH
`define CACHE_SB_BASE_SVH
`define THIS_CLASS cache_sb_base_c
`define M_VIF m_vif.mon_cb

class `THIS_CLASS extends uvm_scoreboard;
  `uvm_component_utils(`THIS_CLASS)

  uvm_analysis_imp  #(cache_txn_c, `THIS_CLASS) m_xfr_a_imp;
  uvm_analysis_port #(cache_txn_c)              m_lookup_ap;

  virtual cache_if      m_vif;
          cache_model_c m_cache;

  string    m_msg_name  = "SB";
  string    sdreq_owner = "NONE";
  string    hdl_path;

  bit       cdreq_ot;
  int       cdreq_error_count;
  cdreq_e   cdreq_op_req_bf;
  address_t cdreq_addr_req_bf;
  data_t    cdreq_data_req_bf;
  lookup_e  cdreq_lookup;
  idx_t     cdreq_idx_bf;
  way_t     cdreq_way_bf;
  st_e      cdreq_st_prev;
  tag_t     cdreq_tag_prev;
  data_t    cdreq_data_prev;
  way_t     cdreq_evict_way_prev;

  bit       sureq_ot;
  int       sureq_error_count;
  bit       sureq_hit;
  sureq_e   sureq_op_req_bf;
  address_t sureq_addr_req_bf;
  lookup_e  sureq_lookup;
  idx_t     sureq_idx_bf;
  way_t     sureq_way_bf;
  st_e      sureq_st_prev;
  tag_t     sureq_tag_prev;
  data_t    sureq_data_prev;
  way_t     sureq_evict_way_prev;

  bit         reset_check;
  cache_txn_c l1_xfr_q[$];
  cache_txn_c snp_xfr_q[$];

  extern  virtual function  void  build_phase(uvm_phase phase);
  extern  virtual function  void  check_phase(uvm_phase phase);

  extern  virtual task            wait_nxt_l1_xfr(ref cache_txn_c t);
  extern  virtual task            wait_nxt_snp_xfr(ref cache_txn_c t);
  extern  virtual function  void  comp_model_vs_rtl(string type_req="ALL", idx_t idx=0, way_t way=0);
  extern  virtual function  void  write(cache_txn_c t);

  function new(string name="`THIS_CLASS", uvm_component parent);
    super.new(name, parent);
  endfunction: new

endclass: `THIS_CLASS

// ------------------------------------------------------------------
function void `THIS_CLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(virtual cache_if)::get(this, "", "cac_if", m_vif)) uvm_report_fatal(m_msg_name, "Cannot get virtual cache interface");
  m_xfr_a_imp = new("m_xfr_a_imp", this);
  m_lookup_ap = new("m_lookup_ap", this);
  m_cache     = cache_model_c::type_id::create("cache", this);
endfunction: build_phase

// ------------------------------------------------------------------
function void `THIS_CLASS::check_phase(uvm_phase phase);
  super.check_phase(phase);

`ifdef HAS_SB
  comp_model_vs_rtl("ALL");
`endif
endfunction: check_phase

// ------------------------------------------------------------------
task `THIS_CLASS::wait_nxt_l1_xfr(ref cache_txn_c t);
  while(l1_xfr_q.size() == 0) begin
    @`M_VIF;
  end
  t = l1_xfr_q.pop_front();
  if(t.Type_xfr != CDREQ_XFR)
    `uvm_info(m_msg_name, $sformatf("%s", t.convert2string()), UVM_MEDIUM)
endtask: wait_nxt_l1_xfr

// ------------------------------------------------------------------
task `THIS_CLASS::wait_nxt_snp_xfr(ref cache_txn_c t);
  string tag;
  while(snp_xfr_q.size() == 0) begin
    @`M_VIF;
  end
  t = snp_xfr_q.pop_front();
  if(t.Type_xfr != SUREQ_XFR)
    `uvm_info(m_msg_name, $sformatf("%s", t.convert2string()), UVM_MEDIUM)
endtask: wait_nxt_snp_xfr

// ------------------------------------------------------------------
function void `THIS_CLASS::comp_model_vs_rtl(string type_req="ALL", idx_t idx=0, way_t way=0);
  int                       error_count;
  bit [`VIP_RAM_WIDTH-1:0]  read_rtl_blk;

  if(!(type_req inside {"ALL", "CDREQ", "SUREQ"}))
    `uvm_fatal(m_msg_name, $sformatf("can not identify type of request:%s", type_req))
  else begin
    for(int i = 0; i < (`VIP_NUM_BLK/`VIP_NUM_WAY); i++) begin
      // check mem
      for(int ii = 0; ii < `VIP_NUM_WAY; ii++) begin
        hdl_path = $sformatf("cache_mem_tb_top.dut.mem[%0d][%0d]", i, ii);
        if(!uvm_hdl_read(hdl_path, read_rtl_blk))
          `uvm_fatal(m_msg_name, $sformatf("read hdl path fail, hdl_path=%s", hdl_path))
        if((type_req == "ALL") || ((type_req inside {"CDREQ", "SUREQ"}) && (i == idx) && (ii == way))) begin
          if(st_e'(read_rtl_blk[`ST]) != m_cache.mem[i][ii].state) begin
            `SB_ERROR(type_req, $sformatf("state mismatch: IDX=%0d  WAY=%0d  RTL=0x%0s  MODEL=0x%s", i, ii, st_e'(read_rtl_blk[`ST]), m_cache.mem[i][ii].state))
            error_count++;
          end
          if(read_rtl_blk[`RAM_TAG] != m_cache.mem[i][ii].tag) begin
            `SB_ERROR(type_req, $sformatf("tag mismatch: IDX=%0d  WAY=%0d  RTL=0x%0h  MODEL=0x%0h", i, ii, read_rtl_blk[`RAM_TAG], m_cache.mem[i][ii].tag))
            error_count++;
          end
          if(read_rtl_blk[`DAT] != m_cache.mem[i][ii].data) begin
            `SB_ERROR(type_req, $sformatf("data mismatch: IDX=%0d  WAY=%0d  RTL=0x%0h  MODEL=0x%0h", i, ii, read_rtl_blk[`DAT], m_cache.mem[i][ii].data))
            error_count++;
          end
        end
      end
      // check replacement
`ifdef PLRU_REPL
      hdl_path = $sformatf("cache_mem_tb_top.dut.repl_tree[%0d]", i);
      if(!uvm_hdl_read(hdl_path, read_rtl_blk))
        `uvm_fatal(m_msg_name, $sformatf("read hdl path fail, hdl_path=%s", hdl_path))
      if((type_req == "ALL") || ((type_req inside {"CDREQ", "SUREQ"}) && (i == idx))) begin
        if(read_rtl_blk[2:0] != m_cache.plru_tree_bit[i]) begin
          error_count++;
          `SB_ERROR(type_req, $sformatf("replacement bit mismatch: IDX=%0d  RTL=0x%0h  MODEL=0x%0h", i, read_rtl_blk[2:0], m_cache.plru_tree_bit[i]))
        end
      end
`elsif THESIS_REPL
`else
  `uvm_fatal(m_msg_name, "can not identify replacement policy")
`endif // PLRU_REPL
    end
  end

  if(error_count == 0) begin
    if(type_req inside {"CDREQ", "SUREQ"})
      `uvm_info(m_msg_name, $sformatf("no mismatch between RTL and MODEL at: IDX=%0d  WAY=%0d", idx, way), UVM_LOW)
    else
      `uvm_info(m_msg_name, $sformatf("no mismatch between RTL and MODEL at all blocks"), UVM_LOW)
  end
  else
    `uvm_error(m_msg_name, $sformatf("there are %0d mismatch between RTL and MODEL", error_count))
endfunction: comp_model_vs_rtl

// ------------------------------------------------------------------
function void `THIS_CLASS::write(cache_txn_c t);
`ifdef HAS_SB
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
    if(sdreq_owner == "CDREQ")      l1_xfr_q.push_back(t_loc);
    else if(sdreq_owner == "SUREQ") snp_xfr_q.push_back(t_loc);
    else                            `uvm_fatal("SB_FAIL", "receives SURSP although SDREQ has not sent yet")
    sdreq_owner = "NONE";
  end
  else
    `uvm_fatal("SB_FAIL", "can not define transfer type")
`endif // HAS_SB
endfunction: write

`undef M_VIF
`undef THIS_CLASS
`endif
