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
`ifdef HAS_SB
          begin
            check_cdreq();
          end
          begin
            check_sureq();
          end
`endif // HAS_SB
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
  string      str;

  forever begin
    wait_nxt_l1_xfr(t);
    if((t.Type_xfr == CDREQ_XFR) && (cdreq_ot == 1))
      `uvm_fatal("SB_FAIL", "receive new CDREQ_XFR while previous transaction is outstanding")
    else if((t.Type_xfr == CDREQ_XFR) && (cdreq_ot == 0)) begin
      // allocate scenario
      cdreq_ot              = 1;
      cdreq_error_count     = 0;
      cdreq_op_req_bf       = t.cdreq_op;
      cdreq_addr_req_bf     = t.cdreq_addr;
      cdreq_data_req_bf     = t.cdreq_data;
      cdreq_idx_bf          = m_cache.get_idx(cdreq_addr_req_bf);
      cdreq_way_bf          = m_cache.get_way(cdreq_addr_req_bf, cdreq_idx_bf, str);
      cdreq_st_prev         = m_cache.get_state(cdreq_idx_bf, cdreq_way_bf);
      cdreq_tag_prev        = m_cache.get_tag(cdreq_idx_bf, cdreq_way_bf);
      cdreq_data_prev       = m_cache.get_data(cdreq_idx_bf, cdreq_way_bf);
      cdreq_evict_way_prev  = m_cache.get_evict_way(cdreq_idx_bf);

      `uvm_info(m_msg_name,   $sformatf("--------------------  CDREQ ----------------------"), UVM_LOW)
      `uvm_info("REC_CDREQ",  $sformatf("Request: OP=%s  ADDR=0x%0h  DAT=0x%0h  Lookup=%s  Access to: IDX=0x%0h  WAY=0x%0h  ST=%s  TAG=0x%0h  DAT=0x%0h", cdreq_op_req_bf, cdreq_addr_req_bf, cdreq_data_req_bf, str, cdreq_idx_bf, cdreq_way_bf, cdreq_st_prev, cdreq_tag_prev, cdreq_data_prev), UVM_LOW)

      // check flow
      if(cdreq_op_req_bf inside {CDREQ_RD, CDREQ_RFO}) begin // valid senarios
        if(cdreq_st_prev inside {INVALID, EXCLUSIVE, SHARED, MODIFIED}) begin
          if( (cdreq_st_prev == INVALID) ||
              (cdreq_tag_prev != cdreq_addr_req_bf[`ADDR_TAG]) ||
              ((cdreq_st_prev == SHARED) && (cdreq_op_req_bf == CDREQ_RFO))
            ) begin // init sub-request on SDREQ channel
            wait_nxt_l1_xfr(t);
            if( (cdreq_op_req_bf == CDREQ_RD) &&
                !((t.Type_xfr == SDREQ_XFR) && (t.sdreq_op == SDREQ_RD) && (t.sdreq_addr == cdreq_addr_req_bf) && (t.sdreq_data == '0))
              )
              `SB_ERROR("CDREQ", $sformatf("expect:[SDREQ_XFR]  sdreq_op=SDREQ_RD  sdreq_addr=0x%0h  sdreq_data=0x0--- actually:%s", cdreq_addr_req_bf, t.convert2string()))
            else if ( ((cdreq_op_req_bf == CDREQ_RFO) && (cdreq_st_prev == INVALID)) &&
                      !((t.Type_xfr == SDREQ_XFR) && (t.sdreq_op == SDREQ_RFO) && (t.sdreq_addr == cdreq_addr_req_bf) && (t.sdreq_data == '0))
                    )
              `SB_ERROR("CDREQ", $sformatf("expect:[SDREQ_XFR]  sdreq_op=SDREQ_RFO  sdreq_addr=0x%0h  sdreq_data=0x0 --- actually:%s", cdreq_addr_req_bf, t.convert2string()))
            else if ( ((cdreq_op_req_bf == CDREQ_RFO) && (cdreq_st_prev == SHARED)) &&
                      !((t.Type_xfr == SDREQ_XFR) && (t.sdreq_op == SDREQ_INV) && (t.sdreq_addr == cdreq_addr_req_bf) && (t.sdreq_data == '0))
                    )
              `SB_ERROR("CDREQ", $sformatf("expect:[SDREQ_XFR]  sdreq_op=SDREQ_INV  sdreq_addr=0x%0h  sdreq_data=0x0 --- actually:%s", cdreq_addr_req_bf, t.convert2string()))
            else begin
              // wait response on SURSP channel
              wait_nxt_l1_xfr(t);
              if( (cdreq_op_req_bf == CDREQ_RD) &&
                  !((t.Type_xfr == SURSP_XFR) && (t.sursp_rsp inside {SURSP_FETCH, SURSP_SNOOP}))
                )
                `SB_ERROR("CDREQ", $sformatf("expect:[SURSP_XFR]  sursp_rsp=(SURSP_FETCH || SURSP_SNOOP) --- actually:%s", t.convert2string()))
              else if ( ((cdreq_op_req_bf == CDREQ_RFO) && (cdreq_st_prev == INVALID)) &&
                        !((t.Type_xfr == SURSP_XFR) && (t.sursp_rsp == SURSP_OKAY))
                      )
                `SB_ERROR("CDREQ", $sformatf("expect:[SURSP_XFR]  sursp_rsp=SURSP_OKAY --- actually:%s", t.convert2string()))
              else if ( ((cdreq_op_req_bf == CDREQ_RFO) && (cdreq_st_prev == SHARED)) &&
                        !((t.Type_xfr == SURSP_XFR) && (t.sursp_rsp == SURSP_OKAY) && (t.sursp_data == '0))
                      )
                `SB_ERROR("CDREQ", $sformatf("expect:[SURSP_XFR]  sursp_rsp=SURSP_OKAY  sursp_data=0x0 --- actually:%s", t.convert2string()))
              else begin
                // update memory
                if(cdreq_op_req_bf == CDREQ_RD) begin
                  if(t.sursp_rsp == SURSP_FETCH)
                    m_cache.set_state(cdreq_idx_bf, cdreq_way_bf, EXCLUSIVE);
                  else if(t.sursp_rsp == SURSP_SNOOP)
                    m_cache.set_state(cdreq_idx_bf, cdreq_way_bf, SHARED);
                end
                else if(cdreq_op_req_bf == CDREQ_RFO) begin
                  m_cache.set_state(cdreq_idx_bf, cdreq_way_bf, MIGRATED);
                end
                if((cdreq_st_prev == INVALID) || (cdreq_tag_prev != cdreq_addr_req_bf[`ADDR_TAG])) begin
                  m_cache.set_tag(cdreq_idx_bf, cdreq_way_bf, cdreq_addr_req_bf[`ADDR_TAG]);
                  m_cache.set_data(cdreq_idx_bf, cdreq_way_bf, t.sursp_data);
                end
              end
            end
          end
          else if((cdreq_op_req_bf == CDREQ_RFO) && (cdreq_st_prev inside {EXCLUSIVE, MODIFIED})) begin
            m_cache.set_state(cdreq_idx_bf, cdreq_way_bf, MIGRATED);
          end
          // send reponse of original request in CURSP channel
          wait_nxt_l1_xfr(t);
          if(!((t.Type_xfr == CURSP_XFR) && (t.cursp_rsp == CURSP_OKAY) && (t.cursp_data == m_cache.get_data(cdreq_idx_bf, cdreq_way_bf))))
            `SB_ERROR("CDREQ", $sformatf("expect:[CURSP_XFR]  cursp_rsp=CURSP_OKAY  cursp_data=0x%0h --- actually:%s", m_cache.get_data(cdreq_idx_bf, cdreq_way_bf), t.convert2string()))
        end
        else if(cdreq_st_prev == MIGRATED) // corner caess
          `SB_ERROR("CDREQ", $sformatf("[CORNER_CASE] cdreq_op=%s  cdreq_addr=0x%0h  blk_st=%s", cdreq_op_req_bf.name(), cdreq_addr_req_bf, cdreq_st_prev))
        else // invalid block state
          `uvm_fatal(m_msg_name, $sformatf("can not identify current state of accessed block ST=%s", cdreq_st_prev.name()))
      end
      else if(cdreq_op_req_bf == CDREQ_MD) begin
        if(cdreq_st_prev inside {EXCLUSIVE, SHARED, MODIFIED, MIGRATED}) begin // valid scenarios
          if(cdreq_st_prev == SHARED) begin // init SDREQ_IND if hit SHARED
            wait_nxt_l1_xfr(t);
            if(!((t.Type_xfr == SDREQ_XFR) && (t.sdreq_op == SDREQ_INV) && (t.sdreq_addr == cdreq_addr_req_bf) && (t.sdreq_data == '0)))
              `SB_ERROR("CDREQ", $sformatf("expect:[SDREQ_XFR]  sdreq_op=SDREQ_INV  sdreq_addr=0x%0h  sdreq_data=0x0 --- actually:%s", cdreq_addr_req_bf, t.convert2string()))
            else begin
              wait_nxt_l1_xfr(t);
              if(!((t.Type_xfr == SURSP_XFR) && (t.sursp_rsp == SURSP_OKAY) && (t.sursp_data == '0)))
                `SB_ERROR("CDREQ", $sformatf("expect:[SURSP_XFR]  sursp_rsp=SURSP_OKAY  sursp_data=0x0 --- actually:%s", t.convert2string()))
            end
          end
          m_cache.set_state(cdreq_idx_bf, cdreq_way_bf, MIGRATED);
          // send response of original request on CURSP
          wait_nxt_l1_xfr(t);
          if(!((t.Type_xfr == CURSP_XFR) && (t.cursp_rsp == CURSP_OKAY) && (t.cursp_data == '0))) begin
            `SB_ERROR("CDREQ", $sformatf("expect:[CURSP_XFR]  cursp_rsp=CURSP_OKAY  cursp_data=0x0 --- actually:%s", t.convert2string()))
          end
        end
        else if(cdreq_st_prev == INVALID) // corner cases
          `SB_ERROR("CDREQ", $sformatf("[CORNER_CASE] cdreq_op=%s  cdreq_addr=0x%0h  blk_st=%s", cdreq_op_req_bf.name(), cdreq_addr_req_bf, cdreq_st_prev))
        else // invalid cache state
          `uvm_fatal(m_msg_name, $sformatf("can not identify current state of accessed block ST=%s", cdreq_st_prev.name()))
      end
      else if(cdreq_op_req_bf == CDREQ_WB) begin
        if(cdreq_st_prev == MIGRATED) begin // valid scenarios
          m_cache.set_state(cdreq_idx_bf, cdreq_way_bf, MODIFIED);
          m_cache.set_data(cdreq_idx_bf, cdreq_way_bf, t.cdreq_data);
          // send response of original request on CURSP
          wait_nxt_l1_xfr(t);
          if(!((t.Type_xfr == CURSP_XFR) && (t.cursp_rsp == CURSP_OKAY) && (t.cursp_data == '0)))
            `SB_ERROR("CDREQ", $sformatf("expect:[CURSP_XFR]  cursp_rsp=CURSP_OKAY  cursp_data=0x0 --- actually:%s", t.convert2string()))
        end
        else if(cdreq_st_prev inside {INVALID, EXCLUSIVE, SHARED, MODIFIED}) // corner cases
          `SB_ERROR("CDREQ", $sformatf("[CORNER_CASE] cdreq_op=%s  cdreq_addr=0x%0h  blk_st=%s", cdreq_op_req_bf.name(), cdreq_addr_req_bf, cdreq_st_prev))
        else // invalid cache state
          `uvm_fatal(m_msg_name, $sformatf("can not identify current state of accessed block ST=%s", cdreq_st_prev.name()))
      end
      else
        `uvm_fatal(m_msg_name, $sformatf("cannot identify SUREQ opcode ST=%s", cdreq_op_req_bf.name()))

      // promote replacement
      m_cache.update_repl_age(cdreq_idx_bf, cdreq_way_bf);
      // print report
      @`M_VIF;
      comp_model_vs_rtl("CDREQ", cdreq_idx_bf, cdreq_way_bf);
      if(cdreq_error_count == 0) begin
        str = "Report: ";
        if(cdreq_st_prev == m_cache.get_state(cdreq_idx_bf, cdreq_way_bf))  str = {str, $sformatf("ST=%s(remain)  ", cdreq_st_prev)};
        else                                                                str = {str, $sformatf("ST=%s <-- %s  ", m_cache.get_state(cdreq_idx_bf, cdreq_way_bf), cdreq_st_prev)};
        if(cdreq_tag_prev == m_cache.get_tag(cdreq_idx_bf, cdreq_way_bf))   str = {str, $sformatf("TAG=0x%0h(remain)  ", cdreq_tag_prev)};
        else                                                                str = {str, $sformatf("TAG=0x%0h <-- 0x%0h  ", m_cache.get_tag(cdreq_idx_bf, cdreq_way_bf), cdreq_tag_prev)};
        if(cdreq_data_prev == m_cache.get_data(cdreq_idx_bf, cdreq_way_bf)) str = {str, $sformatf("DATA=0x%0h(remain)  ", cdreq_data_prev)};
        else                                                                str = {str, $sformatf("DATA=0x%0h <-- 0x%0h  ", m_cache.get_data(cdreq_idx_bf, cdreq_way_bf), cdreq_data_prev)};
        if(cdreq_evict_way_prev == m_cache.get_evict_way(cdreq_idx_bf))     str = {str, $sformatf("EVICT_WAY=0x%0h(remain)  ", cdreq_evict_way_prev)};
        else                                                                str = {str, $sformatf("EVICT_WAY=0x%0h <-- 0x%0h  ", m_cache.get_evict_way(cdreq_idx_bf), cdreq_evict_way_prev)};
        `uvm_info("PASS_CDREQ", str, UVM_LOW)
      end
      else begin
        `uvm_info("FAIL_CDREQ", $sformatf("# request from CDREQ failed"), UVM_LOW)
      end
      `uvm_info(m_msg_name, $sformatf("--------------------------------------------------"), UVM_LOW)

      // clean scenario
      cdreq_ot              = 0;
      cdreq_error_count     = 0;
      cdreq_op_req_bf       = CDREQ_RD;
      cdreq_addr_req_bf     = 0;
      cdreq_data_req_bf     = 0;
      cdreq_idx_bf          = 0;
      cdreq_way_bf          = 0;
      cdreq_st_prev         = INVALID;
      cdreq_tag_prev        = 0;
      cdreq_data_prev       = 0;
      cdreq_evict_way_prev  = 0;
    end
    else begin
      `uvm_fatal("SB_FAIL", "receives other sub-transfers before request transfer is opened")
    end
  end
endtask: check_cdreq

// ------------------------------------------------------------------
task `THIS_CLASS::check_sureq();
  cache_txn_c t;
  bit         sureq_hit;
  string      str;

  forever begin
    wait_nxt_snp_xfr(t);
    if((t.Type_xfr == SUREQ_XFR) && (sureq_ot == 1))
      `uvm_fatal("SB_FAIL", "receive new SUREQ_XFR while previous transaction is outstanding")
    else if((t.Type_xfr == SUREQ_XFR) && (sureq_ot == 0)) begin
      // allocate scenatio
      sureq_ot              = 1;
      sureq_error_count     = 0;
      sureq_op_req_bf       = t.sureq_op;
      sureq_addr_req_bf     = t.sureq_addr;
      sureq_idx_bf          = m_cache.get_idx(sureq_addr_req_bf);
      sureq_evict_way_prev  = m_cache.get_evict_way(sureq_idx_bf);
      
      // assign default
      sureq_hit = 1'b0;
      str       = "MISS";
      for(int i=0; i < `VIP_NUM_WAY; i++) begin
        if((m_cache.mem[sureq_idx_bf][i].state != INVALID) && (m_cache.mem[sureq_idx_bf][i].tag == sureq_addr_req_bf[`ADDR_TAG])) begin
          sureq_hit       = 1;
          str             = "HIT";
          sureq_way_bf    = i;
          sureq_st_prev   = m_cache.get_state(sureq_idx_bf, sureq_way_bf);
          sureq_tag_prev  = m_cache.get_tag(sureq_idx_bf, sureq_way_bf);
          sureq_data_prev = m_cache.get_data(sureq_idx_bf, sureq_way_bf);
          break;
        end
      end

      `uvm_info(m_msg_name,   $sformatf("--------------------  SUREQ ----------------------"), UVM_LOW)
      `uvm_info("REC_SUREQ",  $sformatf("Request: OP=%s  ADDR=0x%0h  Access to IDX=0x%0h  WAY=0x%0h  ST=%s  TAG=0x%0h  DAT=0x%0h", sureq_op_req_bf, sureq_addr_req_bf, sureq_idx_bf, sureq_way_bf, sureq_st_prev, sureq_tag_prev, sureq_data_prev), UVM_LOW)

      // check flow
      if(sureq_op_req_bf inside {SUREQ_RD, SUREQ_RFO}) begin
        if(!sureq_hit) begin
          wait_nxt_snp_xfr(t);
          if(!((t.Type_xfr == SDRSP_XFR) && (t.sdrsp_rsp == SDRSP_INVALID) && (t.sdrsp_data == '0)))
            `SB_ERROR("SUREQ", $sformatf("expect:[SDRSP_XFR]  sdrsp_rsp=SDRSP_INVALID  sdrsp_data=0x0 --- actually:%s", t.convert2string()))
        end
        else if(sureq_st_prev inside {EXCLUSIVE, SHARED, MODIFIED, MIGRATED}) begin // valid senarios
          if((sureq_st_prev inside {EXCLUSIVE, SHARED, MODIFIED}) && (sureq_op_req_bf == SUREQ_RFO) && m_cache.is_blk_valid_in_l1(sureq_addr_req_bf)) begin // init sub-request on CUREQ channel
            wait_nxt_snp_xfr(t);
            if(!((t.Type_xfr == CUREQ_XFR) && (t.cureq_op == CUREQ_INV) && (t.cureq_addr == sureq_addr_req_bf)))
              `SB_ERROR("SUREQ", $sformatf("expect:[CUREQ_XFR]  cureq_op=CUREQ_INV  cureq_addr=0x%0h --- actually:%s", sureq_addr_req_bf, t.convert2string()))
            else begin
              wait_nxt_snp_xfr(t);
              if(!((t.Type_xfr == CDRSP_XFR) && (t.cdrsp_rsp == CDRSP_OKAY) && (t.cdrsp_data == '0)))
                `SB_ERROR("SUREQ", $sformatf("expect:[CDRSP_XFR]  cdrsp_rsp=CDRSP_OKAY  cdrsp_data=0x0 --- actually:%s", t.convert2string()))
            end
          end
          else if(sureq_st_prev == MIGRATED) begin
            wait_nxt_snp_xfr(t);
            if( (sureq_op_req_bf == SUREQ_RD) &&
                !((t.Type_xfr == CUREQ_XFR) && (t.cureq_op == CUREQ_RD) && (t.cureq_addr == sureq_addr_req_bf))
              )
              `SB_ERROR("SUREQ", $sformatf("expect:[CUREQ_XFR]  cureq_op=CUREQ_RD  cureq_addr=0x%0h --- actually:%s", sureq_addr_req_bf, t.convert2string()))
            else if ( (sureq_op_req_bf == SUREQ_RFO) &&
                      !((t.Type_xfr == CUREQ_XFR) && (t.cureq_op == CUREQ_RFO) && (t.cureq_addr == sureq_addr_req_bf))
                    )
              `SB_ERROR("SUREQ", $sformatf("expect:[CUREQ_XFR]  cureq_op=CUREQ_RFO  cureq_addr=0x%0h --- actually:%s", sureq_addr_req_bf, t.convert2string()))
            else begin
              wait_nxt_snp_xfr(t);
              if(!((t.Type_xfr == CDRSP_XFR) && (t.cdrsp_rsp == CDRSP_OKAY)))
                `SB_ERROR("SUREQ", $sformatf("expect:[CDRSP_XFR]  cdrsp_rsp=CDRSP_OKAY --- actually:%s", t.convert2string()))
              else
                m_cache.set_data(sureq_idx_bf, sureq_way_bf, t.cdrsp_data);
            end
          end
          // init SDREQ
          if(sureq_st_prev inside {MODIFIED, MIGRATED}) begin
            wait_nxt_snp_xfr(t);
            if(!((t.Type_xfr == SDREQ_XFR) && (t.sdreq_op == SDREQ_WB) && (t.sdreq_addr == sureq_addr_req_bf) && (t.sdreq_data == m_cache.get_data(sureq_idx_bf, sureq_way_bf))))
              `SB_ERROR("SUREQ", $sformatf("expect:[SDREQ_XFR]  sdreq_op=SDREQ_WB  sdreq_addr=0x%0h  sdreq_data=0x%0h --- actually:%s", sureq_addr_req_bf, m_cache.get_data(sureq_idx_bf, sureq_way_bf), t.convert2string()))
            else begin
              wait_nxt_snp_xfr(t);
              if(!((t.Type_xfr == SURSP_XFR) && (t.sursp_rsp == SURSP_OKAY) && (t.sursp_data == '0)))
                `SB_ERROR("SUREQ", $sformatf("expect:[SURSP_XFR]  sursp_rsp=SURSP_OKAY  sursp_data=0x0 --- actually:%s", t.convert2string()))
            end
          end
          // send SDRSP to original SUREQ
          wait_nxt_snp_xfr(t);
          if(!((t.Type_xfr == SDRSP_XFR) && (t.sdrsp_rsp == SDRSP_OKAY) && (t.sdrsp_data == m_cache.get_data(sureq_idx_bf, sureq_way_bf))))
            `SB_ERROR("SUREQ", $sformatf("expect:[SDRSP_XFR]  sdrsp_rsp=SDRSP_OKAY  sdrsp_data=0x%0h --- actually:%s", m_cache.get_data(sureq_idx_bf, sureq_way_bf), t.convert2string))
          else
            if(sureq_op_req_bf == SUREQ_RD)
              m_cache.set_state(sureq_idx_bf, sureq_way_bf, SHARED);
            else if(sureq_op_req_bf == SUREQ_RFO)
              m_cache.set_state(sureq_idx_bf, sureq_way_bf, INVALID);
        end
        else begin // invalid block state
          `uvm_fatal(m_msg_name, $sformatf("can not identify current state of accessed block ST=%s", sureq_st_prev.name()))
        end
      end
      else if(sureq_op_req_bf == SUREQ_INV) begin
        if(!sureq_hit) begin
          wait_nxt_snp_xfr(t);
          if(!((t.Type_xfr == SDRSP_XFR) && (t.sdrsp_rsp == SDRSP_INVALID) && (t.sdrsp_data == '0)))
            `SB_ERROR("SUREQ", $sformatf("expect:[SDRSP_XFR]  sdrsp_rsp=SDRSP_INVALID  sdrsp_data=0x0 --- actually:%s", t.convert2string()))
        end
        else if(sureq_st_prev == SHARED) begin
          // init CUREQ
          if(m_cache.is_blk_valid_in_l1(sureq_addr_req_bf)) begin
            wait_nxt_snp_xfr(t);
            if(!((t.Type_xfr == CUREQ_XFR) && (t.cureq_op == CUREQ_INV) && (t.cureq_addr == sureq_addr_req_bf)))
              `SB_ERROR("SUREQ", $sformatf("expect:[CUREQ_XFR]  cureq_op=CUREQ_INV  cureq_addr=0x%0h --- actually:%s", sureq_addr_req_bf, t.convert2string()))
            else begin
              wait_nxt_snp_xfr(t);
              if(!((t.Type_xfr == CDRSP_XFR) && (t.cdrsp_rsp == CDRSP_OKAY) && (t.cursp_data == '0)))
                `SB_ERROR("SUREQ", $sformatf("expect:[CDRSP_XFR]  cdrsp_rsp=CDRSP_OKAY  cdrsp_data=0x0 --- actually:%s", t.convert2string()))
            end
          end
          // send SDRSP to original SUREQ
          m_cache.set_state(sureq_idx_bf, sureq_way_bf, INVALID);
          wait_nxt_snp_xfr(t);
          if(!((t.Type_xfr == SDRSP_XFR) && (t.sdrsp_rsp == SDRSP_OKAY) && (t.sdrsp_data == '0)))
            `SB_ERROR("SUREQ", $sformatf("expect:[SDRSP_XFR]  sdrsp_rsp=SDRSP_OKAY  sdrsp_data=0x0 --- actually:%s", t.convert2string()))
        end
        else if(sureq_st_prev inside {EXCLUSIVE, MODIFIED, MIGRATED})
          `SB_ERROR("SUREQ", $sformatf("[CORNER_CASE] sureq_op=%s  sureq_addr=0x%0h  blk_st=%s", sureq_op_req_bf.name(), sureq_addr_req_bf, sureq_st_prev))
        else
          `uvm_fatal(m_msg_name, $sformatf("can not identify current state of accessed block ST=%s", sureq_st_prev.name()))
      end
      else
        `uvm_fatal(m_msg_name, $sformatf("cannot identify SUREQ opcode ST=%s", sureq_op_req_bf.name()))

      // promote replacement
      if(sureq_hit && (sureq_op_req_bf == SUREQ_RD)) begin
        m_cache.update_repl_age(sureq_idx_bf, sureq_way_bf);
      end
      // print request report
      `uvm_info(m_msg_name, $sformatf("OP=%s  ADDR=0x%0h", sureq_op_req_bf, sureq_addr_req_bf), UVM_LOW)
      @`M_VIF;
      comp_model_vs_rtl("SUREQ", sureq_idx_bf, sureq_way_bf);
      if(sureq_error_count == 0) begin
        str = "Report: ";
        if(sureq_hit) begin
          if(sureq_st_prev == m_cache.get_state(sureq_idx_bf, sureq_way_bf))  str = {str, $sformatf("ST: %s(remain)  ", sureq_st_prev)};
          else                                                                str = {str, $sformatf("ST: %s <-- %s  ", m_cache.get_state(sureq_idx_bf, sureq_way_bf), sureq_st_prev)};
          if(sureq_tag_prev == m_cache.get_tag(sureq_idx_bf, sureq_way_bf))   str = {str, $sformatf("TAG: 0x%0h(remain)  ", sureq_tag_prev)};
          else                                                                str = {str, $sformatf("TAG: 0x%0h <-- 0x%0h  ", m_cache.get_tag(sureq_idx_bf, sureq_way_bf), sureq_tag_prev)};
          if(sureq_data_prev == m_cache.get_data(sureq_idx_bf, sureq_way_bf)) str = {str, $sformatf("DATA: 0x%0h(remain)  ", sureq_data_prev)};
          else                                                                str = {str, $sformatf("DATA: 0x%0h <-- 0x%0h  ", m_cache.get_data(sureq_idx_bf, sureq_way_bf), sureq_data_prev)};
        end
        if(sureq_evict_way_prev == m_cache.get_evict_way(sureq_idx_bf))     str = {str, $sformatf("EVICT_WAY=0x%0h(remain)  ", sureq_evict_way_prev)};
        else                                                                str = {str, $sformatf("EVICT_WAY=0x%0h <-- 0x%0h  ", m_cache.get_evict_way(sureq_idx_bf), sureq_evict_way_prev)};
        `uvm_info("PASS_SUREQ", str, UVM_LOW)
      end
      else begin
        `uvm_info("FAIL_SUREQ", $sformatf("request from SUREQ failed"), UVM_LOW)
      end
      `uvm_info(m_msg_name, $sformatf("--------------------------------------------------"), UVM_LOW)

      // clean scenario
      sureq_ot              = 0;
      sureq_error_count     = 0;
      sureq_op_req_bf       = SUREQ_RD;
      sureq_addr_req_bf     = 0;
      sureq_idx_bf          = 0;
      sureq_hit             = 0;
      sureq_way_bf          = 0;
      sureq_st_prev         = INVALID;
      sureq_tag_prev        = 0;
      sureq_data_prev       = 0;
      sureq_evict_way_prev  = 0;
    end
    else begin
      `uvm_fatal("SB_FAIL", "receives other sub-transfers before request transfer is opened")
    end
  end
endtask: check_sureq

`undef THIS_CLASS
`endif
