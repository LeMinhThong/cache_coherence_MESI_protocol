`ifndef FSM_SNP_REQ_CTRL_SV
`define FSM_SNP_REQ_CTRL_SV

`include "cache_def.sv"
import cache_pkg::*;

module fsm_snp_req_ctrl (
      input   logic [2:0] blk_curSt,
      input   logic [1:0] sureq_op,
      input   logic       blk_valid_in_l1,

      output  logic [2:0] blk_nxtSt,
      output  logic [1:0] init_cureq,
      output  logic [2:0] init_sdreq,
      output  logic [1:0] sdrsp_rsp
);

  //-----------------------------------------------------------------
  assign init_cureq = ((sureq_op == SUREQ_RFO ) && (blk_curSt == MIGRATED)) ? CUREQ_RFO :
                      ((sureq_op != SUREQ_RD  ) && blk_valid_in_l1)         ? CUREQ_INV : CUREQ_RD;

  //-----------------------------------------------------------------
  assign init_sdreq = ((blk_curSt == MODIFIED) || (blk_curSt == MIGRATED)) ? SDREQ_WB : SDREQ_RD;

  //-----------------------------------------------------------------
  assign sdrsp_rsp  = (blk_curSt == INVALID) ? SDRSP_INV : SDRSP_OKAY;

  //-----------------------------------------------------------------
  always_comb begin
    if(blk_curSt != INVALID) begin
      case(sureq_op)
        SUREQ_RD:   blk_nxtSt = SHARED;
        SUREQ_RFO:  blk_nxtSt = INVALID;
        SUREQ_INV:  blk_nxtSt = INVALID;
        default:    blk_nxtSt = blk_curSt;
      endcase // blk_curSt
    end
    else begin
      blk_nxtSt = blk_curSt;
    end
  end

endmodule

`endif
