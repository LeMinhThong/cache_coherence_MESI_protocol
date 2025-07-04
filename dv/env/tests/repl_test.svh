`ifndef REPL_TEST_SVH
`define REPL_TEST_SVH
`define THIS_CLASS repl_test_c

class `THIS_CLASS extends cache_base_test_c;
  `uvm_component_utils(`THIS_CLASS)

  extern  virtual task  run_seq();

  function new(string name="`THIS_CLASS", uvm_component parent);
    super.new(name, parent);
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
task `THIS_CLASS::run_seq();
  send_l1_rd('h401, SURSP_FETCH);
  send_l1_rd('h501, SURSP_FETCH);
  send_l1_rd('h601, SURSP_FETCH);
  send_l1_rd('h701, SURSP_FETCH);

  send_l1_rd('h401);
  send_l1_rd('h501);
  send_l1_rd('h601);
  send_l1_rd('h701);

  send_l1_rd('hc01, SURSP_FETCH);
  send_l1_rd('hd01, SURSP_FETCH);
  send_l1_rd('he01, SURSP_FETCH);
  send_l1_rd('hf01, SURSP_FETCH);

  send_snp_rd('h001);
  send_snp_rd('h101);
  send_snp_rd('h201);
  send_snp_rd('h301);

  send_snp_rd('h401);
  send_snp_rd('h501);
  send_snp_rd('h601);
  send_snp_rd('h701);

  //send_l1_rfo('h002);
  //send_l1_rfo('h102);
  //send_l1_rfo('h202);
  //send_l1_rfo('h302);

  //send_l1_rfo('h402);
  //send_l1_rfo('h502);
  //send_l1_rfo('h602);
  //send_l1_rfo('h702);
  //send_l1_rd('h1400, SURSP_FETCH);
  //send_l1_rd('h1800, SURSP_FETCH);
  //send_l1_rd('h1a00, SURSP_FETCH);
  //send_l1_rd('h1c00, SURSP_FETCH);

endtask: run_seq

`undef THIS_CLASS
`endif
