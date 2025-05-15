`ifndef L1_REQ_SEQ
`define L1_REQ_SEQ
`define THIS_CLASS l1_req_seq_c

class `THIS_CLASS extends cache_base_seq_c;
  `uvm_object_utils(`THIS_CLASS)

  cdreq_e   m_op;
  address_t m_addr;
  data_t    m_l1_data;

  sursp_e   m_snp_rsp   = SURSP_FETCH;
  data_t    m_snp_data  = 512'hFE;

  extern  virtual task            body();
  extern  virtual function  void  set_seq(cdreq_e op, address_t addr, data_t data='0);
  extern  virtual function  void  set_as_wr_seq(address_t addr, data_t data);
  extern  virtual function  void  set_as_rd_seq(address_t addr);
  extern  virtual function  void  set_snp_rsp(sursp_e snp_rsp=SURSP_FETCH, data_t data=8'hFE);

  function new(string name="`THIS_CLASS");
    super.new(name);
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
function void `THIS_CLASS::set_seq(cdreq_e op, address_t addr, data_t data='0);
  m_op      = op;
  m_addr    = addr;
  if(op == CDREQ_WB)  m_l1_data = data;
  else                m_l1_data = '0;
endfunction: set_seq

//-------------------------------------------------------------------
function void `THIS_CLASS::set_as_wr_seq(address_t addr, data_t data);
  m_op      = CDREQ_WB;
  m_addr    = addr;
  m_l1_data = data;
endfunction: set_as_wr_seq

//-------------------------------------------------------------------
function void `THIS_CLASS::set_as_rd_seq(address_t addr);
  m_op      = CDREQ_RD;
  m_addr    = addr;
  m_l1_data = '0;
endfunction: set_as_rd_seq

//-------------------------------------------------------------------
function void `THIS_CLASS::set_snp_rsp(sursp_e snp_rsp=SURSP_FETCH, data_t data=8'hFE);
  m_snp_rsp   = snp_rsp;
  m_snp_data  = data;
endfunction: set_snp_rsp

//-------------------------------------------------------------------
task `THIS_CLASS::body();
  cache_txn_c t_req = new();
  cache_txn_c t_rsp = new();

  `uvm_info(get_type_name(), "start body", UVM_DEBUG);
  assert(randomize(t_req) with {
    t_req.Type        == L1_REQ;
    t_req.cdreq_op    == m_op;
    t_req.cdreq_addr  == m_addr;
    t_req.cdreq_data  == m_l1_data;

    t_req.sursp_rsp  == m_snp_rsp;
    t_req.sursp_data == m_snp_data;
  }) else `uvm_fatal(get_type_name(), "randomize transaction with failed")

  send_seq(t_req, t_rsp);
  `uvm_info(get_type_name(), "complete body", UVM_DEBUG);
endtask: body

`undef THIS_CLASS
`endif
