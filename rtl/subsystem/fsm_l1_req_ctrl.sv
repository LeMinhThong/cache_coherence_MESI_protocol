`ifndef FSM_l1_REQ_CTRL_SV
`define FSM_l1_REQ_CTRL_SV

`include "cache_def.sv"

module fsm_l1_req_ctrl (
      input   logic [2:0]   curSt   ,
      input   logic         wr_hit  ,
      input   logic         rd_hit  ,
      input   logic         wr_miss ,
      input   logic         rd_miss ,
      input   logic [2:0]   snp_rsp ,

      output  logic [2:0]   nxtSt   ,
      output  logic         cdt_rsp ,
      output  logic [2:0]   snp_req 
);

  localparam READ_HIT   = 0;
  localparam WRITE_HIT  = 1;
  localparam READ_MISS  = 2;
  localparam WRITE_MISS = 3;

  logic [3:0] rd_wr_hit_miss;

  //-----------------------------------------------------------------
  //assign snp_wb   = ((curSt == `MODIFIED) && (wr_miss || rd_miss)) ? 1'b1 : 1'b0;
  assign rd_wr_hit_miss = {wr_miss, rd_miss, wr_hit, rd_hit};
  //assign cdt_rsp = ((wr_miss || rd_miss) && (snp_rsp == `SDT_RD)) ? 1'b1 : 1'b0;
  assign cdt_rsp = wr_miss || rd_miss;

  //-----------------------------------------------------------------
  always_comb begin
    snp_req = `SDT_RD;
    nxtSt   = `INVALID;
    case(1'b1)
      rd_wr_hit_miss[READ_HIT]:
            begin
              case(curSt)
                `EXCLUSIVE:
                      begin
                        snp_req = `SDT_RD;
                        nxtSt   = `EXCLUSIVE;
                      end
                `MODIFIED:
                      begin
                        snp_req = `SDT_RD;
                        nxtSt   = `MODIFIED;
                      end
                `SHARED:
                      begin
                        snp_req = `SDT_RD;
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
                        snp_req = `SDT_RD;
                        nxtSt   = `MODIFIED;
                      end
                `MODIFIED:
                      begin
                        snp_req = `SDT_RD;
                        nxtSt   = `MODIFIED;
                      end
                `SHARED:
                      begin
                        snp_req = `SDT_INV;
                        nxtSt   = `MODIFIED;
                      end
                default: ;
              endcase // curSt
            end
      rd_wr_hit_miss[READ_MISS]:
            begin
              case(snp_rsp)
                `SDR_OKAY:
                      begin
                        snp_req = `SDT_RD;
                        nxtSt   = `INVALID;
                      end
                `SDR_SNOOP:
                      begin
                        snp_req = `SDT_RD;
                        nxtSt   = `SHARED;
                      end
                `SDR_FETCH:
                      begin
                        snp_req = `SDT_RD;
                        nxtSt   = `EXCLUSIVE;
                      end
                default: ;
              endcase // snp_rsp
            end
      rd_wr_hit_miss[WRITE_MISS]:
            begin
              case(snp_rsp)
                `SDR_OKAY:
                      begin
                        snp_req = `SDT_RFO;
                        nxtSt   = `INVALID;
                      end
                `SDR_SNOOP, `SDR_FETCH:
                      begin
                        snp_req = `SDT_RD;
                        nxtSt   = `MODIFIED;
                      end
                default: ;
              endcase // snp_rsp
            end
    endcase // rd_wr_hit_miss
  end
endmodule // fsm_l1_req_ctrl

`endif
