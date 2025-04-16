`ifndef FSM_l1_REQ_CTRL_SV
`define FSM_l1_REQ_CTRL_SV

`include "cache_def.sv"

module fsm_l1_req_ctrl (
      input   logic [2:0]   curSt,
      input   logic         wr_hit,
      input   logic         rd_hit,
      input   logic         wr_miss,
      input   logic         rd_miss,
      input   logic [1:0]   snp_rsp,

      output  logic [2:0]   nxtSt,
      output  logic         l1_wait,
      //output  logic         snp_wb,
      output  logic [2:0]   snp_req
);

  localparam READ_HIT   = 0;
  localparam WRITE_HIT  = 1;
  localparam READ_MISS  = 2;
  localparam WRITE_MISS = 3;

  logic [3:0] rd_wr_hit_miss = {wr_miss, rd_miss, wr_hit, rd_hit};

  //-----------------------------------------------------------------
  //assign snp_wb   = ((curSt == `MODIFIED) && (wr_miss || rd_miss)) ? 1'b1 : 1'b0;
  assign l1_wait  = ((wr_hit || rd_hit) && (snp_rsp == `SNP_NO_RSP)) ? 1'b1 : 1'b0;

  //-----------------------------------------------------------------
  always_comb begin
    snp_req = `SNP_NO_REQ;
    nxtSt   = `INVALID;
    case(1'b1)
      rd_wr_hit_miss[READ_HIT]:
            begin
              case(curSt)
                `EXCLUSIVE:
                      begin
                        snp_req = `SNP_NO_REQ;
                        nxtSt   = `EXCLUSIVE;
                      end
                `MODIFIED:
                      begin
                        snp_req = `SNP_NO_REQ;
                        nxtSt   = `MODIFIED;
                      end
                `SHARED:
                      begin
                        snp_req = `SNP_NO_REQ;
                        nxtSt   = `SHARED;
                      end
                default: ;
              endcase // curSt
            end
      rd_wr_hit_miss[WRITE_HIT]:
            begin
              case(curSt)
                `EXCLUSIVE:
                      begin
                        snp_req = `SNP_NO_REQ;
                        nxtSt   = `MODIFIED;
                      end
                `MODIFIED:
                      begin
                        snp_req = `SNP_NO_REQ;
                        nxtSt   = `MODIFIED;
                      end
                `SHARED:
                      begin
                        snp_req = `SNP_INV;
                        nxtSt   = `MODIFIED;
                      end
                default: ;
              endcase // curSt
            end
      rd_wr_hit_miss[READ_MISS]:
            begin
              case(snp_rsp)
                `SNP_NO_RSP:
                      begin
                        snp_req = `SNP_RD;
                        nxtSt   = `INVALID;
                      end
                `SNP_FOUND:
                      begin
                        snp_req = `SNP_NO_REQ;
                        nxtSt   = `SHARED;
                      end
                `SNP_FETCH:
                      begin
                        snp_req = `SNP_NO_REQ;
                        nxtSt   = `EXCLUSIVE;
                      end
                default: ;
              endcase // snp_rsp
            end
      rd_wr_hit_miss[WRITE_MISS]:
            begin
              case(snp_rsp)
                `SNP_NO_RSP:
                      begin
                        snp_req = `SNP_RWITM;
                        nxtSt   = `INVALID;
                      end
                `SNP_FOUND, `SNP_FETCH:
                      begin
                        snp_req = `SNP_NO_REQ;
                        nxtSt   = `MODIFIED;
                      end
                default: ;
              endcase // snp_rsp
            end
    endcase // rd_wr_hit_miss
  end
endmodule // fsm_l1_req_ctrl

`endif
