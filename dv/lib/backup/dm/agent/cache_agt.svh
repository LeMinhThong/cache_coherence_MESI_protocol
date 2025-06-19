`ifndef CACHE_AGT_SVH
`define CACHE_AGT_SVH
`define THIS_CLASS cache_agt_c

class `THIS_CLASS extends uvm_agent;
  `uvm_component_utils(`THIS_CLASS);

  cache_seqr_c    m_sqr;
  cache_drv_c     m_drv;
  cache_drv_bfm_c m_drv_bfm;
  cache_mon_c     m_mon;

  extern  function  void  build_phase(uvm_phase phase);
  extern  function  void  connect_phase(uvm_phase phase);

  function new(string name="`THIS_CLASS", uvm_component component);
    super.new(name, component);
  endfunction: new
endclass: `THIS_CLASS

//-------------------------------------------------------------------
function void `THIS_CLASS::build_phase(uvm_phase phase);
  super.build_phase(phase);
  m_sqr     = cache_seqr_c::type_id::create("sqr", this);
  m_drv     = cache_drv_c::type_id::create("drv", this);
  m_drv_bfm = cache_drv_bfm_c::type_id::create("drv_bfm", this);
  m_mon     = cache_mon_c::type_id::create("mon", this);
endfunction: build_phase

//-------------------------------------------------------------------
function void `THIS_CLASS::connect_phase(uvm_phase phase);
  m_drv.seq_item_port.connect(m_sqr.seq_item_export);
  m_drv.rsp_port.connect(m_sqr.rsp_export);
  m_drv.req_port.connect(m_drv_bfm.req_imp);
  m_drv_bfm.rsp_port.connect(m_drv.rsp_imp);
endfunction: connect_phase

`undef THIS_CLASS
`endif
