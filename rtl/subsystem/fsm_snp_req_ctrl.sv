`ifndef FSM_SNP_REQ_CTRL_SV
`define FSM_SNP_REQ_CTRL_SV

`include "cache_def.sv"
import cache_pkg::*;

module fsm_snp_req_ctrl (
      input   logic [2:0] blk_curSt,
      input   logic [1:0] snp_op,

      output  logic [2:0] blk_nxtSt,
      output  logic [1:0] snp_rsp
);

  //-----------------------------------------------------------------
  assign snp_rsp  = (blk_curSt == INVALID) ? SDRSP_INV : SDRSP_OKAY;

  //-----------------------------------------------------------------
  always_comb begin
    blk_nxtSt = INVALID;
    case(snp_op)
      SUREQ_RD:   blk_nxtSt = SHARED;
      SUREQ_RFO:  blk_nxtSt = INVALID;
      SUREQ_INV:  blk_nxtSt = INVALID;
      default: ;
    endcase // blk_curSt
  end
endmodule

`endif
