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
  idx_t     idx = 0;
  tag_t     tag = 0;

  fork
    begin
      #15us `uvm_fatal(get_type_name(), "test run_seq reached timeout")
    end
    
    begin
      send_l1_rd  ({tag, idx}, SURSP_FETCH);
      send_l1_rd  ({tag, idx});
      send_snp_rfo({tag, idx});
      send_l1_rd  ({tag, idx}, SURSP_FETCH);
      send_l1_rfo ({tag, idx});
      send_l1_wb  ({tag, idx});
      send_l1_rd  ({tag, idx});
      send_l1_md  ({tag, idx});
      send_l1_md  ({tag, idx});
      send_snp_rd ({tag, idx});
      send_snp_rd ({tag, idx});
      send_snp_rfo({tag, idx});
      send_l1_rfo ({tag, idx});
      send_snp_rfo({tag, idx});
      send_l1_rd  ({tag, idx}, SURSP_SNOOP);
      send_l1_rd  ({tag, idx});
      send_l1_rfo ({tag, idx});
      send_snp_rd ({tag, idx});
      send_snp_inv({tag, idx});
      send_l1_rd  ({tag, idx}, SURSP_FETCH);
      send_snp_rd ({tag, idx});
      send_l1_md  ({tag, idx});
      send_l1_wb  ({tag, idx});
      send_l1_rfo ({tag, idx});
      send_l1_wb  ({tag, idx});
      send_snp_rfo({tag, idx});
      send_snp_rd ({tag, idx});
      send_snp_rfo({tag, idx});
      send_snp_inv({tag, idx});
      send_l1_rd  ({tag, idx}, SURSP_FETCH);
      send_l1_md  ({tag, idx});
      send_snp_rfo({tag, idx});
      send_l1_rd  ({tag, idx}, SURSP_FETCH);
      send_l1_wb  ({tag, idx});
      send_snp_rd ({tag, idx});

      // test EVICT
      send_l1_rd  (((32'h0 << 8) | 8'h1), SURSP_FETCH);
      send_l1_rd  (((32'h1 << 8) | 8'h1), SURSP_FETCH);
      send_l1_rd  (((32'h2 << 8) | 8'h1), SURSP_FETCH);
      send_l1_rd  (((32'h3 << 8) | 8'h1), SURSP_FETCH);
      send_l1_rd  (((32'h4 << 8) | 8'h1), SURSP_FETCH);
      send_l1_rd  (((32'h5 << 8) | 8'h1), SURSP_SNOOP);
      send_l1_rfo (((32'h6 << 8) | 8'h1));

      send_l1_rd  (((32'h0 << 8) | 8'h2), SURSP_SNOOP);
      send_l1_rd  (((32'h1 << 8) | 8'h2), SURSP_SNOOP);
      send_l1_rd  (((32'h2 << 8) | 8'h2), SURSP_SNOOP);
      send_l1_rd  (((32'h3 << 8) | 8'h2), SURSP_SNOOP);
      send_l1_rd  (((32'h4 << 8) | 8'h2), SURSP_FETCH);
      send_l1_rd  (((32'h5 << 8) | 8'h2), SURSP_SNOOP);
      send_l1_rfo (((32'h6 << 8) | 8'h2));

      send_l1_rfo (((32'h0 << 8) | 8'h3));
      send_l1_rfo (((32'h1 << 8) | 8'h3));
      send_l1_rfo (((32'h2 << 8) | 8'h3));
      send_l1_rfo (((32'h3 << 8) | 8'h3));
      send_l1_rd  (((32'h4 << 8) | 8'h3), SURSP_FETCH);
      send_l1_rd  (((32'h5 << 8) | 8'h3), SURSP_SNOOP);
      send_l1_rfo (((32'h6 << 8) | 8'h3));

      send_l1_rfo (((32'h0 << 8) | 8'h4));
      send_l1_rfo (((32'h1 << 8) | 8'h4));
      send_l1_rfo (((32'h2 << 8) | 8'h4));
      send_l1_rfo (((32'h3 << 8) | 8'h4));
      send_l1_wb  (((32'h0 << 8) | 8'h4));
      send_l1_wb  (((32'h1 << 8) | 8'h4));
      send_l1_wb  (((32'h2 << 8) | 8'h4));
      send_l1_wb  (((32'h3 << 8) | 8'h4));
      send_l1_rd  (((32'h4 << 8) | 8'h4), SURSP_FETCH);
      send_l1_rd  (((32'h5 << 8) | 8'h4), SURSP_SNOOP);
      send_l1_rfo (((32'h6 << 8) | 8'h4));
    end
  join_any
  `uvm_info(get_type_name(), "run_seq complete", UVM_DEBUG)
endtask: run_seq

`undef THIS_CLASS
`endif
