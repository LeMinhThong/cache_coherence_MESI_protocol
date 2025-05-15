`ifndef FSM_SNP_REQ_CTRL_SV
`define FSM_SNP_REQ_CTRL_SV

`include "cache_def.sv"

module fsm_snp_req_ctrl (
      input   logic [2:0] curSt,
      input   logic [1:0] snp_op,

      output  logic [2:0] nxtSt,
      output  logic [1:0] snp_rsp
);

  //-----------------------------------------------------------------
  //assign snp_wb   = ((curSt == `MODIFIED) && ((snp_op == `SNP_RD) || (snp_op == `SNP_RWITM))) ? 1'b1 : 1'b0;
  assign snp_rsp  = ((curSt[0] == 1'b1) && ((snp_op == `SUREQ_RD) || (snp_op == `SUREQ_RFO))) ? `SDRSP_OKAY : `SDRSP_INV;

  //-----------------------------------------------------------------
  always_comb begin
    nxtSt = curSt;
    case(snp_op)
      `SUREQ_RD:  nxtSt = `SHARED;
      `SUREQ_INV: nxtSt = `INVALID;
      `SUREQ_RFO: nxtSt = `INVALID;
      default: ;
    endcase // curSt
  end
endmodule

`endif
