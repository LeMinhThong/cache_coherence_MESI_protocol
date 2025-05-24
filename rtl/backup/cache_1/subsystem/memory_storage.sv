`ifndef MEMORY_STORAGE_SV
`define MEMORY_STORAGE_SV

`include "cache_def.sv"
import cache_pkg::*;

module memory_storage # (
      parameter NUM_BLK,
      parameter BLK_WIDTH,
      parameter SADDR_WIDTH,

      parameter IDX_WIDTH,
      parameter TAG_WIDTH,
      parameter RAM_WIDTH
) (
      input   logic                   clk,
      input   logic                   rst_n,

      input   logic [2:0]             cdreq_req_curSt,
      input   logic [ST_WIDTH-1:0]    cdreqAddr_2mem_blk_nxtSt,
      input   logic                   cac_hit,
      input   logic                   sursp_hs_en,
      input   logic                   cdreq_init_sdreq_inv,
      input   logic [2:0]             cdreq_op,
      input   logic [SADDR_WIDTH-1:0] cdreq_addr,
      input   logic [BLK_WIDTH-1:0]   cdreq_data,
      input   logic [BLK_WIDTH-1:0]   sursp_data,

      input   logic [ST_WIDTH-1:0]    sureqAddr_2mem_blk_nxtSt,
      input   logic                   sdrsp_hs_compack,
      input   logic                   cdrsp_hs_en,
      input   logic [SADDR_WIDTH-1:0] sureq_addr,
      input   logic [BLK_WIDTH-1:0]   cdrsp_data,

      output  logic [ST_WIDTH-1:0]    cdreqAddr_2mem_blk_curSt,
      output  logic [BLK_WIDTH-1:0]   cdreqAddr_2mem_data,
      output  logic [TAG_WIDTH-1:0]   cdreqAddr_2mem_tag,

      output  logic [ST_WIDTH-1:0]    sureqAddr_2mem_blk_curSt,
      output  logic [BLK_WIDTH-1:0]   sureqAddr_2mem_data,
      output  logic [TAG_WIDTH-1:0]   sureqAddr_2mem_tag
);

  // ----------------------------------------------------------------
  logic [RAM_WIDTH-1:0] mem [0:NUM_BLK-1];

  // ----------------------------------------------------------------
  assign cdreqAddr_2mem_blk_curSt  = mem[cdreq_addr[`IDX]][`ST];
  assign cdreqAddr_2mem_data       = mem[cdreq_addr[`IDX]][`DAT]; 
  assign cdreqAddr_2mem_tag        = mem[cdreq_addr[`IDX]][`RAM_TAG];

  assign sureqAddr_2mem_blk_curSt  = mem[sureq_addr[`IDX]][`ST];
  assign sureqAddr_2mem_data       = mem[sureq_addr[`IDX]][`DAT]; 
  assign sureqAddr_2mem_tag        = mem[sureq_addr[`IDX]][`RAM_TAG];

  // ----------------------------------------------------------------
  // Update block state
  // ----------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      for(int i = 0; i < NUM_BLK; i++) begin
        mem[i][`ST] <= INVALID;
      end
    end
    else begin
      if(cdreq_req_curSt == CDREQ_SEND_RSP)
        mem[cdreq_addr[`IDX]][`ST] <= cdreqAddr_2mem_blk_nxtSt;
      else if(sdrsp_hs_compack)
        mem[sureq_addr[`IDX]][`ST] <= sureqAddr_2mem_blk_nxtSt;
    end
  end

  // ----------------------------------------------------------------
  // Update Tag
  // ----------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      for(int i = 0; i < NUM_BLK; i++) begin
        mem[i][`RAM_TAG] <= {TAG_WIDTH{1'b0}};
      end
    end
    else begin
      if((cdreq_req_curSt == CDREQ_SEND_RSP) && !cac_hit)
        mem[cdreq_addr[`IDX]][`RAM_TAG] <= cdreq_addr[`ADDR_TAG];
    end
  end

  // ----------------------------------------------------------------
  // Update data
  // ----------------------------------------------------------------
  always_ff @(posedge clk) begin
    if(!rst_n) begin
      for(int i = 0; i < NUM_BLK; i++) begin
        mem[i][`DAT] <= {BLK_WIDTH{1'b0}};
      end
    end
    else begin
      if(cdreq_op == CDREQ_WB)
        mem[cdreq_addr[`IDX]][`DAT] <= cdreq_data;
      else if(((cdreq_op == CDREQ_RFO) || (cdreq_op == CDREQ_RD)) && !cdreq_init_sdreq_inv && (cdreq_req_curSt == CDREQ_SEND_RSP) && sursp_hs_en)
        mem[cdreq_addr[`IDX]][`DAT] <= sursp_data;
      else if((sureqAddr_2mem_blk_curSt == MIGRATED) && (cdrsp_hs_en))
        mem[cdreq_addr[`IDX]][`DAT] <= cdrsp_data;
    end
  end
endmodule

`endif
