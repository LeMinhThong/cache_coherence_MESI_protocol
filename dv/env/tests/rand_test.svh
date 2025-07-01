`ifndef RANDOM_TEST_SVH
`define RANDOM_TEST_SVH
`define THIS_CLASS rand_test_c

class `THIS_CLASS extends cache_base_test_c;
  `uvm_component_utils(`THIS_CLASS)

  extern  virtual task  run_seq();

  function new(string name="`THIS_CLASS", uvm_component parent);
    super.new(name, parent);
    m_timeout = 100us;
  endfunction: new

endclass: `THIS_CLASS

// ------------------------------------------------------------------
task `THIS_CLASS::run_seq();
  rand_seq_c m_seq = new();
  m_seq.m_num_txn = 500;
  `START_SEQ(m_seq);

  `uvm_info(get_type_name(), "run_seq complete", UVM_DEBUG)
endtask: run_seq

`undef THIS_CLASS
`endif
