`ifndef LRU_REPL_TEST_SVH
`define LRU_REPL_TEST_SVH
`define THIS_CLASS lru_repl_test_c

class `THIS_CLASS extends cache_base_test_c;
  `uvm_component_utils(`THIS_CLASS)

  extern  virtual task  run_seq();

  function new(string name="`THIS_CLASS", uvm_component parent);
    super.new(name, parent);
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
task `THIS_CLASS::run_seq();
  send_l1_rd('h400, SURSP_FETCH);
  send_l1_rd('h800, SURSP_FETCH);
  send_l1_rd('ha00, SURSP_FETCH);
  send_l1_rd('hc00, SURSP_FETCH);

  send_l1_rd('h400, SURSP_FETCH);
  send_l1_rd('h800, SURSP_FETCH);
  send_l1_rd('ha00, SURSP_FETCH);
  send_l1_rd('hc00, SURSP_FETCH);

  send_l1_rd('hc00, SURSP_FETCH);
  send_l1_rd('ha00, SURSP_FETCH);
  send_l1_rd('h800, SURSP_FETCH);
  send_l1_rd('h400, SURSP_FETCH);

  send_l1_rd('h1400, SURSP_FETCH);
  send_l1_rd('h1800, SURSP_FETCH);
  send_l1_rd('h1a00, SURSP_FETCH);
  send_l1_rd('h1c00, SURSP_FETCH);

endtask: run_seq

`undef THIS_CLASS
`endif
