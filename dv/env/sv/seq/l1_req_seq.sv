`ifndef L1_REQ_SEQ
`define L1_REQ_SEQ
`define THIS_CLASS l1_req_seq_c

class `THIS_CLASS extends cache_base_seq_c;
  `uvm_object_utils(`THIS_CLASS)

  l1_op_e   m_l1_op;
  address_t m_l1_addr;
  data_t    m_l1_data;

  snp_rsp_e m_snp_rsp;
  data_t    m_snp_data;

  extern  virtual task            body();
  extern  virtual function  void  config_seq(l1_op_e l1_op, address_t l1_addr, data_t l1_data, snp_rsp_e snp_rsp, data_t snp_data);

  function new(string name="`THIS_CLASS");
    super.new(name);
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
task `THIS_CLASS::body();
  cache_txn_c t_req = new();
  cache_txn_c t_rsp = new();

  `uvm_info(get_type_name(), "hello from body", UVM_DEBUG);
  assert(randomize(t_req) with {
    t_req.rx_l1_op    == m_l1_op;
    t_req.rx_l1_addr  == m_l1_addr;
    if(m_l1_op == L1_WR)
      t_req.rx_l1_data  == m_l1_data;
    else
      t_req.rx_l1_data  == '0;
    t_req.rx_snp_rsp  == m_snp_rsp;
    t_req.rx_snp_data == m_snp_data;
  }) else `uvm_fatal(get_type_name(), "randomize sequence with failed")

  send_seq(t_req, t_rsp);
  `uvm_info(get_type_name(), "complete body", UVM_DEBUG);
endtask: body

//-------------------------------------------------------------------
function void `THIS_CLASS::config_seq(l1_op_e l1_op, address_t l1_addr, data_t l1_data, snp_rsp_e snp_rsp, data_t snp_data);
  m_l1_op     = l1_op;
  m_l1_addr   = l1_addr;
  m_l1_data   = l1_data;

  m_snp_rsp   = snp_rsp;
  m_snp_data  = snp_data;
endfunction: config_seq

`undef THIS_CLASS
`endif
