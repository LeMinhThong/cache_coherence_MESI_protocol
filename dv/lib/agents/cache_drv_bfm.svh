`ifndef CACHE_DRV_BFM_SVH
`define CACHE_DRV_BFM_SVH
`define THIS_CLASS cache_drv_bfm_c
`define M_VIF m_vif.drv_cb

class `THIS_CLASS extends uvm_component;
  `uvm_component_utils(`THIS_CLASS)

  uvm_blocking_put_imp      #(cache_txn_c, `THIS_CLASS) req_imp;
  uvm_nonblocking_put_port  #(cache_txn_c)              rsp_port;

  virtual cache_if m_vif;

  cache_txn_c l1_req_q[$];
  cache_txn_c snp_req_q[$];

  cureq_e     cureq_op_loc;
  sdreq_e     sdreq_op_loc;

  string  m_msg_name            = "DRV_BFM";
  int     wt_ready_en_rand_max  = 5;
  int     wt_send_rsp_rand_max  = 5;

  bit     reset_check;
  //bit     init_transfer;
  bit     init_l1_transfer;
  bit     init_snp_transfer;
  bit     put_flag;

  extern  virtual function  void  build_phase(uvm_phase phase);
  extern  virtual task            run_phase(uvm_phase phase);
  extern  virtual task            get_and_drive();
  extern  virtual task            drive_l1_transfer();
  extern  virtual task            drive_snp_transfer();
  extern  virtual task            reset_monitoring();
  extern  virtual task            reset_signals();
  extern  virtual task            put(cache_txn_c txn);
  extern  virtual task            send_reponse(cache_txn_c t_rsp);

  function new(string name="`THIS_CLASS", uvm_component parent);
    super.new(name, parent);
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
function void `THIS_CLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(virtual cache_if)::get(this, "", "cac_if", m_vif)) uvm_report_fatal(m_msg_name, "Cannot get virtual cache interface");
  this.req_imp = new("req_imp", this);
  this.rsp_port = new("rsp_port", this);
endfunction: build_phase

//-------------------------------------------------------------------
task `THIS_CLASS::run_phase(uvm_phase phase);
  fork
    begin
      reset_signals();
      reset_monitoring();
    end

    begin
      forever begin
        wait(reset_check == 1'b1);
        fork
          get_and_drive();

          wait(reset_check == 1'b0);
        join_any
        `uvm_info(m_msg_name, "RST_DEBUG: out-of-fork", UVM_INFO)
        disable fork;
        l1_req_q.delete();
        snp_req_q.delete();
        //init_transfer = 1'b0;
        init_l1_transfer = 1'b0;
        init_snp_transfer = 1'b0;
        put_flag = 1'b0;
      end
    end
  join
endtask: run_phase

//-------------------------------------------------------------------
task `THIS_CLASS::get_and_drive();
  wait(reset_check == 1);
  forever begin
    if(put_flag == 1'b1) begin
      fork
        if(!init_l1_transfer)   drive_l1_transfer();
        if(!init_snp_transfer)  drive_snp_transfer();
      join_any
      put_flag = 1'b0;
      //if((init_transfer == 1'b0) || ((init_l1_transfer == 1'b0 ) && (init_snp_transfer == 1'b0))) begin
      //  fork begin
      //    fork
      //      if(!init_l1_transfer)   drive_l1_transfer();
      //      if(!init_snp_transfer)  drive_snp_transfer();
      //    join_any
      //    init_transfer = 1'b0;
      //  end join_none
      //  init_transfer = 1'b1;
      //end
      //put_flag = 1'b0;
    end
    else
      @`M_VIF;
  end
endtask: get_and_drive

//-------------------------------------------------------------------
task `THIS_CLASS::drive_l1_transfer();
  cache_txn_c t_req;
  cache_txn_c t_rsp;

  init_l1_transfer = 1'b1;
  while(l1_req_q.size() > 0) begin
    t_req = l1_req_q.pop_front();
    `uvm_info(m_msg_name, $sformatf("drive L1 request: t_req=%s", t_req.convert2string()), UVM_DEBUG)
    t_rsp = new t_req;

    fork
      begin // CDREQ
        `M_VIF.cdreq_valid  <= 1'b1;
        `M_VIF.cdreq_op     <= t_req.cdreq_op;
        `M_VIF.cdreq_addr   <= t_req.cdreq_addr;
        if(t_req.cdreq_op == CDREQ_WB)
          `M_VIF.cdreq_data <= t_req.cdreq_data;
        else
          `M_VIF.cdreq_data <= '0;

        @`M_VIF;
        while(`M_VIF.cdreq_ready != 1'b1) begin
          @`M_VIF;
        end

        `M_VIF.cdreq_valid  <= 1'b0;
        `M_VIF.cdreq_op     <= '0;
        `M_VIF.cdreq_addr   <= '0;
        `M_VIF.cdreq_data   <= '0;
      end

      begin: CAC_SDREQ_HANDLER_BLK
        // accept request from SDREQ
        @(posedge `M_VIF.sdreq_valid);
        repeat($urandom_range(0, wt_ready_en_rand_max)) begin
          @`M_VIF;
        end
        sdreq_op_loc = sdreq_e'(`M_VIF.sdreq_op);
        `M_VIF.sdreq_ready  <= 1'b1;
        @`M_VIF;
        `M_VIF.sdreq_ready  <= 1'b0;
        @`M_VIF;

        // wait before send response
        repeat($urandom_range(0, wt_send_rsp_rand_max)) begin
          @`M_VIF;
        end

        // send response on SURSP
        `M_VIF.sursp_valid  <= 1'b1;
        if(sdreq_op_loc == SDREQ_RD)
          `M_VIF.sursp_rsp <= t_req.sursp_rsp;
        else
          `M_VIF.sursp_rsp <= SURSP_OKAY;

        if(sdreq_op_loc inside {SDREQ_RD, SDREQ_RFO})
          `M_VIF.sursp_data <= t_req.sursp_data;
        else
          `M_VIF.sursp_data <= '0;

        @(posedge `M_VIF.sursp_ready);
        `M_VIF.sursp_valid  <= 1'b0;
        `M_VIF.sursp_rsp    <= '0;
        `M_VIF.sursp_data   <= '0;
      end: CAC_SDREQ_HANDLER_BLK

      begin // CURSP
        @(posedge `M_VIF.cursp_valid);

        repeat($urandom_range(0, wt_ready_en_rand_max)) begin
          @`M_VIF;
        end
        `M_VIF.cursp_ready <= 1'b1;
        t_rsp.cursp_rsp   = cursp_e'(`M_VIF.cursp_rsp);
        t_rsp.cursp_data  = `M_VIF.cursp_data;

        @`M_VIF;
        `M_VIF.cursp_ready <= 1'b0;
        // disable SURSP channel controller in cases no SDREQ request is initiated
        disable CAC_SDREQ_HANDLER_BLK;
      end
    join

    `uvm_info(m_msg_name, $sformatf("put L1 response: %s", t_rsp.convert2string()), UVM_DEBUG)
    send_reponse(t_rsp);
  end
  init_l1_transfer = 1'b0;
endtask: drive_l1_transfer

//-------------------------------------------------------------------
task `THIS_CLASS::drive_snp_transfer();
  cache_txn_c t_req;
  cache_txn_c t_rsp;

  init_snp_transfer = 1'b1;
  while(snp_req_q.size() > 0) begin
    t_req = snp_req_q.pop_front();
    `uvm_info(m_msg_name, $sformatf("drive snoop request: t_req=%s", t_req.convert2string()), UVM_DEBUG)
    t_rsp = new t_req;

    fork
      begin // initiates SUREQ
        `M_VIF.sureq_valid  <= 1'b1;
        `M_VIF.sureq_op     <= t_req.sureq_op;
        `M_VIF.sureq_addr   <= t_req.sureq_addr;

        @`M_VIF;
        while(`M_VIF.sureq_ready != 1'b1) begin
          @`M_VIF;
        end

        `M_VIF.sureq_valid  <= 1'b0;
        `M_VIF.sureq_op     <= '0;
        `M_VIF.sureq_addr   <= '0;
      end

      begin: CUREQ_HANDLER_BLK
        // accept request from CUREQ
        @(posedge `M_VIF.cureq_valid);
        repeat($urandom_range(0, wt_ready_en_rand_max)) begin
          @`M_VIF;
        end
        cureq_op_loc = cureq_e'(`M_VIF.cureq_op);
        `M_VIF.cureq_ready <= 1'b1;
        @`M_VIF;
        `M_VIF.cureq_ready <= 1'b0;
        @`M_VIF;

        // wait before send response
        repeat($urandom_range(0, wt_send_rsp_rand_max)) begin
          @`M_VIF;
        end

        // send response on CDRSP
        `M_VIF.cdrsp_valid  <= 1'b1;
        `M_VIF.cdrsp_rsp    <= CDRSP_OKAY;
        if(cureq_op_loc == CUREQ_INV)
          `M_VIF.cdrsp_data <= '0;
        else
          `M_VIF.cdrsp_data <= t_req.cdrsp_data;

        @(posedge `M_VIF.cdrsp_ready);
        `M_VIF.cdrsp_valid  <= 1'b0;
        `M_VIF.cdrsp_rsp    <= '0;
        `M_VIF.cdrsp_data   <= '0;
      end: CUREQ_HANDLER_BLK

      begin: SNP_SDREQ_HANDLER_BLK
        // accept request from SDREQ
        @(posedge `M_VIF.sdreq_valid);
        repeat($urandom_range(0, wt_ready_en_rand_max)) begin
          @`M_VIF;
        end
        sdreq_op_loc = sdreq_e'(`M_VIF.sdreq_op);
        `M_VIF.sdreq_ready  <= 1'b1;
        @`M_VIF;
        `M_VIF.sdreq_ready  <= 1'b0;
        @`M_VIF;

        // wait before send response
        repeat($urandom_range(0, wt_send_rsp_rand_max)) begin
          @`M_VIF;
        end

        // send response on SURSP
        `M_VIF.sursp_valid  <= 1'b1;
        if(sdreq_op_loc == SDREQ_RD)
          `M_VIF.sursp_rsp <= t_req.sursp_rsp;
        else
          `M_VIF.sursp_rsp <= SURSP_OKAY;

        if(sdreq_op_loc inside {SDREQ_RD, SDREQ_RFO})
          `M_VIF.sursp_data <= t_req.sursp_data;
        else
          `M_VIF.sursp_data <= '0;

        @(posedge `M_VIF.sursp_ready);
        `M_VIF.sursp_valid  <= 1'b0;
        `M_VIF.sursp_rsp    <= '0;
        `M_VIF.sursp_data   <= '0;
      end: SNP_SDREQ_HANDLER_BLK

      begin // SDRSP
        @(posedge `M_VIF.sdrsp_valid);

        repeat($urandom_range(0, wt_ready_en_rand_max)) begin
          @`M_VIF;
        end
        `M_VIF.sdrsp_ready <= 1'b1;
        t_rsp.sdrsp_rsp   = sdrsp_e'(`M_VIF.sdrsp_rsp);
        t_rsp.sdrsp_data  = `M_VIF.sdrsp_data;

        @`M_VIF;
        `M_VIF.sdrsp_ready <= 1'b0;

        // disable CUREQ or SDREQ handler when L2 send response on SDRRSP
        disable CUREQ_HANDLER_BLK;
        disable SNP_SDREQ_HANDLER_BLK;
      end
    join

    `uvm_info(m_msg_name, $sformatf("put snoop response: %s", t_rsp.convert2string()), UVM_DEBUG)
    send_reponse(t_rsp);
  end
  init_snp_transfer = 1'b0;
endtask: drive_snp_transfer
    //`M_VIF.sureq_op    <= t_req.sureq_op;
    //`M_VIF.sureq_addr  <= t_req.sureq_addr;

    //@m_vif.mon_cb;
    //t_rsp.sdrsp_rsp  = sdrsp_e'(m_vif.sdrsp_rsp);
    //t_rsp.sdrsp_data = m_vif.sdrsp_data;

    //@`M_VIF;
    //`M_VIF.sureq_op    <= SUREQ_RD;
    //`M_VIF.sureq_addr  <= '0;

    //`uvm_info(m_msg_name, $sformatf("put snoop response: %s", t_rsp.convert2string()), UVM_DEBUG)
    //send_reponse(t_rsp);

//-------------------------------------------------------------------
task `THIS_CLASS::reset_monitoring();
  forever begin
    fork
      begin
        @(negedge `M_VIF.rst_n);
        `uvm_info(m_msg_name, "Reset is handling", UVM_DEBUG)
        reset_check = 0;
        reset_signals();
      end

      begin
        @(posedge `M_VIF.rst_n);
        `uvm_info(m_msg_name, "Reset has completed", UVM_DEBUG)
        repeat(3) @(`M_VIF)
        reset_check = 1;
      end
    join
  end
endtask: reset_monitoring

//-------------------------------------------------------------------
task `THIS_CLASS::reset_signals();
  `M_VIF.cdreq_valid  <= 1'b0;
  `M_VIF.cdreq_op     <= '0;
  `M_VIF.cdreq_addr   <= '0;
  `M_VIF.cdreq_data   <= '0;

  `M_VIF.cursp_ready  <= 1'b0;

  `M_VIF.cureq_ready  <= 1'b0;

  `M_VIF.cdrsp_valid  <= 1'b0;
  `M_VIF.cdrsp_rsp    <= '0;
  `M_VIF.cdrsp_data   <= '0;

  `M_VIF.sdreq_ready  <= 1'b0;

  `M_VIF.sursp_valid  <= 1'b0;
  `M_VIF.sursp_rsp    <= '0;
  `M_VIF.sursp_data   <= '0;

  `M_VIF.sureq_valid  <= 1'b0;
  `M_VIF.sureq_op     <= '0;
  `M_VIF.sureq_addr   <= '0;

  `M_VIF.sdrsp_ready  <= 1'b0;
endtask: reset_signals

//-------------------------------------------------------------------
task `THIS_CLASS::put(cache_txn_c txn);
  cache_txn_c loc_txn = new txn;
  if(loc_txn.Type == L1_REQ)  begin
    l1_req_q.push_back(loc_txn);
    `uvm_info(m_msg_name, $sformatf("put req to l1_req_q=%0d req=%s", l1_req_q.size(), loc_txn.convert2string()), UVM_DEBUG)
  end
  else if (loc_txn.Type == SNP_REQ) begin
    snp_req_q.push_back(loc_txn);
  end
  else
    `uvm_fatal(m_msg_name, "Can not determine request type")
  put_flag = 1'b1;
endtask: put

//-------------------------------------------------------------------
task `THIS_CLASS::send_reponse(cache_txn_c t_rsp);
  void'(this.rsp_port.try_put(t_rsp));
endtask: send_reponse

`undef M_VIF
`undef THIS_CLASS
`endif
