`ifndef STATE_CONTROLLER_SV
`define STATE_CONTROLLER_SV

`include "cache_def.sv"
import cache_pkg::*;

module state_controller #(
      parameter NUM_BLK,
      parameter BLK_WIDTH,
      parameter SADDR_WIDTH,

      parameter IDX_WIDTH,
      parameter TAG_WIDTH,
      parameter RAM_WIDTH
) (
      input   logic                 clk,
      input   logic                 rst_n,

      input   logic                 cdreq_hs_en,
      input   logic                 cac_hit,
      input   logic                 cdreq_init_sdreq_inv,
      input   logic                 sdreq_hs_compack,
      input   logic                 sursp_hs_en,
      input   logic                 cursp_hs_compack,

      input   logic                 sureq_hs_en,
      input   logic                 snp_hit,
      input   logic [ST_WIDTH-1:0]  sureqAddr_2mem_blk_curSt,
      input   logic                 sureq_init_cureq_inv,
      input   logic                 cureq_hs_compack,
      input   logic                 cdrsp_hs_en,
      input   logic                 sdrsp_hs_compack,

      output  logic [2:0]           cdreq_req_curSt,
      output  logic [2:0]           sureq_req_curSt
);

  // ----------------------------------------------------------------
  // CDERQ state controller FSM
  // ----------------------------------------------------------------
  logic [2:0] cdreq_req_nxtSt;

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
      cdreq_req_curSt <= CDREQ_IDLE;
    else
      cdreq_req_curSt <= cdreq_req_nxtSt;
  end

  always_comb begin
    case(cdreq_req_curSt)
      CDREQ_IDLE:       cdreq_req_nxtSt = (cdreq_hs_en                      ) ? CDREQ_ALLOCATE    : CDREQ_IDLE;
      CDREQ_ALLOCATE:   cdreq_req_nxtSt = (cac_hit && !cdreq_init_sdreq_inv ) ? CDREQ_SEND_RSP    : CDREQ_INIT_SDREQ;
      CDREQ_INIT_SDREQ: cdreq_req_nxtSt = (sdreq_hs_compack                 ) ? CDREQ_WAIT_SURSP  : CDREQ_INIT_SDREQ;
      CDREQ_WAIT_SURSP: cdreq_req_nxtSt = (sursp_hs_en                      ) ? CDREQ_SEND_RSP    : CDREQ_WAIT_SURSP;
      CDREQ_SEND_RSP:   cdreq_req_nxtSt = (cursp_hs_compack                 ) ? CDREQ_IDLE        : CDREQ_SEND_RSP;
      default:          cdreq_req_nxtSt = CDREQ_IDLE;
    endcase // cdreq_req_curSt
  end

  // ----------------------------------------------------------------
  // SUREQ state controller FSM
  // ----------------------------------------------------------------
  logic [2:0] sureq_req_nxtSt;

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
      sureq_req_curSt <= SUREQ_IDLE;
    else
      sureq_req_curSt <= sureq_req_nxtSt;
  end

  always_comb begin
    case(sureq_req_curSt)
      SUREQ_IDLE:       sureq_req_nxtSt = (sureq_hs_en      ) ? SUREQ_ALLOCATE    : SUREQ_IDLE;
      SUREQ_ALLOCATE:
            begin
              if      ((snp_hit && (sureqAddr_2mem_blk_curSt == MIGRATED)) || sureq_init_cureq_inv)  sureq_req_nxtSt = SUREQ_INIT_CUREQ;
              else if (snp_hit && (sureqAddr_2mem_blk_curSt == MODIFIED))                            sureq_req_nxtSt = SUREQ_INIT_SDREQ;
              else                                                                          sureq_req_nxtSt = SUREQ_SEND_RSP;
            end
      SUREQ_INIT_CUREQ: sureq_req_nxtSt = (cureq_hs_compack ) ? SUREQ_WAIT_CDRSP  : SUREQ_INIT_CUREQ;
      SUREQ_WAIT_CDRSP: sureq_req_nxtSt = (cdrsp_hs_en      ) ? ((sureq_init_cureq_inv && (sureqAddr_2mem_blk_curSt != MODIFIED)) ? SUREQ_SEND_RSP : SUREQ_INIT_SDREQ) : SUREQ_WAIT_CDRSP;
      SUREQ_INIT_SDREQ: sureq_req_nxtSt = (sdreq_hs_compack ) ? SUREQ_WAIT_SURSP  : SUREQ_INIT_SDREQ;
      SUREQ_WAIT_SURSP: sureq_req_nxtSt = (sursp_hs_en      ) ? SUREQ_SEND_RSP    : SUREQ_WAIT_SURSP;
      SUREQ_SEND_RSP:   sureq_req_nxtSt = (sdrsp_hs_compack ) ? SUREQ_IDLE        : SUREQ_SEND_RSP;
      default:          sureq_req_nxtSt = SUREQ_IDLE;
    endcase // sureq_req_curSt
  end
endmodule

`endif
