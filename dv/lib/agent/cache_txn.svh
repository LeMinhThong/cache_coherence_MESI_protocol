`ifndef CACHE_TXN_SVH
`define CACHE_TXN_SVH
`define THIS_CLASS cache_txn_c

class `THIS_CLASS extends uvm_sequence_item;
        int       TxnId;
        xfr_e     Type_xfr = ALL_CH;
  rand  type_e    Type;

  rand  cdreq_e   cdreq_op;
  rand  address_t cdreq_addr;
  rand  data_t    cdreq_data;

  rand  cursp_e   cursp_rsp;
  rand  data_t    cursp_data;

  rand  cureq_e   cureq_op;
  rand  address_t cureq_addr;

  rand  cdrsp_e   cdrsp_rsp;
  rand  data_t    cdrsp_data;

  rand  sdreq_e   sdreq_op;
  rand  address_t sdreq_addr;
  rand  data_t    sdreq_data;

  rand  sursp_e   sursp_rsp;
  rand  data_t    sursp_data;

  rand  sureq_e   sureq_op;
  rand  address_t sureq_addr;

  rand  sdrsp_e   sdrsp_rsp;
  rand  data_t    sdrsp_data;

  // ----------------------------------------------------------------
  `uvm_object_utils_begin(`THIS_CLASS)
    `uvm_field_int  (         TxnId       ,UVM_DEFAULT)
    `uvm_field_enum (xfr_e,   Type_xfr    ,UVM_DEFAULT)
    `uvm_field_enum (type_e,  Type        ,UVM_DEFAULT)

    `uvm_field_enum (cdreq_e, cdreq_op    ,UVM_DEFAULT)
    `uvm_field_int  (         cdreq_addr  ,UVM_DEFAULT)
    `uvm_field_int  (         cdreq_data  ,UVM_DEFAULT)

    `uvm_field_enum (cursp_e, cursp_rsp   ,UVM_DEFAULT)
    `uvm_field_int  (         cursp_data  ,UVM_DEFAULT)

    `uvm_field_enum (cureq_e, cureq_op    ,UVM_DEFAULT)
    `uvm_field_int  (         cureq_addr  ,UVM_DEFAULT)

    `uvm_field_enum (cdrsp_e, cdrsp_rsp   ,UVM_DEFAULT)
    `uvm_field_int  (         cdrsp_data  ,UVM_DEFAULT)

    `uvm_field_enum (sdreq_e, sdreq_op    ,UVM_DEFAULT)
    `uvm_field_int  (         sdreq_addr  ,UVM_DEFAULT)
    `uvm_field_int  (         sdreq_data  ,UVM_DEFAULT)

    `uvm_field_enum (sursp_e, sursp_rsp   ,UVM_DEFAULT)
    `uvm_field_int  (         sursp_data  ,UVM_DEFAULT)

    `uvm_field_enum (sureq_e, sureq_op    ,UVM_DEFAULT)
    `uvm_field_int  (         sureq_addr  ,UVM_DEFAULT)

    `uvm_field_enum (sdrsp_e, sdrsp_rsp   ,UVM_DEFAULT)
    `uvm_field_int  (         sdrsp_data  ,UVM_DEFAULT)
  `uvm_object_utils_end

  // ----------------------------------------------------------------
  extern  virtual function  string  convert2string();
  extern  virtual function  bit     comp(input cache_txn_c item);
  //extern  virtual function  void    cloneFields(cache_txn_c t);
  extern  virtual function  void    set_as_wr_req();
  extern  virtual function  void    set_as_rd_req();
  extern  virtual function  bit     is_wr_req();

  // ----------------------------------------------------------------
  function new(string name="`THIS_CLASS");
    super.new(name);
    TxnId = -1;
  endfunction: new
endclass: `THIS_CLASS

// ----------------------------------------------------------------
function string `THIS_CLASS::convert2string();
  string str;
  string tmp_str;

  str = {str, $sformatf("TxnId=%0d  ",        TxnId             )};
  str = {str, $sformatf("Type_xfr=%s  ",      Type_xfr.name()   )};
  str = {str, $sformatf("Type=%s  ",          Type.name()       )};
  if((Type_xfr == CDREQ_XFR) || (Type_xfr == ALL_CH)) begin
    str = {str, $sformatf("cdreq_op=%s  ",      cdreq_op.name()   )};
    str = {str, $sformatf("cdreq_addr=0x%0h  ", cdreq_addr        )};
    str = {str, $sformatf("cdreq_data=0x%0h  ", cdreq_data        )};
  end
  if((Type_xfr == CURSP_XFR) || (Type_xfr == ALL_CH)) begin
    str = {str, $sformatf("cursp_rsp=%s  ",     cursp_rsp.name()  )};
    str = {str, $sformatf("cursp_data=0x%0h  ", cursp_data        )};
  end
  if((Type_xfr == CUREQ_XFR) || (Type_xfr == ALL_CH)) begin
    str = {str, $sformatf("cureq_op=%s  ",      cureq_op.name()   )};
    str = {str, $sformatf("cureq_addr=0x%0h  ", cureq_addr        )};
  end
  if((Type_xfr == CDRSP_XFR) || (Type_xfr == ALL_CH)) begin
    str = {str, $sformatf("cdrsp_rsp=%s  ",     cdrsp_rsp.name()  )};
    str = {str, $sformatf("cdrsp_data=0x%0h  ", cdrsp_data        )};
  end
  if((Type_xfr == SDREQ_XFR) || (Type_xfr == ALL_CH)) begin
    str = {str, $sformatf("sdreq_op=%s  ",      sdreq_op.name()   )};
    str = {str, $sformatf("sdreq_addr=0x%0h  ", sdreq_addr        )};
    str = {str, $sformatf("sdreq_data=0x%0h  ", sdreq_data        )};
  end
  if((Type_xfr == SURSP_XFR) || (Type_xfr == ALL_CH)) begin
    str = {str, $sformatf("sursp_rsp=%s  ",     sursp_rsp.name()  )};
    str = {str, $sformatf("sursp_data=0x%0h  ", sursp_data        )};
  end
  if((Type_xfr == SUREQ_XFR) || (Type_xfr == ALL_CH)) begin
    str = {str, $sformatf("sureq_op=%s  ",      sureq_op.name()   )};
    str = {str, $sformatf("sureq_addr=0x%0h  ", sureq_addr        )};
  end
  if((Type_xfr == SDRSP_XFR) || (Type_xfr == ALL_CH)) begin
    str = {str, $sformatf("sdrsp_rsp=%s  ",     sdrsp_rsp.name()  )};
    str = {str, $sformatf("sdrsp_data=0x%0h  ", sdrsp_data        )};
  end

  return str;
endfunction: convert2string

// ----------------------------------------------------------------
//function void `THIS_CLASS::cloneFields(cache_txn_c t);
//  this.TxnId        = t.TxnId;
//  this.Type         = t.Type;
//  this.cdreq_op     = t.cdreq_op;
//  this.cdreq_addr   = t.cdreq_addr;
//  this.cdreq_data   = t.cdreq_data;
//  this.tx_l1_wait   = t.tx_l1_wait;
//  this.cursp_data   = t.cursp_data;
//  this.sureq_op    = t.sureq_op;
//  this.sureq_addr  = t.sureq_addr;
//  this.sursp_data  = t.sursp_data;
//  this.sursp_rsp   = t.sursp_rsp;
//  this.sdreq_op    = t.sdreq_op;
//  this.sdreq_addr  = t.sdreq_addr;
//  this.sdrsp_data  = t.sdrsp_data;
//  this.sdrsp_rsp   = t.sdrsp_rsp;
//endfunction: cloneFields

// ----------------------------------------------------------------
function bit `THIS_CLASS::comp(input cache_txn_c item);
  cache_txn_c castItem;
  if(item == null)            return 0;
  if(!$cast(castItem, item))  return 0;
  return 1;
endfunction: comp

// ----------------------------------------------------------------
function void `THIS_CLASS::set_as_wr_req();
  this.cdreq_op = CDREQ_WB;
endfunction: set_as_wr_req

// ----------------------------------------------------------------
function void `THIS_CLASS::set_as_rd_req();
  this.cdreq_op = CDREQ_RD;
endfunction: set_as_rd_req

// ----------------------------------------------------------------
function bit `THIS_CLASS::is_wr_req();
  if(this.cdreq_op == CDREQ_WB) return 1;
  else                          return 0;
endfunction: is_wr_req

`undef THIS_CLASS
`endif
