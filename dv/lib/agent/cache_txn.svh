`ifndef CACHE_TXN_SVH
`define CACHE_TXN_SVH
`define THIS_CLASS cache_txn_c

class `THIS_CLASS extends uvm_sequence_item;
        int       TxnId;
  rand  type_e    Type;

  rand  cdr_e   cdr_op;
  rand  address_t cdr_addr;
  rand  data_t    cdr_data;

  rand  cdt_e  cdt_rsp;
  rand  data_t    cdt_data;

  rand  cut_e   cut_op;
  rand  address_t cut_addr;

  rand  cur_e  cur_rsp;
  rand  data_t    cur_data;

  rand  sdt_e   sdt_op;
  rand  address_t sdt_addr;
  rand  data_t    sdt_data;

  rand  sdr_e  sdr_rsp;
  rand  data_t    sdr_data;

  rand  sur_e   sur_op;
  rand  address_t sur_addr;

  rand  sut_e  sut_rsp;
  rand  data_t    sut_data;

  // ----------------------------------------------------------------
  `uvm_object_utils_begin(`THIS_CLASS)
    `uvm_field_int  (           TxnId     ,UVM_DEFAULT)
    `uvm_field_enum (type_e,    Type      ,UVM_DEFAULT)

    `uvm_field_enum (cdr_e,   cdr_op    ,UVM_DEFAULT)
    `uvm_field_int  (           cdr_addr  ,UVM_DEFAULT)
    `uvm_field_int  (           cdr_data  ,UVM_DEFAULT)

    `uvm_field_enum (cdt_e,  cdt_rsp   ,UVM_DEFAULT)
    `uvm_field_int  (           cdt_data  ,UVM_DEFAULT)

    `uvm_field_enum (cut_e,   cut_op    ,UVM_DEFAULT)
    `uvm_field_int  (           cut_addr  ,UVM_DEFAULT)

    `uvm_field_enum (cur_e,  cur_rsp   ,UVM_DEFAULT)
    `uvm_field_int  (           cur_data  ,UVM_DEFAULT)

    `uvm_field_enum (sdt_e,   sdt_op    ,UVM_DEFAULT)
    `uvm_field_int  (           sdt_addr  ,UVM_DEFAULT)
    `uvm_field_int  (           sdt_data  ,UVM_DEFAULT)

    `uvm_field_enum (sdr_e,  sdr_rsp   ,UVM_DEFAULT)
    `uvm_field_int  (           sdr_data  ,UVM_DEFAULT)

    `uvm_field_enum (sur_e,   sur_op    ,UVM_DEFAULT)
    `uvm_field_int  (           sur_addr  ,UVM_DEFAULT)

    `uvm_field_enum (sut_e,  sut_rsp   ,UVM_DEFAULT)
    `uvm_field_int  (           sut_data  ,UVM_DEFAULT)
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

  str = {str, $sformatf("TxnId=%0d  ",      TxnId         )};
  str = {str, $sformatf("Type=%s  ",        Type.name()   )};

  str = {str, $sformatf("cdr_op=%s  ",      cdr_op.name() )};
  str = {str, $sformatf("cdr_addr=0x%0h  ", cdr_addr      )};
  str = {str, $sformatf("cdr_data=0x%0h  ", cdr_data      )};

  str = {str, $sformatf("cdt_rsp=%s  ",     cdt_rsp.name())};
  str = {str, $sformatf("cdt_data=0x%0h  ", cdt_data      )};

  str = {str, $sformatf("cut_op=%s  ",      cut_op.name() )};
  str = {str, $sformatf("cut_addr=0x%0h  ", cut_addr      )};

  str = {str, $sformatf("cur_rsp=%s  ",     cur_rsp.name())};
  str = {str, $sformatf("cur_data=0x%0h  ", cur_data      )};

  str = {str, $sformatf("sdt_op=%s  ",      sdt_op.name() )};
  str = {str, $sformatf("sdt_addr=0x%0h  ", sdt_addr      )};
  str = {str, $sformatf("sdt_data=0x%0h  ", sdt_data      )};

  str = {str, $sformatf("sdr_rsp=%s  ",     sdr_rsp.name())};
  str = {str, $sformatf("sdr_data=0x%0h  ", sdr_data      )};

  str = {str, $sformatf("sur_op=%s  ",      sur_op.name() )};
  str = {str, $sformatf("sur_addr=0x%0h  ", sur_addr      )};

  str = {str, $sformatf("sut_rsp=%s  ",     sut_rsp.name())};
  str = {str, $sformatf("sut_data=0x%0h  ", sut_data      )};

  return str;
endfunction: convert2string

// ----------------------------------------------------------------
//function void `THIS_CLASS::cloneFields(cache_txn_c t);
//  this.TxnId        = t.TxnId;
//  this.Type         = t.Type;
//  this.cdr_op     = t.cdr_op;
//  this.cdr_addr   = t.cdr_addr;
//  this.cdr_data   = t.cdr_data;
//  this.tx_l1_wait   = t.tx_l1_wait;
//  this.cdt_data   = t.cdt_data;
//  this.sur_op    = t.sur_op;
//  this.sur_addr  = t.sur_addr;
//  this.sdr_data  = t.sdr_data;
//  this.sdr_rsp   = t.sdr_rsp;
//  this.sdt_op    = t.sdt_op;
//  this.sdt_addr  = t.sdt_addr;
//  this.sut_data  = t.sut_data;
//  this.sut_rsp   = t.sut_rsp;
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
  this.cdr_op = CDR_WB;
endfunction: set_as_wr_req

// ----------------------------------------------------------------
function void `THIS_CLASS::set_as_rd_req();
  this.cdr_op = CDR_RD;
endfunction: set_as_rd_req

// ----------------------------------------------------------------
function bit `THIS_CLASS::is_wr_req();
  if(this.cdr_op == CDR_WB) return 1;
  else                      return 0;
endfunction: is_wr_req

`undef THIS_CLASS
`endif
