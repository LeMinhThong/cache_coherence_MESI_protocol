`ifndef CACHE_MEM_SV
`define CACHE_MEM_SV

`include "cache_def.sv"

module cache_mem #(
      parameter PADDR_WIDTH = 64,
      parameter BLK_WIDTH   = 512,
      parameter NUM_BLK     = 1024,

      parameter SADDR_WIDTH = PADDR_WIDTH-$clog2(BLK_WIDTH/8)
) (
      input   logic                   clk       ,
      input   logic                   rst_n     ,

      input   logic                   cdr_valid ,
      output  logic                   cdr_ready ,
      input   logic [2:0]             cdr_op    ,
      input   logic [SADDR_WIDTH-1:0] cdr_addr  ,
      input   logic [BLK_WIDTH-1:0]   cdr_data  ,

      output  logic                   cdt_valid ,
      input   logic                   cdt_ready ,
      output  logic [1:0]             cdt_rsp   ,
      output  logic [BLK_WIDTH-1:0]   cdt_data  ,

      output  logic                   cut_valid ,
      input   logic                   cut_ready ,
      output  logic [1:0]             cut_op    ,
      output  logic [SADDR_WIDTH-1:0] cut_addr  ,

      input   logic                   cur_valid ,
      output  logic                   cur_ready ,
      input   logic [1:0]             cur_rsp   ,
      input   logic [BLK_WIDTH-1:0]   cur_data  ,

      output  logic                   sdt_valid ,
      input   logic                   sdt_ready ,
      output  logic [2:0]             sdt_op    ,
      output  logic [SADDR_WIDTH-1:0] sdt_addr  ,
      output  logic [BLK_WIDTH-1:0]   sdt_data  ,

      input   logic                   sdr_valid ,
      output  logic                   sdr_ready ,
      input   logic [2:0]             sdr_rsp   ,
      input   logic [BLK_WIDTH-1:0]   sdr_data  ,

      input   logic                   sur_valid ,
      output  logic                   sur_ready ,
      input   logic [1:0]             sur_op    ,
      input   logic [SADDR_WIDTH-1:0] sur_addr  ,

      output  logic                   sut_valid ,
      input   logic                   sut_ready ,
      output  logic [1:0]             sut_rsp   ,
      output  logic [BLK_WIDTH-1:0]   sut_data  
);

  // ----------------------------------------------------------------
  // FIXME
  // ----------------------------------------------------------------
  // move considering snp_hit when determine sut_rsp into fsm_snp_req_ctrl

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
  // internal signals
  // ----------------------------------------------------------------

  // ----------------------------------------------------------------
  // Definitioin
  // ----------------------------------------------------------------
  logic cac_wr;
  logic cac_rd;
  logic cac_req;
  logic cac_hit;

  logic wr_hit;
  logic rd_hit;
  logic wr_miss;
  logic rd_miss;

  logic snp_hit;

  logic [ST_WIDTH-1:0] cac_req_blk_curSt;
  logic [ST_WIDTH-1:0] cac_req_blk_nxtSt;
  logic [ST_WIDTH-1:0] snp_req_blk_curSt;
  logic [ST_WIDTH-1:0] snp_req_blk_nxtSt;

  logic snp_ret_dat;

  // ----------------------------------------------------------------
  // Determine L1 request hit or miss
  // ----------------------------------------------------------------
  assign cac_req_blk_curSt  = cac_mem[cdr_addr[`IDX]][`ST];
  assign snp_req_blk_curSt  = cac_mem[sur_addr[`IDX]][`ST];

  assign cac_wr   = (cdr_op == `CDR_WB) ? 1'b1 : 1'b0;
  assign cac_rd   = ((cdr_op == `CDR_RD) || (cdr_op == `CDR_RFO)) ? 1'b1 : 1'b0;
  assign cac_req  = cac_wr || cac_rd;

  assign cac_hit  = ((cac_mem[cdr_addr[`IDX]][`VALID] == 1'b1) && (cdr_addr[`ADDR_TAG] == cac_mem[cdr_addr[`IDX]][`RAM_TAG])) ? 1'b1 : 1'b0;
  assign snp_hit  = ((cac_mem[sur_addr[`IDX]][`VALID] == 1'b1) && (sur_addr[`ADDR_TAG] == cac_mem[sur_addr[`IDX]][`RAM_TAG])) ? 1'b1 : 1'b0;

  assign wr_hit   = cac_wr && cac_hit;
  assign rd_hit   = cac_rd && cac_hit;
  assign wr_miss  = cac_wr && !cac_hit;
  assign rd_miss  = cac_rd && !cac_hit;

  // ----------------------------------------------------------------
  // l1 side output
  // ----------------------------------------------------------------
  assign cdt_data = cac_mem[cdr_addr[`IDX]][`DAT];

  // ----------------------------------------------------------------
  // SNP side output
  // ----------------------------------------------------------------
  assign sdt_addr  = (cac_hit == 1'b0) ? cdr_addr : {SADDR_WIDTH{1'b0}};
  assign sut_data  = cac_mem[sur_addr[`IDX]][`DAT];

  // ----------------------------------------------------------------
  // l1 request controller
  // ----------------------------------------------------------------
  fsm_l1_req_ctrl l1_req_crtl (
        .curSt    (cac_req_blk_curSt),
        .wr_hit   (wr_hit           ),
        .rd_hit   (rd_hit           ),
        .wr_miss  (wr_miss          ),
        .rd_miss  (rd_miss          ),
        .snp_rsp  (sdr_rsp          ),

        .nxtSt    (cac_req_blk_nxtSt),
        .cdt_rsp  (cdt_rsp          ),
        .snp_req  (sdt_op           )
  );

  // ----------------------------------------------------------------
  // Snoop request controller
  // ----------------------------------------------------------------
  fsm_snp_req_ctrl snp_req_crtl (
        .curSt    (snp_req_blk_curSt),
        .snp_op   (sur_op           ),

        .nxtSt    (snp_req_blk_nxtSt),
        .snp_rsp  (sut_rsp          )
  );

  // ----------------------------------------------------------------
  // Update cache state when l1 send request or Snoop match 
  // ----------------------------------------------------------------
  always_ff @(posedge clk) begin
    if(!rst_n) begin
      for(int i = 0; i < NUM_BLK; i++) begin
        cac_mem[i][`ST] <= `INVALID;
      end
    end else begin // FIXME: shouldn't have order
      if(cac_req)
        cac_mem[cdr_addr[`IDX]][`ST] <= cac_req_blk_nxtSt;
      else if(snp_hit)
        cac_mem[sur_addr[`IDX]][`ST] <= snp_req_blk_nxtSt;
    end
  end

  // ----------------------------------------------------------------
  // Update Tag when l1 request miss
  // ----------------------------------------------------------------
  assign snp_ret_dat = ((sdr_rsp == `SDR_SNOOP) || (sdr_rsp == `SDR_FETCH)) ? 1'b1 : 1'b0;

  always_ff @(posedge clk) begin
    if(!rst_n) begin
      for(int i = 0; i < NUM_BLK; i++) begin
        cac_mem[i][`RAM_TAG] <= {TAG_WIDTH{1'b0}};
      end
    end else begin
      if(snp_ret_dat)
        cac_mem[cdr_addr[`IDX]][`RAM_TAG] <= cdr_addr[`ADDR_TAG];
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
        cac_mem[cdr_addr[`IDX]][`DAT] <= cdr_data;
      else if(snp_ret_dat)
        cac_mem[cdr_addr[`IDX]][`DAT] <= sdr_data;
    end
  end
endmodule // cache_mem

`endif
