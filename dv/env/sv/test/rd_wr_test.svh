`ifndef RD_WR_TEST_SVH
`define RD_WR_TEST_SVH
`define THIS_CLASS rd_wr_test_c

class `THIS_CLASS extends cache_base_test_c;
  `uvm_component_utils(`THIS_CLASS)

  extern  virtual task  run_seq();

  function new(string name="`THIS_CLASS", uvm_component parent);
    super.new(name, parent);
  endfunction: new
endclass: `THIS_CLASS

// ------------------------------------------------------------------
task `THIS_CLASS::run_seq();
  //l1_req_seq_c  m_l1_seq  = new();

  //m_l1_seq.set_seq(CDREQ_RD, 64'h400);
  //m_l1_seq.set_snp_rsp(SURSP_FETCH, 512'h1);
  //`START_SEQ(m_l1_seq)

  //m_l1_seq = new();
  //m_l1_seq.set_seq(CDREQ_RFO, 64'h401);
  //m_l1_seq.set_snp_rsp(SURSP_OKAY, 512'h2);
  //`START_SEQ(m_l1_seq)
  `uvm_info(get_type_name(), "seq complete", UVM_LOW)
endtask: run_seq

`undef THIS_CLASS
`endif
