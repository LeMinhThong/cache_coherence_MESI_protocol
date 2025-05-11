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
  l1_req_seq_c  m_l1_seq  = new();
  snp_req_seq_c m_snp_seq = new();

  #50ns;

  m_l1_seq.set_as_rd_seq(64'h20);
  `START_SEQ(m_l1_seq)

  @`M_VIF;
  m_l1_seq = new();
  m_l1_seq.set_as_wr_seq(64'h20, 32'hbb);
  `START_SEQ(m_l1_seq)

  @`M_VIF;
  m_l1_seq = new();
  m_l1_seq.set_as_rd_seq(64'h20);
  `START_SEQ(m_l1_seq)
endtask: run_seq

`undef THIS_CLASS
`endif
