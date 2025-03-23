`ifndef CACHE_TRANSACTION_SV
`define CACHE_TRANSACTION_SV
`define THIS_CLASS cache_transaction

class `THIS_CLASS extends uvm_sequence_item;
  localparam LINE_WIDTH     = `VIP_LINE_WIDTH;
  localparam NUM_CACHE_LINE = `VIP_NUM_CACHE_LINE;
  localparam ADDR_WIDTH     = `VIP_ADDR_WIDTH;
  localparam DATA_WIDTH     = `VIP_DATA_WIDTH;

  integer                   TransId;

  rand bit                   Write;
  rand bit  [ADDR_WIDTH-1:0] Address;
  rand bit  [LINE_WIDTH-1:0] LineData;

  rand bit  [2:0]            State;

  rand bit  [1:0]            Bus2cacBusReq;
  rand bit  [1:0]            Bus2cacBusRsp;

  rand bit  [1:0]            Cac2busBusReq;
  rand bit  [1:0]            Cac2busBusRsp;

  // ----------------------------------------------------------------
  `uvm_object_utils_begin(`THIS_CLASS)
    `uvm_field_int(TransId, UVM_DEFAULT)
    `uvm_field_int(Write, UVM_DEFAULT)
    `uvm_field_int(Address, UVM_DEFAULT)
    `uvm_field_int(LineData, UVM_DEFAULT)
    `uvm_field_int(State, UVM_DEFAULT)
    `uvm_field_int(Bus2cacBusReq, UVM_DEFAULT)
    `uvm_field_int(Bus2cacBusRsp, UVM_DEFAULT)
    `uvm_field_int(Cac2busBusRsp, UVM_DEFAULT)
    `uvm_field_int(Cac2busBusRsp, UVM_DEFAULT)
  `uvm_object_utils_end

  // ----------------------------------------------------------------
  function new(string name="`THIS_CLASS");
    super.new(name);
    TransId = -1;
  endfunction: new
endclass: `THIS_CLASS

`undef THIS_CLASS
`endif
