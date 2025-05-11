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

  init_l1_transfer = 1'b1;
  while(l1_req_q.size() > 0) begin
    t_req = l1_req_q.pop_front();
    `uvm_info(m_msg_name, $sformatf("drive L1 request: t_req=%s", t_req.convert2string()), UVM_DEBUG)
    t_rsp = new t_req;

    `M_VIF.cdr_op   <= t_req.cdr_op;
    `M_VIF.cdr_addr <= t_req.cdr_addr;
    if(t_req.is_wr_req()) `M_VIF.cdr_data <= t_req.cdr_data;
    else                  `M_VIF.cdr_data <= '0;

    @m_vif.mon_cb;
    if(m_vif.sdt_op != SDT_RD) begin
      @`M_VIF;
      `uvm_info(m_msg_name, $sformatf("<CACHE_MISS> snp_rsp: %s, snp_data: 0x%0h", t_req.sdr_rsp.name(), t_req.sdr_data), UVM_DEBUG)
      if(rand_snp_delay) begin
        repeat($urandom_range(1, 5)) @`M_VIF;
      end
      `M_VIF.sdr_rsp   <= t_req.sdr_rsp;
      `M_VIF.sdr_data  <= t_req.sdr_data;

      @`M_VIF;
      `M_VIF.sdr_rsp   <= SDR_OKAY;
      `M_VIF.sdr_data  <= '0;
    end

    if(!t_req.is_wr_req())  t_rsp.cdt_data = m_vif.cdt_data;

    `uvm_info(m_msg_name, $sformatf("put L1 response: %s", t_rsp.convert2string()), UVM_DEBUG)
    send_reponse(t_rsp);

    @`M_VIF;
    `M_VIF.cdr_op     <= CDR_RD;
    `M_VIF.cdr_addr   <= '0;
  end
  init_l1_transfer = 1'b0;
endtask: drive_l1_transfer

//-------------------------------------------------------------------
task `THISCLASS::drive_snp_transfer();
  cache_txn_c t_req;
  cache_txn_c t_rsp;

  init_snp_transfer = 1'b1;
  while(snp_req_q.size() > 0) begin
    t_req = snp_req_q.pop_front();
    `uvm_info(m_msg_name, $sformatf("drive snoop request: t_req=%s", t_req.convert2string()), UVM_DEBUG)
    t_rsp = new t_req;

    `M_VIF.sur_op    <= t_req.sur_op;
    `M_VIF.sur_addr  <= t_req.sur_addr;

    @m_vif.mon_cb;
    t_rsp.sut_rsp  = sut_e'(m_vif.sut_rsp);
    t_rsp.sut_data = m_vif.sut_data;

    @`M_VIF;
    `M_VIF.sur_op    <= SUR_RD;
    `M_VIF.sur_addr  <= '0;

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
  `M_VIF.cdr_op     <= CDR_RD;
  `M_VIF.cdr_addr   <= '0;
  `M_VIF.cdr_data   <= '0;

  `M_VIF.sur_op    <= SUR_RD;
  `M_VIF.sur_addr  <= '0;
  `M_VIF.sdr_data  <= '0;
  `M_VIF.sdr_rsp   <= SDR_OKAY;
endtask: reset_signals

//-------------------------------------------------------------------
task `THISCLASS::put(cache_txn_c txn);
  cache_txn_c loc_txn = new txn;
  put_flag = 1'b1;
  if      (loc_txn.Type == L1_REQ)  l1_req_q.push_back(loc_txn);
  else if (loc_txn.Type == SNP_REQ) snp_req_q.push_back(loc_txn);
  else                              `uvm_fatal(m_msg_name, "Can not determine request type")
endtask: put

//-------------------------------------------------------------------
task `THISCLASS::send_reponse(cache_txn_c t_rsp);
  void'(this.rsp_port.try_put(t_rsp));
endtask: send_reponse

`undef M_VIF
`undef THISCLASS
`endif
