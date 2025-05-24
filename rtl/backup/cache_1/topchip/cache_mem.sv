`ifndef CACHE_MEM_SV
`define CACHE_MEM_SV

`include "cache_def.sv"
import cache_pkg::*;

module cache_mem #(
      parameter NUM_BLK     = 1024,
      parameter PADDR_WIDTH = 64,
      parameter BLK_WIDTH   = 512,

      parameter SADDR_WIDTH = PADDR_WIDTH-$clog2(BLK_WIDTH/8)
) (
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
  parameter IDX_WIDTH  = $clog2(NUM_BLK);
  parameter TAG_WIDTH  = SADDR_WIDTH - IDX_WIDTH;
  parameter RAM_WIDTH  = ST_WIDTH + TAG_WIDTH + BLK_WIDTH;

  // ----------------------------------------------------------------
  // internal signals definition
  // ----------------------------------------------------------------
  logic [BLK_WIDTH-1:0]   cdreqAddr_2mem_data;
  logic [BLK_WIDTH-1:0]   sureqAddr_2mem_data;

  logic [TAG_WIDTH-1:0]   cdreqAddr_2mem_tag;
  logic [TAG_WIDTH-1:0]   sureqAddr_2mem_tag;


  // ----------------------------------------------------------------
  // inbound channels handshake control
  // ----------------------------------------------------------------
  localparam HS_IDLE      = 2'b00;
  localparam HS_ASSERT    = 2'b01;
  localparam HS_DEASSERT  = 2'b10;

  // inbound channels handshake complete acknowledgement
  logic cdreq_hs_en;
  logic cdrsp_hs_en;
  logic sureq_hs_en;
  logic sursp_hs_en;

  // FIXME always allowed to receive flit
  assign cdreq_hs_en = (!rst_n) ? 1'b0 : cdreq_valid;
  assign cdrsp_hs_en = (!rst_n) ? 1'b0 : cdrsp_valid;
  assign sureq_hs_en = (!rst_n) ? 1'b0 : sureq_valid;
  assign sursp_hs_en = (!rst_n) ? 1'b0 : sursp_valid;

  // outbound channels handshake complete acknowledgement
  logic cureq_hs_compack; 
  logic cursp_hs_compack; 
  logic sdreq_hs_compack; 
  logic sdrsp_hs_compack; 

  assign cureq_hs_compack = cureq_valid && cureq_ready;
  assign cursp_hs_compack = cursp_valid && cursp_ready;
  assign sdreq_hs_compack = sdreq_valid && sdreq_ready;
  assign sdrsp_hs_compack = sdrsp_valid && sdrsp_ready;

  logic [2:0] cdreq_hs_curSt, cdreq_hs_nxtSt;
  logic [2:0] cdrsp_hs_curSt, cdrsp_hs_nxtSt;
  logic [2:0] sureq_hs_curSt, sureq_hs_nxtSt;
  logic [2:0] sursp_hs_curSt, sursp_hs_nxtSt;

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
      HS_IDLE:      cdreq_hs_nxtSt = (cdreq_hs_en) ? HS_ASSERT : HS_IDLE;
      HS_ASSERT:    cdreq_hs_nxtSt = HS_DEASSERT;
      HS_DEASSERT:  cdreq_hs_nxtSt = HS_IDLE;
      default:      cdreq_hs_nxtSt = HS_IDLE;
    endcase // cdreq_hs_curSt
  end

  always_comb begin
    case(cdrsp_hs_curSt)
      HS_IDLE:      cdrsp_hs_nxtSt = (cdrsp_hs_en) ? HS_ASSERT : HS_IDLE;
      HS_ASSERT:    cdrsp_hs_nxtSt = HS_DEASSERT;
      HS_DEASSERT:  cdrsp_hs_nxtSt = HS_IDLE;
      default:      cdrsp_hs_nxtSt = HS_IDLE;
    endcase // cdrsp_hs_curSt
  end

  always_comb begin
    case(sureq_hs_curSt)
      HS_IDLE:      sureq_hs_nxtSt = (sureq_hs_en) ? HS_ASSERT : HS_IDLE;
      HS_ASSERT:    sureq_hs_nxtSt = HS_DEASSERT;
      HS_DEASSERT:  sureq_hs_nxtSt = HS_IDLE;
      default:      sureq_hs_nxtSt = HS_IDLE;
    endcase // sureq_hs_curSt
  end

  always_comb begin
    case(sursp_hs_curSt)
      HS_IDLE:     sursp_hs_nxtSt = (sursp_hs_en) ? HS_ASSERT : HS_IDLE;
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
  // allocate downstream cache request
  // ----------------------------------------------------------------
  // 1 slot buffer: blocking transaction (oustanding has not supported yet)
  logic                   cdreq_ot;
  logic [2:0]             cdreq_op_bf;
  logic [SADDR_WIDTH-1:0] cdreq_addr_bf;
  logic [BLK_WIDTH-1:0]   cdreq_data_bf;

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n || cursp_hs_compack) begin
      cdreq_ot      <= 1'b0;
      cdreq_op_bf   <= CDREQ_RD;
      cdreq_addr_bf <= {SADDR_WIDTH{1'b0}};
      cdreq_data_bf <= {BLK_WIDTH{1'b0}};
    end
    else begin
      if(cdreq_hs_en) begin
        cdreq_ot      <= 1'b1;
        cdreq_op_bf   <= cdreq_op;
        cdreq_addr_bf <= cdreq_addr;
        cdreq_data_bf <= cdreq_data;
      end
    end
  end

  // ----------------------------------------------------------------
  // allocate upstream snoop request
  // ----------------------------------------------------------------
  // 1 slot buffer: blocking transaction (oustanding has not supported yet)
  logic                   sureq_ot;
  logic [1:0]             sureq_op_bf;
  logic [SADDR_WIDTH-1:0] sureq_addr_bf;

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n || sdrsp_hs_compack) begin
      sureq_ot      <= 1'b0;
      sureq_op_bf   <= SUREQ_RD;
      sureq_addr_bf <= {SADDR_WIDTH{1'b0}};
    end
    else begin
      if(sureq_hs_en) begin
        sureq_ot      <= 1'b1;
        sureq_op_bf   <= sureq_op;
        sureq_addr_bf <= sureq_addr;
      end
    end
  end

  // ----------------------------------------------------------------
  // Definitioin
  // ----------------------------------------------------------------
  logic cac_wr;
  logic cac_rd;
  logic cac_hit;

  logic wr_hit;
  logic rd_hit;
  logic wr_miss;
  logic rd_miss;


  logic [3:0] cache_lookup;

  logic snp_hit;

  logic [ST_WIDTH-1:0] cdreqAddr_2mem_blk_curSt;
  logic [ST_WIDTH-1:0] sureqAddr_2mem_blk_curSt;
  logic [ST_WIDTH-1:0] cdreqAddr_2mem_blk_nxtSt;
  logic [ST_WIDTH-1:0] sureqAddr_2mem_blk_nxtSt;

  // ----------------------------------------------------------------
  logic [2:0] cdreq_req_curSt;
  logic [2:0] sureq_req_curSt;

  logic       blk_valid_in_l1;
  logic       cdreq_init_sdreq_inv;
  logic       sureq_init_cureq_inv;

  assign blk_valid_in_l1      = 1'b1;
  assign cdreq_init_sdreq_inv = ((cdreqAddr_2mem_blk_curSt == SHARED) && ((cdreq_op_bf == CDREQ_RFO) || (cdreq_op_bf == CDREQ_MD)));
  assign sureq_init_cureq_inv = (snp_hit && blk_valid_in_l1 && (((sureq_op_bf == SUREQ_RFO) || (sureq_op_bf == SUREQ_INV)) && (sureqAddr_2mem_blk_curSt != MIGRATED)));

  // ----------------------------------------------------------------
  // outbound channels handshake control
  // ----------------------------------------------------------------
  assign sdreq_valid = ((cdreq_req_curSt == CDREQ_INIT_SDREQ) || (sureq_req_curSt == SUREQ_INIT_SDREQ)) ? 1'b1 : 1'b0;
  assign cursp_valid = (cac_hit && (cdreq_req_curSt == CDREQ_SEND_RSP)) ? 1'b1 : 1'b0;
  assign cureq_valid = (sureq_req_curSt == SUREQ_INIT_CUREQ)            ? 1'b1 : 1'b0;
  assign sdrsp_valid = (sureq_req_curSt == SUREQ_SEND_RSP)              ? 1'b1 : 1'b0;

  // ----------------------------------------------------------------
  // Determine L1 request hit or miss
  // ----------------------------------------------------------------
  assign cac_wr   = (cdreq_ot && ((cdreq_op_bf == CDREQ_MD) || (cdreq_op_bf == CDREQ_WB) || (cdreq_op_bf == CDREQ_RFO)))  ? 1'b1 : 1'b0;
  assign cac_rd   = (cdreq_ot && (cdreq_op_bf == CDREQ_RD)) ? 1'b1 : 1'b0;

  assign cac_hit  = (cdreq_ot && cdreqAddr_2mem_blk_curSt[0] && (cdreqAddr_2mem_tag == cdreq_addr_bf[`ADDR_TAG])) ? 1'b1 : 1'b0;
  assign snp_hit  = (sureq_ot && sureqAddr_2mem_blk_curSt[0] && (sureqAddr_2mem_tag == sureq_addr_bf[`ADDR_TAG])) ? 1'b1 : 1'b0;

  assign wr_hit   = cac_wr && cac_hit;
  assign rd_hit   = cac_rd && cac_hit;
  assign wr_miss  = cac_wr && !cac_hit;
  assign rd_miss  = cac_rd && !cac_hit;

  assign cache_lookup = {wr_miss, rd_miss, wr_hit, rd_hit};

  // ----------------------------------------------------------------
  // CUREQ channel control
  // ----------------------------------------------------------------
  assign cureq_addr = (snp_hit) ? sureq_addr_bf : {SADDR_WIDTH{1'b0}};

  // ----------------------------------------------------------------
  // CURSP channel control
  // ----------------------------------------------------------------
  assign cursp_data = ((cdreq_op_bf == CDREQ_RD) || (cdreq_op_bf == CDREQ_RFO)) ? cdreqAddr_2mem_data : {BLK_WIDTH{1'b0}};

  // ----------------------------------------------------------------
  // SDREQ channel control
  // ----------------------------------------------------------------
  assign sdreq_addr = (cdreq_req_curSt == CDREQ_INIT_SDREQ) ? cdreq_addr_bf :
                      (sureq_req_curSt == SUREQ_INIT_SDREQ) ? sureq_addr_bf : {SADDR_WIDTH{1'b0}};
  assign sdreq_data = (sdreq_op == SDREQ_WB) ? sureqAddr_2mem_data : {BLK_WIDTH{1'b0}};

  // ----------------------------------------------------------------
  // SDRSP channel control
  // ----------------------------------------------------------------
  assign sdrsp_data = (snp_hit && ((sureq_op_bf == SUREQ_RD) || (sureq_op_bf == SUREQ_RFO))) ? sureqAddr_2mem_data : {BLK_WIDTH{1'b0}};

  // ----------------------------------------------------------------
  logic [2:0] cdreq_2_sdreq;
  logic [2:0] sureq_2_sdreq;

  fsm_l1_req_ctrl l1_req_crtl (
        .blk_curSt    (cdreqAddr_2mem_blk_curSt ),
        .cache_lookup (cache_lookup             ),
        .cdreq_op     (cdreq_op_bf              ),
        .req_curSt    (cdreq_req_curSt          ),
        .sursp_rsp    (sursp_rsp                ),

        .blk_nxtSt    (cdreqAddr_2mem_blk_nxtSt ),
        .init_sdreq   (cdreq_2_sdreq            ),
        .cursp_rsp    (cursp_rsp                )
  );

  // ----------------------------------------------------------------
  fsm_snp_req_ctrl snp_req_crtl (
        .blk_curSt        (sureqAddr_2mem_blk_curSt ),
        .sureq_op         (sureq_op_bf              ),
        .blk_valid_in_l1  (blk_valid_in_l1          ),

        .blk_nxtSt        (sureqAddr_2mem_blk_nxtSt ),
        .init_cureq       (cureq_op                 ),
        .init_sdreq       (sureq_2_sdreq            ),
        .sdrsp_rsp        (sdrsp_rsp                )
  );

  // ----------------------------------------------------------------
  memory_storage #(
        .NUM_BLK      (NUM_BLK),
        .BLK_WIDTH    (BLK_WIDTH),
        .SADDR_WIDTH  (SADDR_WIDTH),

        .IDX_WIDTH    (IDX_WIDTH),
        .TAG_WIDTH    (TAG_WIDTH),
        .RAM_WIDTH    (RAM_WIDTH)
  ) mem (
        .clk                      (clk                      ),
        .rst_n                    (rst_n                    ),

        .cdreq_req_curSt          (cdreq_req_curSt          ),
        .cdreqAddr_2mem_blk_nxtSt (cdreqAddr_2mem_blk_nxtSt ),
        .cac_hit                  (cac_hit                  ),
        .sursp_hs_en              (sursp_hs_en              ),
        .cdreq_init_sdreq_inv     (cdreq_init_sdreq_inv     ),
        .cdreq_op                 (cdreq_op_bf              ),
        .cdreq_addr               (cdreq_addr_bf            ),
        .cdreq_data               (cdreq_data_bf            ),
        .sursp_data               (sursp_data               ),

        .sureqAddr_2mem_blk_nxtSt (sureqAddr_2mem_blk_nxtSt ),
        .sdrsp_hs_compack         (sdrsp_hs_compack         ),
        .cdrsp_hs_en              (cdrsp_hs_en              ),
        .sureq_addr               (sureq_addr_bf            ),
        .cdrsp_data               (cdrsp_data               ),

        .cdreqAddr_2mem_blk_curSt (cdreqAddr_2mem_blk_curSt ),
        .cdreqAddr_2mem_data      (cdreqAddr_2mem_data      ),
        .cdreqAddr_2mem_tag       (cdreqAddr_2mem_tag       ),

        .sureqAddr_2mem_blk_curSt (sureqAddr_2mem_blk_curSt ),
        .sureqAddr_2mem_data      (sureqAddr_2mem_data      ),
        .sureqAddr_2mem_tag       (sureqAddr_2mem_tag       )
  );

  // ----------------------------------------------------------------
  state_controller #(
        .NUM_BLK      (NUM_BLK),
        .BLK_WIDTH    (BLK_WIDTH),
        .SADDR_WIDTH  (SADDR_WIDTH),

        .IDX_WIDTH    (IDX_WIDTH),
        .TAG_WIDTH    (TAG_WIDTH),
        .RAM_WIDTH    (RAM_WIDTH)
  ) st_ctrl (
        .clk                      (clk                      ),
        .rst_n                    (rst_n                    ),

        .cdreq_hs_en              (cdreq_hs_en              ),
        .cac_hit                  (cac_hit                  ),
        .cdreq_init_sdreq_inv     (cdreq_init_sdreq_inv     ),
        .sdreq_hs_compack         (sdreq_hs_compack         ),
        .sursp_hs_en              (sursp_hs_en              ),
        .cursp_hs_compack         (cursp_hs_compack         ),

        .sureq_hs_en              (sureq_hs_en              ),
        .snp_hit                  (snp_hit                  ),
        .sureqAddr_2mem_blk_curSt (sureqAddr_2mem_blk_curSt ),
        .sureq_init_cureq_inv     (sureq_init_cureq_inv     ),
        .cureq_hs_compack         (cureq_hs_compack         ),
        .cdrsp_hs_en              (cdrsp_hs_en              ),
        .sdrsp_hs_compack         (sdrsp_hs_compack         ),

        .cdreq_req_curSt          (cdreq_req_curSt          ),
        .sureq_req_curSt          (sureq_req_curSt          )
  );

  assign sdreq_op = (cdreq_req_curSt == CDREQ_INIT_SDREQ) ? cdreq_2_sdreq : (sureq_req_curSt == SUREQ_INIT_SDREQ) ? sureq_2_sdreq : SDREQ_RD;

endmodule // cache_mem

`endif
