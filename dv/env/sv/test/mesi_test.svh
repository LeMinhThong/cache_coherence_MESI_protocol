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
  fork
    begin
      #500ns `uvm_fatal(get_type_name(), "test main phase reached timeout")
    end

    begin
      address_t addr = 64'h400;

      send_l1_rd(addr, SURSP_FETCH);
      send_l1_rd(addr);
      send_snp_rfo(addr);
      `uvm_info(get_type_name(), "run_seq complete", UVM_DEBUG)
    end
  join_any
endtask: run_seq

`undef THIS_CLASS
`endif
