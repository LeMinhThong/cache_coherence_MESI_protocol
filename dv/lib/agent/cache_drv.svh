`ifndef CACHE_DRV_SVH
`define CACHE_DRV_SVH
`define THIS_CLASS cache_drv_c
`define M_VIF m_vif.drv_cb 

class `THIS_CLASS extends uvm_driver #(cache_txn_c);
  `uvm_component_utils(`THIS_CLASS);

  uvm_blocking_put_port   #(cache_txn_c)              req_port;
  uvm_nonblocking_put_imp #(cache_txn_c, `THIS_CLASS) rsp_imp;

  virtual cache_if m_vif;

  semaphore   sema_reset;
  cache_txn_c t_req;
  cache_txn_c t_rsp;
  cache_txn_c req_q[$];

  extern          function  void  build_phase(uvm_phase phase);
  extern          task            run_phase(uvm_phase phase);
  extern          task            drive_request();
  extern          task            reset_handler();
  extern  virtual function  bit   try_put(cache_txn_c rsp_txn);
  extern  virtual function  bit   can_put();

  function new(string name="`THIS_CLASS", uvm_component component);
    super.new(name, component);
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
function void `THIS_CLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(virtual cache_if)::get(this, "", "cac_if", m_vif)) uvm_report_fatal("DRIVER", "Cannot get virtual cache interface");
  sema_reset = new(1);
  this.req_port = new("req_port", this);
  this.rsp_imp = new("rsp_imp", this);
endfunction: build_phase

//-------------------------------------------------------------------
task `THIS_CLASS::run_phase(uvm_phase phase);
  fork
    begin
      drive_request();
    end
    begin
      reset_handler();
    end
  join
endtask: run_phase

//-------------------------------------------------------------------
task `THIS_CLASS::drive_request();
  forever begin
    sema_reset.get(1);
    sema_reset.put(1);
    seq_item_port.get(t_req);
    `uvm_info("DRV", $sformatf("Receive request from sequencer: %s", t_req.convert2string()), UVM_DEBUG)
    req_q.push_back(t_req);
    this.req_port.put(t_req);
  end
endtask: drive_request

//-------------------------------------------------------------------
task `THIS_CLASS::reset_handler();
  forever begin
    wait((`M_VIF.rst_n == 1'b0));
    sema_reset.get(1);
    wait((`M_VIF.rst_n == 1'b1));
    sema_reset.put(1);
  end
endtask: reset_handler

//-------------------------------------------------------------------
function bit `THIS_CLASS::try_put(cache_txn_c rsp_txn);
  return 1;
endfunction: try_put

//-------------------------------------------------------------------
function bit `THIS_CLASS::can_put();
  return 1;
endfunction: can_put

`undef M_VIF
`undef THIS_CLASS
`endif
