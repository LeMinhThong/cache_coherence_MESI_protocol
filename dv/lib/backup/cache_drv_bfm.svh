`ifndef CACHE_DRV_BFM_SVH
`define CACHE_DRV_BFM_SVH
`define THISCLASS cache_drv_bfm_c
`define M_VIF m_vif.drv_cb

class `THISCLASS extends uvm_component;
  `uvm_component_utils(`THISCLASS)

  uvm_blocking_put_imp      #(cache_txn_c, `THISCLASS)  req_imp;
  uvm_nonblocking_put_port  #(cache_txn_c)              rsp_port;

  virtual cache_if m_vif;

  cache_txn_c user_txn_q[$];
  cache_txn_c l1_req_q[$];
  cache_txn_c snp_req_q[$];
  cache_txn_c l1_rsp_q[$];
  cache_txn_c snp_rsp_q[$];

  string  m_msg_name = "DRV_BFM";
  bit     has_snp_delay = 0;

  bit     m_txn_outstanding = 0;
  bit     reset_check;
  bit     init_transfer;
  bit     init_l1_transfer;
  bit     init_snp_transfer;

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
        `uvm_info("m_msg_name", "RST_DEBUG: out-of-fork", UVM_DEBUG)
        disable fork;
        l1_req_q.delete();
        snp_req_q.delete();
        l1_rsp_q.delete();
        snp_rsp_q.delete();
        user_txn_q.delete();
        init_transfer = 1'b0;
        init_l1_transfer = 1'b0;
        init_snp_transfer = 1'b0;
      end
    end
  join
endtask: run_phase
//task `THISCLASS::run_phase(uvm_phase phase);
//  forever begin
//    fork
//      begin
//        get_and_drive();
//      end
//      begin
//        reset_monitoring();
//      end
//    join_any
//    `uvm_info(m_msg_name, "flush all pending transation", UVM_DEBUG)
//    disable fork;
//    #0ns;
//  end
//endtask: run_phase

//-------------------------------------------------------------------
task `THISCLASS::get_and_drive();
  cache_txn_c user_loc_obj;
  cache_txn_c t_req;

  wait(reset_check == 1);
  forever begin
    if(user_txn_q.size() > 0) begin
      user_loc_obj = user_txn_q.pop_front();
      $cast(t_req, user_loc_obj);
    end
    else begin
      t_req = null;
    end

    if(t_req == null) begin
      @`M_VIF;
    end
    else begin
      if(t_req.Type == L1_REQ)        l1_req_q.push_back(t_req);
      else if(t_req.Type == SNP_REQ)  snp_req_q.push_back(t_req);
      else                            `uvm_fatal(m_msg_name, "Can not determine request type")
      if((init_transfer == 1'b0) || ((init_l1_transfer == 1'b0 ) && (init_snp_transfer == 1'b0))) begin
        fork
          begin
            //drive_transfer();
            fork
              if(!init_l1_transfer)   drive_l1_transfer();
              if(!init_snp_transfer)  drive_snp_transfer();
            join_any
            init_transfer = 1'b0;
          end
        join_none
        init_transfer = 1'b1;
      end
    end
  end
endtask: get_and_drive

//task `THISCLASS::get_and_drive();
//  cache_txn_c t_req;
//  cache_txn_c t_rsp;
//
//  forever begin
//    @`M_VIF;
//    wait(`M_VIF.rst_n == 1'b1);
//    //`uvm_info(m_msg_name, "Driving signals", UVM_DEBUG)
//    if(user_txn_q.size() > 0) begin
//      t_req = user_txn_q.pop_front();
//      `uvm_info(m_msg_name, $sformatf("get and drive request: mailbox size=%0d  t_req=%s", user_txn_q.size(), t_req.convert2string()), UVM_DEBUG)
//      t_rsp = new t_req;
//      `M_VIF.rx_l1_op   <= t_req.rx_l1_op;
//      `M_VIF.rx_l1_addr <= t_req.rx_l1_addr;
//      if(t_req.is_wr_req())
//        `M_VIF.rx_l1_data <= t_req.rx_l1_data;
//      else
//        `M_VIF.rx_l1_data <= '0;
//      #10ps;
//      @`M_VIF;
//      t_rsp.tx_l1_wait  = m_vif.tx_l1_wait;
//      t_rsp.tx_l1_data  = m_vif.tx_l1_data;
//      t_rsp.tx_snp_op   = snp_op_e'(m_vif.tx_snp_op);
//      t_rsp.tx_snp_addr = m_vif.tx_snp_addr;
//      t_rsp.tx_snp_data = m_vif.tx_snp_data;
//      t_rsp.tx_snp_rsp  = snp_rsp_e'(m_vif.tx_snp_rsp);
//      send_reponse(t_rsp);
//    end
//  end
//endtask: get_and_drive

//-------------------------------------------------------------------
task `THISCLASS::drive_l1_transfer();
  cache_txn_c t_req;
  cache_txn_c t_rsp;

  init_l1_transfer = 1'b1;
  while(l1_req_q.size() > 0) begin
    `uvm_info(m_msg_name, $sformatf("L1 request queue size=%d", l1_req_q.size()), UVM_DEBUG)
    t_req = l1_req_q.pop_front();
    `uvm_info(m_msg_name, $sformatf("drive L1 request: t_req=%s", t_req.convert2string()), UVM_DEBUG)
    t_rsp = new t_req;

    //@`M_VIF;
    `M_VIF.rx_l1_op   <= t_req.rx_l1_op;
    `M_VIF.rx_l1_addr <= t_req.rx_l1_addr;
    if(t_req.is_wr_req()) `M_VIF.rx_l1_data <= t_req.rx_l1_data;
    else                  `M_VIF.rx_l1_data <= '0;

    //@`M_VIF;
    @m_vif.mon_cb;
    if(m_vif.tx_l1_wait == 1'b1) begin
      `uvm_info(m_msg_name, $sformatf("<CACHE_MISS> snp_rsp: %s, snp_data: 0x%0h", t_req.rx_snp_rsp.name(), t_req.rx_snp_data), UVM_DEBUG)
      @`M_VIF;
      if(has_snp_delay) begin
        repeat($urandom_range(1, 5)) @`M_VIF;
      end
      `M_VIF.rx_snp_rsp   <= t_req.rx_snp_rsp;
      `M_VIF.rx_snp_data  <= t_req.rx_snp_data;
    end

    @`M_VIF;
    if(!t_req.is_wr_req())  t_rsp.tx_l1_data = m_vif.tx_l1_data;
    `uvm_info(m_msg_name, $sformatf("put response: %s", t_req.convert2string()), UVM_DEBUG)
    send_reponse(t_rsp);
  end
  init_l1_transfer = 1'b0;
endtask: drive_l1_transfer

//-------------------------------------------------------------------
task `THISCLASS::drive_snp_transfer();
  cache_txn_c txn_tmp;
  init_snp_transfer = 1'b1;
  while(snp_req_q.size() > 0) begin
    txn_tmp = snp_req_q.pop_front();
    //TODO drive signals
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
        //if(m_txn_outstanding) `uvm_fatal(m_msg_name, "reset occurred during transfer")
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
task `THISCLASS::put(cache_txn_c txn);
  cache_txn_c loc_txn = new txn;
  user_txn_q.push_back(loc_txn);

  //----------------------------------
  //cache_txn_c loc_l1_txn;
  //cache_txn_c loc_snp_txn;

  //if(txn.Type == L1_REQ) begin
  //  loc_l1_txn = new txn;
  //  user_txn_q.push_back(loc_l1_txn);
  //end
  //else if(txn.Type == SNP_REQ) begin
  //  loc_snp_txn = new txn;
  //  user_txn_q.push_back(loc_snp_txn);
  //end else
  //  `uvm_fatal(m_msg_name, "can not determine transaction Type")
  //user_txn_q.push_back(loc_txn);
  //----------------------------------
endtask: put

//-------------------------------------------------------------------
task `THISCLASS::reset_signals();
  `M_VIF.rx_l1_op     <= L1_NO_REQ;
  `M_VIF.rx_l1_addr   <= '0;
  `M_VIF.rx_l1_data   <= '0;

  `M_VIF.rx_snp_op    <= SNP_NO_REQ;
  `M_VIF.rx_snp_addr  <= '0;
  `M_VIF.rx_snp_data  <= '0;
  `M_VIF.rx_snp_rsp   <= SNP_NO_RSP;
endtask: reset_signals

//-------------------------------------------------------------------
task `THISCLASS::send_reponse(cache_txn_c t_rsp);
  void'(this.rsp_port.try_put(t_rsp));
endtask: send_reponse

`undef M_VIF
`undef THISCLASS
`endif
