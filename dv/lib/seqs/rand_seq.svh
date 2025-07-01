`ifndef RAND_SEQ_SVH
`define RAND_SEQ_SVH
`define THIS_CLASS rand_seq_c

class `THIS_CLASS extends cache_base_seq_c;
  `uvm_object_utils(`THIS_CLASS)

  int       m_num_txn;
  bit       m_rand_fixed_idx;
  bit       m_rand_fixed_way;

  idx_t     m_fixed_idx;
  way_t     m_fixed_way;

  string    m_msg_name  = "RAND_SEQ";

  extern  virtual task            body();
  extern  virtual function  void  init_seq();

  function new(string name="`THIS_CLASS");
    super.new(name);
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
task `THIS_CLASS::body();
  cache_txn_c t_req;
  cache_txn_c t_rsp;

  `uvm_info(m_msg_name, $sformatf("start body"), UVM_LOW)

  init_seq();

  for(int i = 0; i < m_num_txn; i++) begin
    t_req = new();
    t_rsp = new();

    assert(t_req.randomize() with {
          //if(m_rand_fixed_idx) t_req.;
          //if(m_rand_fixed_way) t_req.;
    })
    else begin
      `uvm_fatal(m_msg_name, $sformatf("random transaction failed"))
    end;
    t_req.Type_xfr = ALL_CH;
    `uvm_info(m_msg_name, $sformatf("send t_req:%s", t_req.convert2string()), UVM_LOW)
    send_seq(t_req, t_rsp);
  end
  `uvm_info(m_msg_name, $sformatf("complete body"), UVM_DEBUG)
endtask: body

//-------------------------------------------------------------------
function void `THIS_CLASS::init_seq();
  if(m_rand_fixed_idx) m_fixed_idx = randomize(m_fixed_idx);
  if(m_rand_fixed_way) m_fixed_way = randomize(m_fixed_way);
endfunction:init_seq

`undef rand_seq_c
`endif
