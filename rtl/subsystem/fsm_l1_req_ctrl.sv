`ifndef FSM_l1_REQ_CTRL_SV
`define FSM_l1_REQ_CTRL_SV

`include "cache_def.sv"
import cache_pkg::*;

module fsm_l1_req_ctrl (
      input   logic [2:0] blk_curSt,
      input   logic [3:0] req_status,
      input   logic [2:0] req_curSt,
      input   logic [2:0] sursp_rsp,

      output  logic [2:0] blk_nxtSt,
      output  logic       cursp_rsp,
      output  logic [2:0] init_sdreq 
);

  //-----------------------------------------------------------------
  //assign snp_wb   = ((blk_curSt == MODIFIED) && (wr_miss || rd_miss)) ? 1'b1 : 1'b0;
  //assign cursp_rsp = wr_miss || rd_miss;
  assign cursp_rsp = CURSP_OKAY;

  //-----------------------------------------------------------------
  // cache state fsm
  //-----------------------------------------------------------------
  always_comb begin
    blk_nxtSt = INVALID;
    case(1'b1)
      req_status[READ_HIT]:   blk_nxtSt = blk_curSt;
      req_status[WRITE_HIT]:  blk_nxtSt = MODIFIED;
      req_status[READ_MISS]:
            begin
              if(req_curSt == REQ_RSP_CURSP)
                case(sursp_rsp)
                  SURSP_SNOOP: blk_nxtSt = SHARED;
                  SURSP_FETCH: blk_nxtSt = EXCLUSIVE;
                  default: ;
                endcase // sursp_rsp
              else
                blk_nxtSt = INVALID;
            end
      req_status[WRITE_MISS]: blk_nxtSt = (req_curSt == REQ_RSP_CURSP) ? MODIFIED : INVALID;
      default: ;
    endcase // req_status
  end

  //-----------------------------------------------------------------
  // initiate downstream snoop request
  //-----------------------------------------------------------------
  always_comb begin
    init_sdreq = SDREQ_RD;
    case(1'b1)
      req_status[READ_HIT]:   init_sdreq = SDREQ_RD;
      req_status[WRITE_HIT]:  init_sdreq = (blk_curSt == SHARED) ? SDREQ_INV : SDREQ_RD;
      req_status[READ_MISS]:  init_sdreq = SDREQ_RD;
      req_status[WRITE_MISS]: init_sdreq = SDREQ_RFO;
      default: ;
    endcase // req_status
  end
endmodule // fsm_l1_req_ctrl

`endif
