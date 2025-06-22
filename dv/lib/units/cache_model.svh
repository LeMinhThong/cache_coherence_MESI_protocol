`ifndef CACHE_MODEL_SVH
`define CACHE_MODEL_SVH
`define THIS_CLASS cache_model_c

typedef struct packed {
  data_t                    data;
  tag_t                     tag;
  st_e                      state;
} block_s;

class `THIS_CLASS extends uvm_component;
  `uvm_component_utils(`THIS_CLASS)

  block_s     mem[(`VIP_NUM_BLK/`VIP_NUM_WAY)][`VIP_NUM_WAY];
`ifdef PLRU_REPL
  logic [2:0] plru_tree_bit [(`VIP_NUM_BLK/`VIP_NUM_WAY)];
`elsif THESIS_REPL
`else
  `uvm_fatal(m_msg_name, "can not identify replacement policy")
`endif
  
  string      m_msg_name = "CACHE";

  extern  virtual function  void    build_phase(uvm_phase phase);

  extern  virtual function  void    init_cache();
  extern  virtual function  void    update_repl_age(idx_t idx, way_t access_way);
  extern  virtual function  bit     is_blk_valid_in_l1(address_t addr);

  extern  virtual function  idx_t   get_idx       (address_t addr);
  extern  virtual function  way_t   get_way       (address_t addr, idx_t idx, output lookup_e lookup);
  extern  virtual function  st_e    get_state     (idx_t idx, way_t way);
  extern  virtual function  tag_t   get_tag       (idx_t idx, way_t way);
  extern  virtual function  data_t  get_data      (idx_t idx, way_t way);
  extern  virtual function  way_t   get_evict_way (idx_t idx);

  extern  virtual function  void    set_state     (idx_t idx, way_t way, st_e state);
  extern  virtual function  void    set_tag       (idx_t idx, way_t way, tag_t tag);
  extern  virtual function  void    set_data      (idx_t idx, way_t way, data_t data);

  function new(string name="`THIS_CLASS", uvm_component parent);
    super.new(name, parent);
  endfunction: new
endclass: `THIS_CLASS

// ------------------------------------------------------------------
function void `THIS_CLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction: build_phase

// ------------------------------------------------------------------
function bit `THIS_CLASS::is_blk_valid_in_l1(address_t addr);
  return 1;
endfunction: is_blk_valid_in_l1

// ------------------------------------------------------------------
function void `THIS_CLASS::init_cache();
  `uvm_info(m_msg_name, "init cache occurred", UVM_LOW)
  foreach(mem[i, ii]) begin
    mem[i][ii]          = '{default: 0};
`ifdef PLRU_REPL
    plru_tree_bit[i]    = 0;
`elsif THESIS_REPL
`else
  `uvm_fatal(m_msg_name, "can not identify replacement policy")
`endif
  end
endfunction: init_cache

// ------------------------------------------------------------------

function void `THIS_CLASS::update_repl_age(idx_t idx, way_t access_way);
`ifdef PLRU_REPL
  unique case(access_way)
    2'b00:
          begin
            plru_tree_bit[idx][2] = 1'b1;
            plru_tree_bit[idx][1] = 1'b1;
          end
    2'b01:
          begin
            plru_tree_bit[idx][2] = 1'b1;
            plru_tree_bit[idx][1] = 1'b0;
          end
    2'b10:
          begin
            plru_tree_bit[idx][2] = 1'b0;
            plru_tree_bit[idx][0] = 1'b1;
          end
    2'b11:
          begin
            plru_tree_bit[idx][2] = 1'b0;
            plru_tree_bit[idx][0] = 1'b0;
          end
  endcase
`elsif THESIS_REPL
`else
  `uvm_fatal(m_msg_name, "can not identify replacement policy")
`endif
endfunction: update_repl_age

// ------------------------------------------------------------------
function idx_t `THIS_CLASS::get_idx(address_t addr);
  return addr[`IDX];
endfunction: get_idx

function way_t `THIS_CLASS::get_way(address_t addr, idx_t idx, output lookup_e lookup);
  bit [1:0] evict_way;

  for(int i=0; i < `VIP_NUM_WAY; i++) begin
    if((mem[idx][i].state != INVALID) && (mem[idx][i].tag == addr[`ADDR_TAG])) begin
      lookup = HIT;
      return i;
    end
  end
  for(int i=0; i < `VIP_NUM_WAY; i++) begin
    if(mem[idx][i].state == INVALID) begin
      lookup = FILL_INV_BLK;
      return i;
    end
  end
  lookup = EVICT_BLK;
  return get_evict_way(idx);
endfunction: get_way

function st_e `THIS_CLASS::get_state(idx_t idx, way_t way);
  return mem[idx][way].state;
endfunction: get_state

function tag_t `THIS_CLASS::get_tag(idx_t idx, way_t way);
  return mem[idx][way].tag;
endfunction: get_tag

function data_t `THIS_CLASS::get_data(idx_t idx, way_t way);
  return mem[idx][way].data;
endfunction: get_data

function way_t `THIS_CLASS::get_evict_way(idx_t idx);
  way_t evict_way;
`ifdef PLRU_REPL
  evict_way[1] = plru_tree_bit[idx][2];
  evict_way[0] = (plru_tree_bit[idx][2]) ? plru_tree_bit[idx][0] : plru_tree_bit[idx][1];
`elsif THESIS_REPL
  evict_way = 2'b00;
`else
  `uvm_fatal(m_msg_name, "can not identify replacement policy")
`endif
  return evict_way;
endfunction: get_evict_way
// ------------------------------------------------------------------
function void `THIS_CLASS::set_state(idx_t idx, way_t way, st_e state);
  mem[idx][way].state = state;
endfunction: set_state

function void `THIS_CLASS::set_tag(idx_t idx, way_t way, tag_t tag);
  mem[idx][way].tag = tag;
endfunction: set_tag

function void `THIS_CLASS::set_data(idx_t idx, way_t way, data_t data);
  mem[idx][way].data = data;
endfunction: set_data

`undef THIS_CLASS
`endif
