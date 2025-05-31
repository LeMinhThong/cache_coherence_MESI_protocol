`ifndef MESI_TEST_SVH
`define MESI_TEST_SVH
`define THIS_CLASS mesi_test_c

class `THIS_CLASS extends cache_base_test_c;
  `uvm_component_utils(`THIS_CLASS)

  extern  virtual task  run_seq();

  function new(string name="`THIS_CLASS", uvm_component parent);
    super.new(name, parent);
  endfunction: new
endclass: `THIS_CLASS

// ------------------------------------------------------------------
task `THIS_CLASS::run_seq();
  address_t addr = 64'h400;

  fork
    begin
      #7us `uvm_fatal(get_type_name(), "test run_seq reached timeout")
    end
    
    begin
      send_l1_rd(addr, SURSP_FETCH);
      send_l1_rd(addr);
      send_snp_rfo(addr);
      send_l1_rd(addr, SURSP_FETCH);
      //send_l1_rfo(addr);
      //send_l1_wb(addr);
      //send_l1_rd(addr);
      //send_l1_md(addr);
      //send_l1_md(addr);
      //send_snp_rd(addr);
      //send_snp_rd(addr);
      //send_snp_rfo(addr);
      //send_l1_rfo(addr);
      //send_snp_rfo(addr);
      //send_l1_rd(addr, SURSP_SNOOP);
      //send_l1_rd(addr);
      //send_l1_rfo(addr);
      //send_snp_rd(addr);
      //send_snp_inv(addr);
      //send_l1_rd(addr, SURSP_FETCH);
      //send_snp_rd(addr);
      //send_l1_md(addr);
      //send_l1_wb(addr);
      //send_l1_rfo(addr);
      //send_l1_wb(addr);
      //send_snp_rfo(addr);
      //send_snp_rd(addr);
      //send_snp_rfo(addr);
      //send_snp_inv(addr);
      //send_l1_rd(addr, SURSP_FETCH);
      //send_l1_md(addr);
      //send_l1_wb(addr);
      //send_snp_rd(addr);
    end
  join_any
  `uvm_info(get_type_name(), "run_seq complete", UVM_DEBUG)
endtask: run_seq

`undef THIS_CLASS
`endif
