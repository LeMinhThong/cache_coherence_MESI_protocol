`ifndef CACHE_MEM_SV
`define CACHE_MEM_SV

`include "cache_def.sv"

module cache_mem #(
      parameter PADDR_WIDTH = 64,
      parameter BLK_WIDTH   = 512,
      parameter NUM_BLK     = 1024,

      parameter SADDR_WIDTH = PADDR_WIDTH-$clog2(BLK_WIDTH/8)
) (
      // System signals
      input   logic clk,
      input   logic rst_n,

      // L1 side
      input   logic [1:0]             rx_l1_op,
      input   logic [SADDR_WIDTH-1:0] rx_l1_addr,
      input   logic [BLK_WIDTH-1:0]   rx_l1_data,

      output  logic                   tx_l1_wait,
      output  logic [BLK_WIDTH-1:0]   tx_l1_data,

      // SNP side
      input   logic [2:0]             rx_snp_op,
      input   logic [SADDR_WIDTH-1:0] rx_snp_addr,
      input   logic [BLK_WIDTH-1:0]   rx_snp_data,
      input   logic [1:0]             rx_snp_rsp,

      output  logic [2:0]             tx_snp_op,
      //output  logic                   tx_snp_wb,
      output  logic [SADDR_WIDTH-1:0] tx_snp_addr,
      output  logic [BLK_WIDTH-1:0]   tx_snp_data,
      output  logic [1:0]             tx_snp_rsp
);

  // ----------------------------------------------------------------
  // FIXME
  // ----------------------------------------------------------------
  // merge write back into *x_snp_req
  // move considering snp_hit when determine tx_snp_rsp into fsm_snp_req_ctrl

  // ----------------------------------------------------------------
  // Cache memory
  // ----------------------------------------------------------------
  // |          --  Cache RAM width --
  // |State   |Tag                |Data          |
  // |3bits   |TAG_WIDTH          |BLK_WIDTH    0|
  localparam ST_WIDTH   = 3;
  localparam IDX_WIDTH  = $clog2(NUM_BLK);
  localparam TAG_WIDTH  = SADDR_WIDTH - IDX_WIDTH;
  localparam RAM_WIDTH  = ST_WIDTH + TAG_WIDTH + BLK_WIDTH;

  logic [RAM_WIDTH-1:0] cac_mem [0:NUM_BLK-1];

  // ----------------------------------------------------------------
  // Definitioin
  // ----------------------------------------------------------------
  logic [ST_WIDTH-1:0] l1_req_blk_curSt  = cac_mem[rx_l1_addr[`IDX]][`ST];
  logic [ST_WIDTH-1:0] snp_req_blk_curSt = cac_mem[rx_snp_addr[`IDX]][`ST];
  logic [ST_WIDTH-1:0] l1_req_blk_nxtSt;
  logic [ST_WIDTH-1:0] snp_req_blk_nxtSt;

  //logic l1_req_wb;
  //logic snp_req_wb;

  // ----------------------------------------------------------------
  // Determine L1 request hit or miss
  // ----------------------------------------------------------------
  logic l1_wr   = (rx_l1_op == 2'b10) ? 1'b1 : 1'b0;
  logic l1_rd   = (rx_l1_op == 2'b01) ? 1'b1 : 1'b0;
  logic l1_req  = l1_wr || l1_rd;

  logic l1_hit  = ((cac_mem[rx_l1_addr[`IDX]][`VALID] == 1'b1) && (rx_l1_addr[`ADDR_TAG] == cac_mem[rx_l1_addr[`IDX]][`RAM_TAG])) ? 1'b1 : 1'b0;
  logic snp_hit = ((cac_mem[rx_snp_addr[`IDX]][`VALID] == 1'b1) && (rx_snp_addr[`ADDR_TAG] == cac_mem[rx_snp_addr[`IDX]][`RAM_TAG])) ? 1'b1 : 1'b0;

  logic wr_hit  = l1_wr && l1_hit;
  logic rd_hit  = l1_rd && l1_hit;
  logic wr_miss = l1_wr && !l1_hit;
  logic rd_miss = l1_rd && !l1_hit;

  // ----------------------------------------------------------------
  // internal signals
  // ----------------------------------------------------------------
  logic [1:0] _tx_snp_rsp;

  // ----------------------------------------------------------------
  // l1 side output
  // ----------------------------------------------------------------
  assign tx_l1_data = cac_mem[rx_l1_addr[`IDX]][`DAT];

  // ----------------------------------------------------------------
  // SNP side output
  // ----------------------------------------------------------------
  assign tx_snp_rsp   = (snp_hit == 1'b1) ? _tx_snp_rsp : `SNP_NO_RSP;
  //assign tx_snp_wb    = l1_req_wb || snp_req_wb;
  //assign tx_snp_addr  = ((snp_req_wb == 1'b1) || (_tx_snp_rsp == `SNP_FOUND)) ? rx_snp_addr : rx_l1_addr;
  assign tx_snp_addr  = (_tx_snp_rsp == `SNP_FOUND) ? rx_snp_addr : rx_l1_addr;
  assign tx_snp_data  = cac_mem[rx_snp_addr[`IDX]][`DAT];

  // ----------------------------------------------------------------
  // l1 request controller
  // ----------------------------------------------------------------
  fsm_l1_req_ctrl l1_req_crtl (
        .curSt    (l1_req_blk_curSt ),
        .wr_hit   (wr_hit           ),
        .rd_hit   (rd_hit           ),
        .wr_miss  (wr_miss          ),
        .rd_miss  (rd_miss          ),
        .snp_rsp  (rx_snp_rsp       ),

        .nxtSt    (l1_req_blk_nxtSt ),
        .l1_wait  (tx_l1_wait       ),
        //.snp_wb   (l1_req_wb        ),
        .snp_req  (tx_snp_op        )
  );

  // ----------------------------------------------------------------
  // Snoop request controller
  // ----------------------------------------------------------------
  fsm_snp_req_ctrl snp_req_crtl (
        .curSt    (snp_req_blk_curSt),
        .snp_op   (rx_snp_op        ),

        .nxtSt    (snp_req_blk_nxtSt),
        //.snp_wb   (snp_req_wb       ),
        .snp_rsp  (_tx_snp_rsp      )
  );

  // ----------------------------------------------------------------
  // Update cache state when l1 send request or Snoop match 
  // ----------------------------------------------------------------
  always_ff @(posedge clk) begin
    if(!rst_n) begin
      for(int i = 0; i < NUM_BLK; i++) begin
        cac_mem[i][`ST] <= `INVALID;
      end
    end else begin
      if(l1_req)
        cac_mem[rx_l1_addr[`IDX]][`ST] <= l1_req_blk_nxtSt;
      else if(snp_hit)
        cac_mem[rx_snp_addr[`IDX]][`ST] <= snp_req_blk_nxtSt;
    end
  end

  // ----------------------------------------------------------------
  // Update Tag when l1 request miss
  // ----------------------------------------------------------------
  logic snp_ret_dat = (rx_snp_rsp == `SNP_FOUND) || (rx_snp_rsp == `SNP_FETCH);

  always_ff @(posedge clk) begin
    if(!rst_n) begin
      for(int i = 0; i < NUM_BLK; i++) begin
        cac_mem[i][`RAM_TAG] <= {TAG_WIDTH{1'b0}};
      end
    end else begin
      if(snp_ret_dat)
        cac_mem[rx_l1_addr[`IDX]][`RAM_TAG] <= rx_l1_addr[`ADDR_TAG];
    end
  end

  // ----------------------------------------------------------------
  // Update data
  // ----------------------------------------------------------------
  always_ff @(posedge clk) begin
    if(!rst_n) begin
      for(int i = 0; i < NUM_BLK; i++) begin
        cac_mem[i][`DAT] <= {BLK_WIDTH{1'b0}};
      end
    end else begin
      if(wr_hit)
        cac_mem[rx_l1_addr[`IDX]][`DAT] <= rx_l1_data;
      else if(snp_ret_dat)
        cac_mem[rx_l1_addr[`IDX]][`DAT] <= rx_snp_data;
    end
  end
endmodule // cache_mem

`endif
