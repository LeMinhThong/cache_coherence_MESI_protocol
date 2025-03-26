`ifndef CACHE_BASE_SEQ_SV
`define CACHE_BASE_SEQ_SV
`define THIS_CLASS cache_base_seq

class `THIS_CLASS extends uvm_sequence;
  `uvm_object_utils(`THIS_CLASS);

  extern  task  body();

  function new(string name="`THIS_CLASS");
    super.new(name);
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
task `THIS_CLASS::body();
  cache_transaction req_txn = new("m_seq");

  `uvm_info(get_type_name(), "Sequence start", UVM_LOW);
  if(!req_txn.randomize()) `uvm_fatal(get_type_name(), "sequence randomize fail");
  `uvm_info(get_type_name(), $sformatf("Write: %b, Addr: %0h, Data %0h", req_txn.Write, req_txn.Address, req_txn.LineData), UVM_LOW);
  #50;  
  `uvm_info(get_type_name(), "Sequence complete", UVM_LOW);
endtask: body

`undef THIS_CLASS
`endif
