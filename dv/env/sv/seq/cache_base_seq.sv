`ifndef CACHE_BASE_SEQ_SV
`define CACHE_BASE_SEQ_SV
`define THIS_CLASS cache_base_seq_c

class `THIS_CLASS extends uvm_sequence;
  `uvm_object_utils(`THIS_CLASS);

  extern  task  body();

  function new(string name="`THIS_CLASS");
    super.new(name);
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
task `THIS_CLASS::body();
  cache_txn_c t_req = new();

  `uvm_info(get_type_name(), "Sequence start", UVM_LOW);
  if(!t_req.randomize()) `uvm_fatal(get_type_name(), "sequence randomize fail");
  `uvm_info("BASE_SEQ", $sformatf("%s", t_req.convert2string()), UVM_LOW);
  #200ns;  
  `uvm_info(get_type_name(), "Sequence complete", UVM_LOW);
endtask: body

`undef THIS_CLASS
`endif
