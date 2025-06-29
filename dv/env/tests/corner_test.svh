`ifndef CORNER_TEST_SVH
`define CORNER_TEST_SVH
`define THIS_CLASS corner_test_c

class `THIS_CLASS extends cache_base_test_c;
  `uvm_component_utils(`THIS_CLASS)

  extern  virtual task  run_seq();

  function new(string name="`THIS_CLASS", uvm_component parent);
    super.new(name, parent);
  endfunction: new
endclass: `THIS_CLASS

// ------------------------------------------------------------------
task `THIS_CLASS::run_seq();
  address_t addr = 32'h401;
  fork
    begin
      #7us `uvm_fatal(get_type_name(), "test run_seq reached timeout")
    end
    begin
      // INVALID
      send_l1_md  (addr);
      send_l1_wb  (addr);
      // EXCLUSIVE
      send_l1_rd  (addr, SURSP_FETCH);
      send_l1_wb  (addr);
      send_snp_inv(addr);
      // SHARED
      send_snp_rd (addr);
      send_l1_wb  (addr);
      // MIDGRATED
      send_l1_md  (addr);
      send_l1_rd  (addr);
      send_l1_rfo (addr);
      send_snp_inv(addr);
      send_l1_wb  (addr);
      send_l1_wb  (addr);
      send_snp_inv(addr);
      // EVICT EXCLUSIVE
      send_l1_rd  (32'h002, SURSP_FETCH);
      send_l1_rd  (32'h102, SURSP_FETCH);
      send_l1_rd  (32'h202, SURSP_FETCH);
      send_l1_rd  (32'h302, SURSP_FETCH);
      send_l1_md  (32'h402);
      send_l1_wb  (32'h502);

      // EVICT SHARED
      send_l1_rd  (32'h003, SURSP_SNOOP);
      send_l1_rd  (32'h103, SURSP_SNOOP);
      send_l1_rd  (32'h203, SURSP_SNOOP);
      send_l1_rd  (32'h303, SURSP_SNOOP);
      send_l1_md  (32'h403);
      send_l1_wb  (32'h503);

      // EVICT MIGRATED
      send_l1_rfo (32'h004);
      send_l1_rfo (32'h104);
      send_l1_rfo (32'h204);
      send_l1_rfo (32'h304);
      send_l1_md  (32'h404);
      send_l1_wb  (32'h504);

      // EVICT MIGRATED
      send_l1_rfo (32'h005);
      send_l1_rfo (32'h105);
      send_l1_rfo (32'h205);
      send_l1_rfo (32'h305);
      send_l1_wb  (32'h005);
      send_l1_wb  (32'h105);
      send_l1_wb  (32'h205);
      send_l1_wb  (32'h305);
      send_l1_md  (32'h405);
      send_l1_wb  (32'h505);

      `uvm_info(get_type_name(), "run_seq complete", UVM_DEBUG)
    end
  join_any
endtask: run_seq

`undef THIS_CLASS
`endif
