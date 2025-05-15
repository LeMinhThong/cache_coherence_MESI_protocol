`ifndef CACHE_MEM_SV
`define CACHE_MEM_SV

`include "cache_def.sv"
import cache_pkg::*;

module cache_mem #(
      parameter PADDR_WIDTH = 64,
      parameter BLK_WIDTH   = 512,
      parameter NUM_BLK     = 1024,

      parameter SADDR_WIDTH = PADDR_WIDTH-$clog2(BLK_WIDTH/8)
) 
(
      input   logic                   clk         ,
      input   logic                   rst_n       ,

      input   logic                   cdreq_valid ,
      input   logic [2:0]             cdreq_op    ,
      input   logic [SADDR_WIDTH-1:0] cdreq_addr  ,
      input   logic [BLK_WIDTH-1:0]   cdreq_data  ,
      output  logic                   cdreq_ready ,

      output  logic                   cursp_valid ,
      output  logic [1:0]             cursp_rsp   ,
      output  logic [BLK_WIDTH-1:0]   cursp_data  ,
      input   logic                   cursp_ready ,

      output  logic                   cureq_valid ,
      output  logic [1:0]             cureq_op    ,
      output  logic [SADDR_WIDTH-1:0] cureq_addr  ,
      input   logic                   cureq_ready ,

      input   logic                   cdrsp_valid ,
      input   logic [1:0]             cdrsp_rsp   ,
      input   logic [BLK_WIDTH-1:0]   cdrsp_data  ,
      output  logic                   cdrsp_ready ,

      output  logic                   sdreq_valid ,
      output  logic [2:0]             sdreq_op    ,
      output  logic [SADDR_WIDTH-1:0] sdreq_addr  ,
      output  logic [BLK_WIDTH-1:0]   sdreq_data  ,
      input   logic                   sdreq_ready ,

      input   logic                   sursp_valid ,
      input   logic [2:0]             sursp_rsp   ,
      input   logic [BLK_WIDTH-1:0]   sursp_data  ,
      output  logic                   sursp_ready ,

      input   logic                   sureq_valid ,
      input   logic [1:0]             sureq_op    ,
      input   logic [SADDR_WIDTH-1:0] sureq_addr  ,
      output  logic                   sureq_ready ,

      output  logic                   sdrsp_valid ,
      output  logic [1:0]             sdrsp_rsp   ,
      output  logic [BLK_WIDTH-1:0]   sdrsp_data  ,
      input   logic                   sdrsp_ready
);

  // ----------------------------------------------------------------
  // FIXME
  // ----------------------------------------------------------------
  // move considering snp_hit when determine sdrsp_rsp into fsm_snp_req_ctrl

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
  // internal signals definition
  // ----------------------------------------------------------------
  //logic [2:0]             _cdreq_op;
  //logic [SADDR_WIDTH-1:0] _cdreq_addr;
  //logic [BLK_WIDTH-1:0]   _cdreq_data;

  // ----------------------------------------------------------------
  // inbound channels handshake control
  // ----------------------------------------------------------------
  localparam HS_IDLE      = 2'b00;
  localparam HS_ASSERT    = 2'b01;
  localparam HS_DEASSERT  = 2'b10;

  logic cdreq_en;
  logic cdrsp_en;
  logic sureq_en;
  logic sursp_en;

  logic [2:0] cdreq_hs_curSt, cdreq_hs_nxtSt;
  logic [2:0] cdrsp_hs_curSt, cdrsp_hs_nxtSt;
  logic [2:0] sureq_hs_curSt, sureq_hs_nxtSt;
  logic [2:0] sursp_hs_curSt, sursp_hs_nxtSt;

  // FIXME always allowed to receive flit
  assign cdreq_en = cdreq_valid;
  assign cdrsp_en = cdrsp_valid;
  assign sureq_en = sureq_valid;
  assign sursp_en = sursp_valid;

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      cdreq_hs_curSt <= HS_IDLE;
      cdrsp_hs_curSt <= HS_IDLE;
      sureq_hs_curSt <= HS_IDLE;
      sursp_hs_curSt <= HS_IDLE;
    end
    else begin
      cdreq_hs_curSt <= cdreq_hs_nxtSt;
      cdrsp_hs_curSt <= cdrsp_hs_nxtSt;
      sureq_hs_curSt <= sureq_hs_nxtSt;
      sursp_hs_curSt <= sursp_hs_nxtSt;
    end
  end

  always_comb begin
    case(cdreq_hs_curSt)
      HS_IDLE:
            begin
              if((cdreq_valid == 1'b1) && (cdreq_en == 1'b1))
                cdreq_hs_nxtSt = HS_ASSERT;
              else
                cdreq_hs_nxtSt = HS_IDLE;
            end
      HS_ASSERT:    cdreq_hs_nxtSt = HS_DEASSERT;
      HS_DEASSERT:  cdreq_hs_nxtSt = HS_IDLE;
      default:      cdreq_hs_nxtSt = HS_IDLE;
    endcase // cdreq_hs_curSt
  end

  always_comb begin
    case(cdrsp_hs_curSt)
      HS_IDLE:
            begin
              if((cdrsp_valid == 1'b1) && (cdrsp_en == 1'b1))
                cdrsp_hs_nxtSt = HS_ASSERT;
              else
                cdrsp_hs_nxtSt = HS_IDLE;
            end
      HS_ASSERT:    cdrsp_hs_nxtSt = HS_DEASSERT;
      HS_DEASSERT:  cdrsp_hs_nxtSt = HS_IDLE;
      default:      cdrsp_hs_nxtSt = HS_IDLE;
    endcase // cdrsp_hs_curSt
  end

  always_comb begin
    case(sureq_hs_curSt)
      HS_IDLE:
            begin
              if((sureq_valid == 1'b1) && (sureq_en == 1'b1))
                sureq_hs_nxtSt = HS_ASSERT;
              else
                sureq_hs_nxtSt = HS_IDLE;
            end
      HS_ASSERT:    sureq_hs_nxtSt = HS_DEASSERT;
      HS_DEASSERT:  sureq_hs_nxtSt = HS_IDLE;
      default:      sureq_hs_nxtSt = HS_IDLE;
    endcase // sureq_hs_curSt
  end

  always_comb begin
    case(sursp_hs_curSt)
      HS_IDLE:
            begin
              if((sursp_valid == 1'b1) && (sursp_en == 1'b1))
                sursp_hs_nxtSt = HS_ASSERT;
              else
                sursp_hs_nxtSt = HS_IDLE;
            end
      HS_ASSERT:    sursp_hs_nxtSt = HS_DEASSERT;
      HS_DEASSERT:  sursp_hs_nxtSt = HS_IDLE;
      default:      sursp_hs_nxtSt = HS_IDLE;
    endcase // sursp_hs_curSt
  end

  assign cdreq_ready = (cdreq_hs_curSt == HS_ASSERT) ? 1'b1 : 1'b0;
  assign cdrsp_ready = (cdrsp_hs_curSt == HS_ASSERT) ? 1'b1 : 1'b0;
  assign sureq_ready = (sureq_hs_curSt == HS_ASSERT) ? 1'b1 : 1'b0;
  assign sursp_ready = (sursp_hs_curSt == HS_ASSERT) ? 1'b1 : 1'b0;

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

  logic [ST_WIDTH-1:0] cdreq_blk_curSt;
  logic [ST_WIDTH-1:0] cdreq_blk_nxtSt;
  logic [ST_WIDTH-1:0] sureq_blk_curSt;
  logic [ST_WIDTH-1:0] sureq_blk_nxtSt;

  logic snp_ret_dat;

  // ----------------------------------------------------------------
  // downstream cache request fsm
  // ----------------------------------------------------------------
  //parameter REQ_IDLE          = 3'b000;
  //parameter REQ_ALLOCATE      = 3'b001;
  //parameter REQ_INIT_SDREQ    = 3'b010;
  //parameter REQ_WAIT_SNP_RSP  = 3'b011;
  //parameter REQ_RSP_CURSP     = 3'b100;

  logic [2:0] cdreq_req_curSt;
  logic [2:0] cdreq_req_nxtSt;

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
      cdreq_req_curSt <= REQ_IDLE;
    else
      cdreq_req_curSt <= cdreq_req_nxtSt;
  end

  always_comb begin
    case(cdreq_req_curSt)
      REQ_IDLE:
            begin
              if((cdreq_valid == 1'b1) && (cdreq_en == 1'b1))
                cdreq_req_nxtSt = REQ_ALLOCATE;
              else
                cdreq_req_nxtSt = REQ_IDLE;
            end
      REQ_ALLOCATE:
            begin
              if(cac_hit == 1'b1)
                cdreq_req_nxtSt = REQ_RSP_CURSP;
              else
                cdreq_req_nxtSt = REQ_INIT_SDREQ;
            end
      REQ_INIT_SDREQ:
            begin
              if((sdreq_valid == 1'b1) && (sdreq_ready == 1'b1))
                cdreq_req_nxtSt = REQ_WAIT_SNP_RSP;
              else
                cdreq_req_nxtSt = REQ_INIT_SDREQ;
            end
      REQ_WAIT_SNP_RSP:
            begin
              if((sursp_valid == 1'b1) && (sursp_en == 1'b1))
                cdreq_req_nxtSt = REQ_RSP_CURSP;
              else
                cdreq_req_nxtSt = REQ_WAIT_SNP_RSP;
            end
      REQ_RSP_CURSP:
            begin
              if((cursp_valid == 1'b1) && (cursp_ready == 1'b1))
                cdreq_req_nxtSt = REQ_IDLE;
              else
                cdreq_req_nxtSt = REQ_RSP_CURSP;
            end
    endcase // cdreq_req_curSt
  end

  // ----------------------------------------------------------------
  // outbound channels handshake control
  // ----------------------------------------------------------------
  assign cursp_valid = (cdreq_req_curSt == REQ_RSP_CURSP) ? 1'b1 : 1'b0;
  assign cureq_valid = 1'b1;
  assign sdreq_valid = (cdreq_req_curSt == REQ_INIT_SDREQ) ? 1'b1 : 1'b0;
  assign sdrsp_valid = 1'b1;

  // ----------------------------------------------------------------
  // allocate downstream cache request
  // ----------------------------------------------------------------
  // 1 slot buffer: blocking transaction (oustanding has not supported yet)
  logic                   cdreq_ot;
  logic [2:0]             cdreq_op_bf;
  logic [SADDR_WIDTH-1:0] cdreq_addr_bf;
  logic [BLK_WIDTH-1:0]   cdreq_data_bf;

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      cdreq_ot      <= 1'b0;
      cdreq_op_bf   <= `CDREQ_RD;
      cdreq_addr_bf <= {SADDR_WIDTH{1'b0}};
      cdreq_data_bf <= {BLK_WIDTH{1'b0}};
    end
    else begin
      if((cdreq_valid == 1'b1) && (cdreq_en == 1'b1)) begin
        cdreq_ot      <= 1'b1;
        cdreq_op_bf   <= cdreq_op;
        cdreq_addr_bf <= cdreq_addr;
        cdreq_data_bf <= cdreq_data;
      end
      else if((cursp_valid == 1'b1) && (cdrsp_ready == 1'b1)) begin
        cdreq_ot      <= 1'b0;
        cdreq_op_bf   <= `CDREQ_RD;
        cdreq_addr_bf <= {SADDR_WIDTH{1'b0}};
        cdreq_data_bf <= {BLK_WIDTH{1'b0}};
      end
      else begin
        cdreq_ot      <= cdreq_ot;
        cdreq_op_bf   <= cdreq_op_bf;
        cdreq_addr_bf <= cdreq_addr_bf;
        cdreq_data_bf <= cdreq_data_bf;
      end
    end
  end

  // ----------------------------------------------------------------
  // Determine L1 request hit or miss
  // ----------------------------------------------------------------
  assign cdreq_blk_curSt  = cac_mem[cdreq_addr_bf[`IDX]][`ST];
  assign sureq_blk_curSt  = cac_mem[sureq_addr[`IDX]][`ST];

  assign cac_wr   = ((cdreq_ot == 1'b1) && ((cdreq_op_bf == `CDREQ_MD) || (cdreq_op_bf == `CDREQ_WB) || (cdreq_op_bf == `CDREQ_RFO)))  ? 1'b1 : 1'b0;
  assign cac_rd   = ((cdreq_ot == 1'b1) && (cdreq_op_bf == `CDREQ_RD)) ? 1'b1 : 1'b0;
  assign cac_req  = cac_wr || cac_rd;

  assign cac_hit  = ((cdreq_ot == 1'b1) && (cac_mem[cdreq_addr_bf[`IDX]][`VALID] == 1'b1) && (cdreq_addr_bf[`ADDR_TAG] == cac_mem[cdreq_addr_bf[`IDX]][`RAM_TAG])) ? 1'b1 : 1'b0;
  assign snp_hit  = ((cac_mem[sureq_addr[`IDX]][`VALID] == 1'b1) && (sureq_addr[`ADDR_TAG] == cac_mem[sureq_addr[`IDX]][`RAM_TAG])) ? 1'b1 : 1'b0;

  assign wr_hit   = cac_wr && cac_hit;
  assign rd_hit   = cac_rd && cac_hit;
  assign wr_miss  = cac_wr && !cac_hit;
  assign rd_miss  = cac_rd && !cac_hit;

  // ----------------------------------------------------------------
  // l1 side output
  // ----------------------------------------------------------------
  assign cursp_data = cac_mem[cdreq_addr_bf[`IDX]][`DAT];

  // ----------------------------------------------------------------
  // SNP side output
  // ----------------------------------------------------------------
  assign sdreq_addr = (cac_hit == 1'b0) ? cdreq_addr_bf : {SADDR_WIDTH{1'b0}};
  assign sdrsp_data = cac_mem[sureq_addr[`IDX]][`DAT];

  // ----------------------------------------------------------------
  // l1 request controller
  // ----------------------------------------------------------------
  fsm_l1_req_ctrl l1_req_crtl (
        .blk_curSt  (cdreq_blk_curSt),
        .req_status ({wr_miss, rd_miss, wr_hit, rd_hit}),
        .req_curSt  (cdreq_req_curSt),
        .sursp_rsp  (sursp_rsp      ),

        .blk_nxtSt  (cdreq_blk_nxtSt),
        .cursp_rsp  (cursp_rsp      ),
        .init_sdreq (sdreq_op       )
  );

  // ----------------------------------------------------------------
  // Snoop request controller
  // ----------------------------------------------------------------
  fsm_snp_req_ctrl snp_req_crtl (
        .curSt    (sureq_blk_curSt),
        .snp_op   (sureq_op       ),

        .nxtSt    (sureq_blk_nxtSt),
        .snp_rsp  (sdrsp_rsp      )
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
        cac_mem[cdreq_addr_bf[`IDX]][`ST] <= cdreq_blk_nxtSt;
      else if(snp_hit)
        cac_mem[sureq_addr[`IDX]][`ST] <= sureq_blk_nxtSt;
    end
  end

  // ----------------------------------------------------------------
  // Update Tag when l1 request miss
  // ----------------------------------------------------------------
  assign snp_ret_dat = ((sursp_rsp == `SURSP_SNOOP) || (sursp_rsp == `SURSP_FETCH)) ? 1'b1 : 1'b0;

  always_ff @(posedge clk) begin
    if(!rst_n) begin
      for(int i = 0; i < NUM_BLK; i++) begin
        cac_mem[i][`RAM_TAG] <= {TAG_WIDTH{1'b0}};
      end
    end else begin
      if(snp_ret_dat)
        cac_mem[cdreq_addr_bf[`IDX]][`RAM_TAG] <= cdreq_addr_bf[`ADDR_TAG];
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
        cac_mem[cdreq_addr_bf[`IDX]][`DAT] <= cdreq_data_bf;
      else if(snp_ret_dat)
        cac_mem[cdreq_addr_bf[`IDX]][`DAT] <= sursp_data;
    end
  end
endmodule // cache_mem

`endif
