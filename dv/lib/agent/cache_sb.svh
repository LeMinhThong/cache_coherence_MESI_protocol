`ifndef CACHE_SB_SVH
`define CACHE_SB_SVH
`define THIS_CLASS cache_sb_c

class `THIS_CLASS extends cache_sb_base_c;
  `uvm_component_utils(`THIS_CLASS)

  extern  virtual function  void  build_phase(uvm_phase phase);
  extern  virtual task            run_phase(uvm_phase phase);
  extern  virtual task            reset_monitoring();
  extern  virtual task            check_cdreq();
  extern  virtual task            check_sureq();

  function new(string name="`THIS_CLASS", uvm_component parent);
    super.new(name, parent);
  endfunction: new
endclass:`THIS_CLASS

// ------------------------------------------------------------------
function void `THIS_CLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
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
        sdreq_owner   = "NONE";
        cdreq_addr_req_bf = -1;
        sureq_addr_req_bf = -1;
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
task `THIS_CLASS::check_cdreq();
  cache_txn_c t;

  forever begin
    wait_nxt_l1_xfr(t);
    if((t.Type_xfr == CDREQ_XFR) && (cdreq_ot == 1))
      `uvm_fatal("SB_FAIL", "receive new CDREQ_XFR while previous transaction is outstanding")
    else if((t.Type_xfr == CDREQ_XFR) && (cdreq_ot == 0)) begin
      cdreq_ot          = 1;
      cdreq_pass        = 0;
      cdreq_op_req_bf   = t.cdreq_op;
      cdreq_addr_req_bf = t.cdreq_addr;
      cdreq_data_req_bf = t.cdreq_data;
      cdreq_st_prev     = m_cache.get_state(cdreq_addr_req_bf);
      cdreq_tag_prev    = m_cache.get_tag(cdreq_addr_req_bf);
      cdreq_data_prev   = m_cache.get_data(cdreq_addr_req_bf);
      `uvm_info(m_msg_name,   $sformatf("--------------------------------------------------"), UVM_LOW)
      `uvm_info("REC_CDREQ",  $sformatf("reiceves request from CDREQ"), UVM_LOW)
      `uvm_info(m_msg_name,   $sformatf("OP=%s  ADDR=0x%0h  DAT=0x%0h", cdreq_op_req_bf, cdreq_addr_req_bf, cdreq_data_req_bf), UVM_LOW)
      `uvm_info(m_msg_name,   $sformatf("ST=%s  TAG=0x%0h  DAT=0x%0h", cdreq_st_prev, cdreq_tag_prev, cdreq_data_prev), UVM_LOW)
      `uvm_info(m_msg_name,   $sformatf("--------------------------------------------------"), UVM_LOW)

      if(t.cdreq_op == CDREQ_RD) begin
        if(cdreq_st_prev == INVALID) begin
          wait_nxt_l1_xfr(t);
          if(!((t.Type_xfr == SDREQ_XFR) && (t.sdreq_op == SDREQ_RD) && (t.sdreq_addr == cdreq_addr_req_bf)))
            `uvm_error("SB_FAIL", $sformatf("expected  [SDREQ_XFR]  sdreq_op=SDREQ_RD  sdreq_addr=0x%0h --- actually:%s", cdreq_addr_req_bf, t.convert2string()))
          else begin
            wait_nxt_l1_xfr(t);
            if(!((t.Type_xfr == SURSP_XFR) && (t.sursp_rsp inside {SURSP_FETCH, SURSP_SNOOP})))
              `uvm_error("SB_FAIL", $sformatf("expected  [SURSP_XFR]  sursp_rsp=(SURSP_FETCH || SURSP_SNOOP) --- actually:%s", t.convert2string()))
            else begin
              if(t.sursp_rsp == SURSP_FETCH)
                m_cache.set_state(cdreq_addr_req_bf, EXCLUSIVE);
              else if(t.sursp_rsp == SURSP_SNOOP)
                m_cache.set_state(cdreq_addr_req_bf, SHARED);
              else
                `uvm_fatal(m_msg_name, $sformatf("expected SURSP_FETCH or SURSP_SNOOP --- actually %s", t.sursp_rsp.name()))
              m_cache.set_tag(cdreq_addr_req_bf);
              m_cache.set_data(cdreq_addr_req_bf, t.sursp_data);
              wait_nxt_l1_xfr(t);
              if(!((t.Type_xfr == CURSP_XFR) && (t.cursp_rsp == CURSP_OKAY) && (t.cursp_data == m_cache.get_data(cdreq_addr_req_bf))))
                `uvm_error("SB_FAIL", $sformatf("expected  [CURSP_XFR]  cursp_rsp=CURSP_OKAY  cursp_data=0x%0h --- actually:%s", m_cache.get_data(cdreq_addr_req_bf), t.convert2string()))
            end
          end
        end
        else if(cdreq_st_prev inside {EXCLUSIVE, SHARED, MODIFIED}) begin
          wait_nxt_l1_xfr(t);
          if(!((t.Type_xfr == CURSP_XFR) && (t.cursp_rsp == CURSP_OKAY) && (t.cursp_data == cdreq_data_prev)))
            `uvm_error("SB_FAIL", $sformatf("expected  [CURSP_XFR]  cursp_rsp=CURSP_OKAY  cursp_data=0x%0h --- actually:%s", cdreq_data_prev, t.convert2string()))
        end
        else
          `uvm_error("CORNER_CASE", $sformatf("cdreq_op=%s  cdreq_addr=0x%0h  blk_st=%s", cdreq_op_req_bf.name(), cdreq_addr_req_bf, cdreq_st_prev))
      end
      else if(t.cdreq_op == CDREQ_RFO) begin
      end
      else if(t.cdreq_op == CDREQ_WB) begin
      end
      else if(t.cdreq_op == CDREQ_MD) begin
      end
      else begin
        `uvm_error("SB_FAIL", "cannot identify CDREQ opcode")
      end

      // print request report
      `uvm_info(m_msg_name, $sformatf("--------------------------------------------------"), UVM_LOW)
      `uvm_info(m_msg_name, $sformatf("OP=%s  ADDR=0x%0h  DAT=0x%0h", cdreq_op_req_bf, cdreq_addr_req_bf, cdreq_data_req_bf), UVM_LOW)
      check_cache_sync();
      if(cdreq_pass) begin
        `uvm_info("CDREQ_PASS", $sformatf("request from CDREQ passed"), UVM_LOW)
        if(cdreq_st_prev == m_cache.get_state(cdreq_addr_req_bf))
          `uvm_info(m_msg_name, $sformatf("ST[NO_CHANGE]: %s", cdreq_st_prev), UVM_LOW)
        else
          `uvm_info(m_msg_name, $sformatf("ST: %s <-- %s", m_cache.get_state(cdreq_addr_req_bf), cdreq_st_prev), UVM_LOW)
        if(cdreq_tag_prev == m_cache.get_tag(cdreq_addr_req_bf))
          `uvm_info(m_msg_name, $sformatf("TAG[NO_CHANGE]: 0x%0h", cdreq_tag_prev), UVM_LOW)
        else
          `uvm_info(m_msg_name, $sformatf("TAG: 0x%0h <-- 0x%0h", m_cache.get_tag(cdreq_addr_req_bf), cdreq_tag_prev), UVM_LOW)
        if(cdreq_data_prev == m_cache.get_data(cdreq_addr_req_bf))
          `uvm_info(m_msg_name, $sformatf("DATA[NO_CHANGE]: 0x%0h", cdreq_data_prev), UVM_LOW)
        else
          `uvm_info(m_msg_name, $sformatf("DATA: 0x%0h <-- 0x%0h", m_cache.get_data(cdreq_addr_req_bf), cdreq_data_prev), UVM_LOW)
      end
      else begin
        `uvm_info("CDREQ_FAIL", $sformatf("request from CDREQ failed"), UVM_LOW)
      end
      `uvm_info(m_msg_name, $sformatf("--------------------------------------------------"), UVM_LOW)

      // clean config
      cdreq_ot          = 0;
      cdreq_pass        = 0;
      cdreq_op_req_bf   = CDREQ_RD;
      cdreq_addr_req_bf = '0;
      cdreq_data_req_bf = '0;
      cdreq_st_prev     = INVALID;
      cdreq_tag_prev    = '0;
      cdreq_data_prev   = '0;
    end
    else begin
      `uvm_fatal("SB_FAIL", "receives other sub-transfers before request transfer is opened")
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

`undef THIS_CLASS
`endif
