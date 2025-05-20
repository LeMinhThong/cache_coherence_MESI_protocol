`ifndef SNP_REQ_SEQ
`define SNP_REQ_SEQ
`define THIS_CLASS snp_req_seq_c

class `THIS_CLASS extends cache_base_seq_c;
  `uvm_object_utils(`THIS_CLASS)

  sureq_e   m_op;
  address_t m_addr;

  extern  virtual task  body();

  function new(string name="`THIS_CLASS");
    super.new(name);
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
task `THIS_CLASS::body();
  cache_txn_c t_req = new();
  cache_txn_c t_rsp = new();

  `uvm_info(get_type_name(), "start body", UVM_DEBUG);
  assert(randomize(t_req) with {
    t_req.Type        == SNP_REQ;
    t_req.sureq_op    == m_op;
    t_req.sureq_addr  == m_addr;
  }) else `uvm_fatal(get_type_name(), "randomize transaction with failed")

  send_seq(t_req, t_rsp);
  `uvm_info(get_type_name(), "complete body", UVM_DEBUG);
endtask: body

`undef THIS_CLASS
`endif
