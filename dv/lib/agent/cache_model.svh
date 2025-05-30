`ifndef CACHE_MODEL_SVH
`define CACHE_MODEL_SVH
`define THIS_CLASS cache_model_c

typedef struct packed {
  data_t  data;
  tag_t   tag;
  st_e    state;
} block_s;

class `THIS_CLASS extends uvm_component;
  `uvm_component_utils(`THIS_CLASS)

  block_s m_cache[`VIP_NUM_BLK];
  
  string  m_msg_name = "CACHE";

  extern  virtual function  void    build_phase(uvm_phase phase);

  extern  virtual function  void    init_cache();
  extern  virtual function  st_e    get_state (address_t addr);
  extern  virtual function  tag_t   get_tag   (address_t addr);
  extern  virtual function  data_t  get_data  (address_t addr);
  extern  virtual function  void    set_state (address_t addr, st_e state);
  extern  virtual function  void    set_tag   (address_t addr);
  extern  virtual function  void    set_data  (address_t addr, data_t data);

  function new(string name="`THIS_CLASS", uvm_component parent);
    super.new(name, parent);
  endfunction: new
endclass: `THIS_CLASS

// ------------------------------------------------------------------
function void `THIS_CLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction: build_phase

// ------------------------------------------------------------------
function void `THIS_CLASS::init_cache();
  `uvm_info(m_msg_name, "init cache occurred", UVM_LOW)
  foreach(m_cache[i]) begin
    m_cache[i] = '{default: 0};
  end
endfunction: init_cache

// ------------------------------------------------------------------
function st_e `THIS_CLASS::get_state(address_t addr);
  return m_cache[addr[`IDX]].state;
endfunction: get_state

function tag_t `THIS_CLASS::get_tag(address_t addr);
  return m_cache[addr[`IDX]].tag;
endfunction: get_tag

function data_t `THIS_CLASS::get_data(address_t addr);
  return m_cache[addr[`IDX]].data;
endfunction: get_data

// ------------------------------------------------------------------
function void `THIS_CLASS::set_state(address_t addr, st_e state);
  m_cache[addr[`IDX]].state = state;
endfunction: set_state

function void `THIS_CLASS::set_tag(address_t addr);
  m_cache[addr[`IDX]].tag = addr[`ADDR_TAG];
endfunction: set_tag

function void `THIS_CLASS::set_data(address_t addr, data_t data);
  m_cache[addr[`IDX]].data = data;
endfunction: set_data

`undef THIS_CLASS
`endif
