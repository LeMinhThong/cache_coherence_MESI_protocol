`ifndef FSM_SNP_REQ_CTRL_SV
`define FSM_SNP_REQ_CTRL_SV

`include "cache_def.sv"

module fsm_snp_req_ctrl (
      input   logic [2:0] curSt,
      input   logic [2:0] snp_op,

      output  logic [2:0] nxtSt,
      //output  logic       snp_wb,
      output  logic [1:0] snp_rsp
);

  //-----------------------------------------------------------------
  //assign snp_wb   = ((curSt == `MODIFIED) && ((snp_op == `SNP_RD) || (snp_op == `SNP_RWITM))) ? 1'b1 : 1'b0;
  assign snp_rsp  = ((curSt[0] == 1'b1) && ((snp_op == `SNP_RD) || (snp_op == `SNP_RWITM))) ? `SNP_FOUND : `SNP_NO_RSP;

  //-----------------------------------------------------------------
  always_comb begin
    nxtSt = `INVALID;
    case(snp_op)
      `SNP_NO_REQ:  nxtSt = curSt;
      `SNP_RD:      nxtSt = `SHARED;
      `SNP_INV:     nxtSt = `INVALID;
      `SNP_RWITM:   nxtSt = `INVALID;
      default: ;
    endcase // curSt
  end
endmodule

`endif
