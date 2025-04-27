`ifndef CACHE_BASE_SEQ_SV
`define CACHE_BASE_SEQ_SV
`define THIS_CLASS cache_base_seq_c

class `THIS_CLASS extends uvm_sequence #(cache_txn_c, cache_txn_c);
  `uvm_object_utils(`THIS_CLASS);

  semaphore   m_sem;
  int         req_cnt = 0;
  int         rsp_cnt = 0;
  cache_txn_c rsp_q[$];

  // config
  bit m_rand_seq;
  int m_rand_wr_rate;

  // if m_rand_seq == 0
  l1_op_e   m_l1_op;
  address_t m_l1_addr;
  data_t    m_l1_data;
  snp_op_e  m_snp_op;
  snp_rsp_e m_snp_rsp;
  address_t m_snp_addr;
  data_t    m_snp_data;

  extern  virtual task            body();
  extern  virtual task            gen_rand_seq();
  extern  virtual task            gen_user_cfg_seq();
  extern  virtual task            send_seq(input cache_txn_c t_req, output cache_txn_c t_rsp);
  extern  virtual function  void  response_handler(uvm_sequence_item response);
  extern  virtual task            wait_for_resp(output cache_txn_c t_rsp);

  function new(string name="`THIS_CLASS");
    super.new(name);
    use_response_handler(1);
    m_sem = new(1);
    //m_fix_rd0wr1 = -1;
    m_rand_wr_rate = 50;
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
task `THIS_CLASS::body();
  if(m_rand_seq)
    gen_rand_seq();
  else
    gen_user_cfg_seq();

  `uvm_info(get_type_name(), "Sequence complete", UVM_LOW);
endtask: body

//-------------------------------------------------------------------
task `THIS_CLASS::gen_rand_seq();
  cache_txn_c t_req = new();
  cache_txn_c t_rsp = new();

  if(!t_req.randomize()) `uvm_fatal(get_type_name(), "sequence randomize fail");
  `uvm_info(get_type_name(), $sformatf("generate random sequence: %s", t_req.convert2string()), UVM_LOW);
  randcase
    m_rand_wr_rate:     t_req.set_as_wr_req();
    100-m_rand_wr_rate: t_req.set_as_rd_req();
  endcase
  if(t_req.is_wr_req()) begin
    if(!std::randomize(t_req.rx_l1_data)) `uvm_fatal(get_type_name(), "randomize write data failed")
  end else begin
    t_req.rx_l1_data = '0;
  end
  send_seq(t_req, t_rsp);
  #50ns;
endtask: gen_rand_seq

//-------------------------------------------------------------------
task `THIS_CLASS::gen_user_cfg_seq();
endtask: gen_user_cfg_seq

//-------------------------------------------------------------------
task `THIS_CLASS::send_seq(input cache_txn_c t_req, output cache_txn_c t_rsp);
  m_sem.get(1);

  wait_for_grant();
  send_request(t_req);
  req_cnt++;
  `uvm_info(get_type_name(), $sformatf("INC_REQ_CNT: req_cnt=%0d  rsp_cnt=%0d", req_cnt, rsp_cnt), UVM_DEBUG)
  wait_for_resp(t_rsp);
  `uvm_info(get_type_name(), $sformatf("received response: %s", t_rsp.convert2string()), UVM_DEBUG)
  m_sem.put(1);
endtask: send_seq

//-------------------------------------------------------------------
function void `THIS_CLASS::response_handler(uvm_sequence_item response);
  cache_txn_c _response;
  assert($cast(_response, response)) else `uvm_fatal(get_type_name(), "Can not assign received response trans from driver to local")
  rsp_cnt++;
  `uvm_info(get_type_name(), $sformatf("INC_RSP_CNT: req_cnt=%0d  rsp_cnt=%0d", req_cnt, rsp_cnt), UVM_DEBUG)
  rsp_q.push_back(_response);
endfunction: response_handler

//-------------------------------------------------------------------
task `THIS_CLASS::wait_for_resp(output cache_txn_c t_rsp);
  if(rsp_q.size() == 0) wait (rsp_q.size() != 0);
  t_rsp = rsp_q.pop_front();
endtask: wait_for_resp

`undef THIS_CLASS
`endif
