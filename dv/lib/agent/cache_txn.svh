`ifndef CACHE_TXN_SVH
`define CACHE_TXN_SVH
`define THIS_CLASS cache_txn_c

class `THIS_CLASS extends uvm_sequence_item;
        int       TxnId;

  rand  l1_op_e   rx_l1_op;
  rand  address_t rx_l1_addr;
  rand  data_t    rx_l1_data;

  rand  bit       tx_l1_wait;
  rand  data_t    tx_l1_data;

  rand  snp_op_e  rx_snp_op;
  rand  address_t rx_snp_addr;
  rand  data_t    rx_snp_data;
  rand  snp_rsp_e rx_snp_rsp;

  rand  snp_op_e  tx_snp_op;
  rand  address_t tx_snp_addr;
  rand  data_t    tx_snp_data;
  rand  snp_rsp_e tx_snp_rsp;

  // ----------------------------------------------------------------
  `uvm_object_utils_begin(`THIS_CLASS)
    `uvm_field_int(TxnId, UVM_DEFAULT)
    `uvm_field_enum(l1_op_e, rx_l1_op ,UVM_DEFAULT)
    `uvm_field_int(rx_l1_addr, UVM_DEFAULT)
    `uvm_field_int(rx_l1_data, UVM_DEFAULT)
    `uvm_field_int(tx_l1_wait, UVM_DEFAULT)
    `uvm_field_enum(snp_op_e, rx_snp_op, UVM_DEFAULT)
    `uvm_field_int(rx_snp_addr, UVM_DEFAULT)
    `uvm_field_int(rx_snp_data, UVM_DEFAULT)
    `uvm_field_enum(snp_rsp_e, rx_snp_rsp, UVM_DEFAULT)
    `uvm_field_enum(snp_op_e, tx_snp_op, UVM_DEFAULT)
    `uvm_field_int(tx_snp_addr, UVM_DEFAULT)
    `uvm_field_int(tx_snp_data, UVM_DEFAULT)
    `uvm_field_enum(snp_rsp_e, tx_snp_rsp, UVM_DEFAULT)
  `uvm_object_utils_end

  // ----------------------------------------------------------------
  extern  virtual function string convert2string();

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

  str = $sformatf("TxnId=%0d  ", TxnId);
  str = {str, $sformatf("rx_l1_op=%s  ",        rx_l1_op.name())};
  str = {str, $sformatf("rx_l1_addr=0x%0h  ",   rx_l1_addr)};
  str = {str, $sformatf("rx_l1_data=0x%0h  ",   rx_l1_data)};
  str = {str, $sformatf("tx_l1_wait=%h  ",      tx_l1_wait)};
  str = {str, $sformatf("tx_l1_data=0x%0h  ",   tx_l1_data)};
  str = {str, $sformatf("rx_snp_op=%s  ",       rx_snp_op.name())};
  str = {str, $sformatf("rx_snp_addr=0x%0h  ",  rx_snp_addr)};
  str = {str, $sformatf("rx_snp_data=0x%0h  ",  rx_snp_data)};
  str = {str, $sformatf("rx_snp_rsp=%s  ",      rx_snp_rsp.name())};
  str = {str, $sformatf("tx_snp_op=%s  ",       tx_snp_op.name())};
  str = {str, $sformatf("tx_snp_addr=0x%0h  ",  tx_snp_addr)};
  str = {str, $sformatf("tx_snp_data=0x%0h  ",  tx_snp_data)};
  str = {str, $sformatf("tx_snp_rsp=%s  ",      tx_snp_rsp.name())};
  str = {str, "\n"};

  return str;
endfunction: convert2string
//function string `THIS_CLASS::convert2string();
//  string str;
//  string tmp_str = "";
//  str = $sformatf("TxnId=%0d  ", TxnId);
//  str = {str, $sformatf("L1Op=%s  ", L1Op.name())};
//  str = {str, $sformatf("Rx_SnpOp=%s  ", Rx_SnpOp.name())};
//  str = {str, $sformatf("Rx_SnpRsp=%s  ", Rx_SnpRsp.name())};
//  str = {str, $sformatf("Tx_SnpOp=%s  ", Tx_SnpOp.name())};
//  str = {str, $sformatf("Tx_SnpRsp=%s  ", Tx_SnpRsp.name())};
//  return str;
//endfunction: convert2string

`undef THIS_CLASS
`endif
