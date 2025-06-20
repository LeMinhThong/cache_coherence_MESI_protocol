`ifndef L1_REQ_SEQ
`define L1_REQ_SEQ
`define THIS_CLASS l1_req_seq_c

class `THIS_CLASS extends cache_base_seq_c;
  `uvm_object_utils(`THIS_CLASS)

  cdreq_e   m_op;
  address_t m_addr;
  //data_t    m_cdreq_data;

  sursp_e   m_sursp_rsp;
  //data_t    m_sursp_data;

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
    t_req.Type        == L1_REQ;
    t_req.cdreq_op    == m_op;
    t_req.cdreq_addr  == m_addr;
    //if(m_op == CDREQ_WB)
    //  t_req.cdreq_data == m_cdreq_data;
    //else
    //  t_req.cdreq_data == '0;

    if(m_op == CDREQ_RD) {
      if(m_sursp_rsp == SURSP_OKAY)
        t_req.sursp_rsp inside {SURSP_FETCH, SURSP_SNOOP};
      else
        t_req.sursp_rsp == m_sursp_rsp;
    }
    else {
      t_req.sursp_rsp == SURSP_OKAY;
    }
    //t_req.sursp_data == m_sursp_data;
  }) else `uvm_fatal(get_type_name(), "randomize transaction with failed")

  send_seq(t_req, t_rsp);
  `uvm_info(get_type_name(), "complete body", UVM_DEBUG);
endtask: body

`undef THIS_CLASS
`endif
