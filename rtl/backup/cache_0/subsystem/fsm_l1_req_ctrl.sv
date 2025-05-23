`ifndef FSM_l1_REQ_CTRL_SV
`define FSM_l1_REQ_CTRL_SV

`include "cache_def.sv"
import cache_pkg::*;

module fsm_l1_req_ctrl (
      input   logic [2:0] blk_curSt,
      input   logic [3:0] cache_lookup,
      input   logic [2:0] cdreq_op,
      input   logic [2:0] req_curSt,
      input   logic [2:0] sursp_rsp,

      output  logic [2:0] blk_nxtSt,
      output  logic [2:0] init_sdreq,
      output  logic [1:0] cursp_rsp
);

  //-----------------------------------------------------------------
  assign cursp_rsp = CURSP_OKAY;

  //-----------------------------------------------------------------
  // cache state fsm
  //-----------------------------------------------------------------
  always_comb begin
    blk_nxtSt = INVALID;
    case(1'b1)
      cache_lookup[READ_HIT]:   blk_nxtSt = blk_curSt;
      cache_lookup[WRITE_HIT]:  blk_nxtSt = (cdreq_op == CDREQ_WB) ? MODIFIED : MIGRATED;
      cache_lookup[READ_MISS]:
            begin
              if(req_curSt == CDREQ_SEND_RSP) begin
                case(sursp_rsp)
                  SURSP_SNOOP: blk_nxtSt = SHARED;
                  SURSP_FETCH: blk_nxtSt = EXCLUSIVE;
                  default: ;
                endcase // sursp_rsp
              end
              else begin
                blk_nxtSt = INVALID;
              end
            end
      cache_lookup[WRITE_MISS]: blk_nxtSt = (req_curSt == CDREQ_SEND_RSP) ? MIGRATED : INVALID;
      // WRITE_MISS only occurred when RFO to INVALID, if CDREQ is MD or WB, then state has to VALID
      default: ;
    endcase // cache_lookup
  end

  //-----------------------------------------------------------------
  // initiate downstream snoop request
  //-----------------------------------------------------------------
  always_comb begin
    init_sdreq = SDREQ_RD;
    case(1'b1)
      cache_lookup[READ_HIT]:   init_sdreq = SDREQ_RD;
      cache_lookup[WRITE_HIT]:  init_sdreq = (blk_curSt == SHARED) ? SDREQ_INV : SDREQ_RD;
      cache_lookup[READ_MISS]:  init_sdreq = SDREQ_RD;
      cache_lookup[WRITE_MISS]: init_sdreq = SDREQ_RFO;
      default: ;
    endcase // cache_lookup
  end
endmodule // fsm_l1_req_ctrl

`endif
