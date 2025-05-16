`ifndef CACHE_DRV_BFM_SVH
`define CACHE_DRV_BFM_SVH
`define THISCLASS cache_drv_bfm_c
`define M_VIF m_vif.drv_cb

class `THISCLASS extends uvm_component;
  `uvm_component_utils(`THISCLASS)

  uvm_blocking_put_imp      #(cache_txn_c, `THISCLASS)  req_imp;
  uvm_nonblocking_put_port  #(cache_txn_c)              rsp_port;

  virtual cache_if m_vif;

  cache_txn_c l1_req_q[$];
  cache_txn_c snp_req_q[$];

  string  m_msg_name = "DRV_BFM";
  bit     rand_snp_delay = 0;

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

  function new(string name="`THISCLASS", uvm_component parent);
    super.new(name, parent);
  endfunction: new
endclass: `THISCLASS

//-------------------------------------------------------------------
function void `THISCLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(virtual cache_if)::get(this, "", "cac_if", m_vif)) uvm_report_fatal(m_msg_name, "Cannot get virtual cache interface");
  this.req_imp = new("req_imp", this);
  this.rsp_port = new("rsp_port", this);
endfunction: build_phase

//-------------------------------------------------------------------
task `THISCLASS::run_phase(uvm_phase phase);
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
task `THISCLASS::get_and_drive();
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
task `THISCLASS::drive_l1_transfer();
  cache_txn_c t_req;
  cache_txn_c t_rsp;
  sdreq_e     sdreq_op_loc;

  init_l1_transfer = 1'b1;
  while(l1_req_q.size() > 0) begin
    t_req = l1_req_q.pop_front();
    `uvm_info(m_msg_name, $sformatf("drive L1 request: t_req=%s", t_req.convert2string()), UVM_DEBUG)
    t_rsp = new t_req;

    fork
      begin
        `M_VIF.cdreq_valid  <= 1'b1;
        `M_VIF.cdreq_op     <= t_req.cdreq_op;
        `M_VIF.cdreq_addr   <= t_req.cdreq_addr;
        if(t_req.is_wr_req())
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

      begin: RESPONSE_SDREQ_BLK
        @(posedge `M_VIF.sdreq_valid);
        repeat(2) @`M_VIF;
        sdreq_op_loc = sdreq_e'(`M_VIF.sdreq_op);
        // accept request from sdreq
        `M_VIF.sdreq_ready  <= 1'b1;
        @`M_VIF;
        `M_VIF.sdreq_ready  <= 1'b0;
        @`M_VIF;

        // send response on sursp
        `M_VIF.sursp_valid  <= 1'b1;
        if(sdreq_op_loc inside {SDREQ_RD, SDREQ_RFO}) begin
          `M_VIF.sursp_rsp  <= t_req.sursp_rsp;
          `M_VIF.sursp_data <= t_req.sursp_data;
        end
        else begin
          `M_VIF.sursp_rsp  <= SURSP_OKAY;
          `M_VIF.sursp_data <= '0;
        end
        @(posedge `M_VIF.sursp_ready);
        `M_VIF.sursp_valid  <= 1'b0;
        `M_VIF.sursp_rsp    <= '0;
        `M_VIF.sursp_data   <= '0;
      end: RESPONSE_SDREQ_BLK

      begin
        @(posedge `M_VIF.cursp_valid);
        t_rsp.cursp_rsp   = cursp_e'(`M_VIF.cursp_rsp);
        t_rsp.cursp_data  = `M_VIF.cursp_data;

        repeat(2) @`M_VIF;
        `M_VIF.cursp_ready <= 1'b1;
        @`M_VIF;
        `M_VIF.cursp_ready <= 1'b0;
        // out fork join in cases no sdreq request initiated
        disable RESPONSE_SDREQ_BLK;
      end
    join
  end
  init_l1_transfer = 1'b0;
endtask: drive_l1_transfer

    //@m_vif.mon_cb;
    //if(m_vif.sdreq_op != SDREQ_RD) begin
    //  @`M_VIF;
    //  `uvm_info(m_msg_name, $sformatf("<CACHE_MISS> snp_rsp: %s, snp_data: 0x%0h", t_req.sursp_rsp.name(), t_req.sursp_data), UVM_DEBUG)
    //  if(rand_snp_delay) begin
    //    repeat($urandom_range(1, 5)) @`M_VIF;
    //  end
    //  `M_VIF.sursp_rsp   <= t_req.sursp_rsp;
    //  `M_VIF.sursp_data  <= t_req.sursp_data;

    //  @`M_VIF;
    //  `M_VIF.sursp_rsp   <= SURSP_OKAY;
    //  `M_VIF.sursp_data  <= '0;
    //end

    //if(!t_req.is_wr_req())  t_rsp.cursp_data = m_vif.cursp_data;

    //`uvm_info(m_msg_name, $sformatf("put L1 response: %s", t_rsp.convert2string()), UVM_DEBUG)
    //send_reponse(t_rsp);

    //@`M_VIF;
    //`M_VIF.cdreq_op     <= CDREQ_RD;
    //`M_VIF.cdreq_addr   <= '0;

//-------------------------------------------------------------------
task `THISCLASS::drive_snp_transfer();
  cache_txn_c t_req;
  cache_txn_c t_rsp;

  init_snp_transfer = 1'b1;
  while(snp_req_q.size() > 0) begin
    t_req = snp_req_q.pop_front();
    `uvm_info(m_msg_name, $sformatf("drive snoop request: t_req=%s", t_req.convert2string()), UVM_DEBUG)
    t_rsp = new t_req;

    `M_VIF.sureq_op    <= t_req.sureq_op;
    `M_VIF.sureq_addr  <= t_req.sureq_addr;

    @m_vif.mon_cb;
    t_rsp.sdrsp_rsp  = sdrsp_e'(m_vif.sdrsp_rsp);
    t_rsp.sdrsp_data = m_vif.sdrsp_data;

    @`M_VIF;
    `M_VIF.sureq_op    <= SUREQ_RD;
    `M_VIF.sureq_addr  <= '0;

    `uvm_info(m_msg_name, $sformatf("put snoop response: %s", t_rsp.convert2string()), UVM_DEBUG)
    send_reponse(t_rsp);
  end
  init_snp_transfer = 1'b0;
endtask

//-------------------------------------------------------------------
task `THISCLASS::reset_monitoring();
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
task `THISCLASS::reset_signals();
  //`M_VIF.cdreq_op     <= CDREQ_RD;
  //`M_VIF.cdreq_addr   <= '0;
  //`M_VIF.cdreq_data   <= '0;

  //`M_VIF.sureq_op    <= SUREQ_RD;
  //`M_VIF.sureq_addr  <= '0;
  //`M_VIF.sursp_data  <= '0;
  //`M_VIF.sursp_rsp   <= SURSP_OKAY;

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
task `THISCLASS::put(cache_txn_c txn);
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
task `THISCLASS::send_reponse(cache_txn_c t_rsp);
  void'(this.rsp_port.try_put(t_rsp));
endtask: send_reponse

`undef M_VIF
`undef THISCLASS
`endif
