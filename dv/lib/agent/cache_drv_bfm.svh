`ifndef CACHE_DRV_BFM_SVH
`define CACHE_DRV_BFM_SVH
`define THISCLASS cache_drv_bfm_c
`define M_VIF m_vif.drv_cb

class `THISCLASS extends uvm_component;
  `uvm_component_utils(`THISCLASS)

  uvm_blocking_put_imp      #(cache_txn_c, `THISCLASS)  req_imp;
  uvm_nonblocking_put_port  #(cache_txn_c)              rsp_port;

  virtual cache_if m_vif;

  bit txn_outstanding = 0;

  extern  virtual function  void  build_phase(uvm_phase phase);
  extern  virtual task            run_phase(uvm_phase phase);
  extern  virtual task            get_and_drive();
  extern  virtual task            reset_handler();
  extern  virtual task            init_signals();
  extern  virtual task            put(cache_txn_c t);

  function new(string name="`THISCLASS", uvm_component parent);
    super.new(name, parent);
  endfunction: new
endclass: `THISCLASS

//-------------------------------------------------------------------
function void `THISCLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(virtual cache_if)::get(this, "", "cac_if", m_vif)) uvm_report_fatal("DRIVER_BFM", "Cannot get virtual cache interface");
  this.req_imp = new("req_imp", this);
  this.rsp_port = new("rsp_port", this);
endfunction: build_phase

//-------------------------------------------------------------------
task `THISCLASS::run_phase(uvm_phase phase);
  forever begin
    fork
      begin
        get_and_drive();
      end
      begin
        reset_handler();
      end
    join_any
    `uvm_info("DRIVER_BFM", "flush all pending transation", UVM_DEBUG)
    disable fork;
    #0ns;
  end
endtask: run_phase

//-------------------------------------------------------------------
task `THISCLASS::get_and_drive();
  cache_txn_c t_req;
  cache_txn_c t_rsp;

  forever begin
    @`M_VIF;
    wait(`M_VIF.rst_n == 1'b1);
    `uvm_info("DRIVER_BFM", "Driving signals", UVM_DEBUG)
  end
endtask: get_and_drive

//-------------------------------------------------------------------
task `THISCLASS::reset_handler();
  cache_txn_c t_req;
  cache_txn_c t_rsp;
  forever begin
    wait(`M_VIF.rst_n == 1'b0);
    `uvm_info("DRIVER_BFM", "Reset is handling", UVM_DEBUG)
    if(txn_outstanding) `uvm_fatal("DRIVER_BFM", "reset occurred during transfer")
    init_signals();
    fork
      begin: WAIT_UNLOCK_RESET
        wait(`M_VIF.rst_n == 1'b1);
        `uvm_info("DRIVER_BFM", "Reset has completed", UVM_DEBUG)
        disable WAIT_UNLOCK_RESET;
      end
    join
  end
endtask: reset_handler

//-------------------------------------------------------------------
task `THISCLASS::put(cache_txn_c t);
endtask: put

//-------------------------------------------------------------------
task `THISCLASS::init_signals();
  `M_VIF.rx_l1_op     <= L1_NO_REQ;
  `M_VIF.rx_l1_addr   <= '0;
  `M_VIF.rx_l1_data   <= '0;

  `M_VIF.rx_snp_op    <= SNP_NO_REQ;
  `M_VIF.rx_snp_addr  <= '0;
  `M_VIF.rx_snp_data  <= '0;
  `M_VIF.rx_snp_rsp   <= SNP_NO_RSP;
endtask: init_signals

`undef M_VIF
`undef THISCLASS
`endif
