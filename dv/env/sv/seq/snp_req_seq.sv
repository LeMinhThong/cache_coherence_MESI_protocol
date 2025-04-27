`ifndef SNP_REQ_SEQ
`define SNP_REQ_SEQ
`define THIS_CLASS snp_req_seq_c

class `THIS_CLASS extends cache_base_seq_c;
  `uvm_object_utils(`THIS_CLASS)

  extern  virtual task  body();

  function new(string name="`THIS_CLASS");
    super.new(name);
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
task `THIS_CLASS::body();
  `uvm_info(get_type_name(), "hello from body", UVM_DEBUG);
  #50ns;
  `uvm_info(get_type_name(), "complete body", UVM_DEBUG);
endtask: body

`undef THIS_CLASS
`endif
