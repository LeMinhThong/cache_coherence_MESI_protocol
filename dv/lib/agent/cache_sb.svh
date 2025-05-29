`ifndef CACHE_SB_SVH
`define CACHE_SB_SVH
`define THIS_CLASS cache_sb_c
`define M_VIF m_vif.mon_cb
`define STRINGIFY(x) `"x`"

class `THIS_CLASS extends uvm_scoreboard;
  `uvm_component_utils(`THIS_CLASS)

  uvm_analysis_imp #(cache_txn_c, `THIS_CLASS) default_a_imp;

  virtual cache_if m_vif;

  cache_model_c m_cache;

  string        m_msg_name      = "SB";
  string        sdreq_owner     = "NONE";

  cdreq_e       cdreq_op_loc;
  address_t     cdreq_addr_loc  = -1;

  address_t     sureq_addr_loc  = -1;
  bit           reset_check;
  cache_txn_c   l1_xfr_q[$];
  cache_txn_c   snp_xfr_q[$];

  extern  virtual function  void  build_phase(uvm_phase phase);
  extern  virtual task            run_phase(uvm_phase phase);
  extern  virtual task            reset_monitoring();
  extern  virtual task            wait_nxt_l1_xfr(ref cache_txn_c t);
  extern  virtual task            wait_nxt_snp_xfr(ref cache_txn_c t);
  extern  virtual task            check_cdreq();
  extern  virtual task            check_sureq();
  extern  virtual function  void  check_cache_sync();
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
  m_cache = cache_model_c::type_id::create("cache", this);
endfunction: build_phase

// ------------------------------------------------------------------
task `THIS_CLASS::run_phase(uvm_phase phase);
  fork
    begin
      reset_monitoring();
    end

    begin
      forever begin
        wait(reset_check == 1'b1);
        fork
          begin
            wait(reset_check == 1'b0);
          end
          begin
            check_cdreq();
          end
          begin
            check_sureq();
          end
        join_any
        `uvm_info(m_msg_name, "RST_DEBUG: out-of-fork", UVM_INFO)
        disable fork;
      end
    end
  join_none
endtask: run_phase

// ------------------------------------------------------------------
task `THIS_CLASS::reset_monitoring();
  forever begin
    fork
      begin
        @(negedge `M_VIF.rst_n);
        `uvm_info(m_msg_name, "Reset is handling", UVM_LOW)
        reset_check = 0;
        m_cache.init_cache();
        sdreq_owner     = "NONE";
        cdreq_addr_loc  = -1;
        sureq_addr_loc  = -1;
        l1_xfr_q.delete();
        snp_xfr_q.delete();
      end

      begin
        @(posedge `M_VIF.rst_n);
        `uvm_info(m_msg_name, "Reset has completed", UVM_LOW)
        repeat(3) @(`M_VIF)
        reset_check = 1;
      end
    join
  end
endtask: reset_monitoring

// ------------------------------------------------------------------
task `THIS_CLASS::wait_nxt_l1_xfr(ref cache_txn_c t);
  while(l1_xfr_q.size() == 0) @`M_VIF;
  t = l1_xfr_q.pop_front();
  `uvm_info(m_msg_name, $sformatf("transfer:%s", t.convert2string()), UVM_MEDIUM)
endtask: wait_nxt_l1_xfr

// ------------------------------------------------------------------
task `THIS_CLASS::wait_nxt_snp_xfr(ref cache_txn_c t);
  while(snp_xfr_q.size() == 0) @`M_VIF;
  t = snp_xfr_q.pop_front();
  `uvm_info(m_msg_name, $sformatf("transfer:%s", t.convert2string()), UVM_MEDIUM)
endtask: wait_nxt_snp_xfr

// ------------------------------------------------------------------
function void `THIS_CLASS::check_cache_sync();
  string                        hdl_path;
  bit     [`VIP_RAM_WIDTH-1:0]  read_rtl_blk;
  st_e                          state;
  tag_t                         tag;
  data_t                        data;

  for(int i = 0; i < `VIP_NUM_BLK; i++) begin
    hdl_path = $sformatf("cache_mem_tb_top.dut.mem[%0d]", i);
    if(!uvm_hdl_read(hdl_path, read_rtl_blk))
      `uvm_fatal(m_msg_name, "uvm_hdl_read fail")
    else begin
      state = st_e'(read_rtl_blk[`ST]);
      tag   = read_rtl_blk[`RAM_TAG];
      data  = read_rtl_blk[`DAT];

      if(state != m_cache.m_cache[i].state)
        `uvm_error(m_msg_name, $sformatf("[block=%0d] state mismatch rtl_mem=0x%0h  model_mem=0x%0h", i, state, m_cache.m_cache[i].state))
      if(tag != m_cache.m_cache[i].tag)
        `uvm_error(m_msg_name, $sformatf("[block=%0d] tag mismatch rtl_mem=0x%0h  model_mem=0x%0h", i, tag, m_cache.m_cache[i].tag))
      if(data != m_cache.m_cache[i].data)
        `uvm_error(m_msg_name, $sformatf("[block=%0d] data mismatch rtl_mem=0x%0h  model_mem=0x%0h", i, data, m_cache.m_cache[i].data))
    end
  end
endfunction: check_cache_sync

// ------------------------------------------------------------------
task `THIS_CLASS::check_cdreq();
  cache_txn_c t;
  bit         ot;

  forever begin
    wait_nxt_l1_xfr(t);
    if((t.Type_xfr == CDREQ_XFR) && (ot == 1))
      `uvm_error(m_msg_name, "receive new CDREQ_XFR while previous transaction is outstanding")
    else if((t.Type_xfr == CDREQ_XFR) && (ot == 0)) begin
      ot = 1;
      if(t.cdreq_op == CDREQ_RD) begin
        cdreq_op_loc    = t.cdreq_op;
        cdreq_addr_loc  = t.cdreq_addr;
        if(m_cache.get_state(cdreq_addr_loc) == INVALID) begin
          wait_nxt_l1_xfr(t);
          if(!((t.Type_xfr == SDREQ_XFR) && (t.sdreq_op == SDREQ_RD) && (t.sdreq_addr == cdreq_addr_loc)))
            `uvm_error(m_msg_name, $sformatf("expected  [SDREQ_XFR]  sdreq_op=SDREQ_RD  sdreq_addr=0x%0h --- actually:%s", cdreq_addr_loc, t.convert2string()))
          else begin
            wait_nxt_l1_xfr(t);
            if(!((t.Type_xfr == SURSP_XFR) && (t.sursp_rsp inside {SURSP_FETCH, SURSP_SNOOP})))
              `uvm_error(m_msg_name, $sformatf("expected  [SURSP_XFR]  sursp_rsp=(SURSP_FETCH || SURSP_SNOOP) --- actually:%s", t.convert2string()))
            else begin
              if(t.sursp_rsp == SURSP_FETCH)
                m_cache.set_state(cdreq_addr_loc, EXCLUSIVE);
              else // SURSP_SNOOP
                m_cache.set_state(cdreq_addr_loc, SHARED);
              m_cache.set_tag(cdreq_addr_loc);
              m_cache.set_data(cdreq_addr_loc, t.sursp_data);
              wait_nxt_l1_xfr(t);
              if(!((t.Type_xfr == CURSP_XFR) && (t.cursp_rsp == CURSP_OKAY) && (t.cursp_data == m_cache.get_data(cdreq_addr_loc))))
                `uvm_error(m_msg_name, $sformatf("expected  [CURSP_XFR]  cursp_rsp=CURSP_OKAY  cursp_data=0x%0h --- actually:%s", m_cache.get_data(cdreq_addr_loc), t.convert2string()))
              else begin
                check_cache_sync();
                `uvm_info(m_msg_name, $sformatf("PASSED senario: cdreq_op=%s  cdreq_addr=0x%0h", cdreq_op_loc.name(), cdreq_addr_loc), UVM_LOW)
                cdreq_op_loc    = CDREQ_RD;
                cdreq_addr_loc  = -1;
                ot              = 0;
              end
            end
          end
        end
        else if(m_cache.get_state(cdreq_addr_loc) inside {EXCLUSIVE, SHARED, MODIFIED}) begin
        end
        else begin
          `uvm_error(m_msg_name, $sformatf("corner case reached: cdreq_op=%s  cdreq_addr=0x%0h  blk_st=%s", cdreq_op_loc.name(), cdreq_addr_loc, m_cache.get_state(cdreq_addr_loc)))
        end
      end
      else if(t.cdreq_op == CDREQ_RFO) begin
      end
      else if(t.cdreq_op == CDREQ_WB) begin
      end
      else if(t.cdreq_op == CDREQ_MD) begin
      end
      else begin
        `uvm_error(m_msg_name, "cannot identify CDREQ opcode")
      end
    end
    else begin
      `uvm_error(m_msg_name, "receives other sub-transfers before request transfer is opened")
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
    l1_xfr_q.push_back(t_loc);
  end

  else if(t_loc.Type_xfr inside {SUREQ_XFR, SDRSP_XFR, CUREQ_XFR, CDRSP_XFR}) begin
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
  end

  else
  `uvm_fatal(m_msg_name, "can not define transfer type")
endfunction: write

`undef THIS_CLASS
`endif
