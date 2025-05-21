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
  logic [2:0]             sureq_op_bf;
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

  // ----------------------------------------------------------------
  // CDERQ state controller FSM
  // ----------------------------------------------------------------
  logic [2:0] cdreq_req_curSt;
  logic [2:0] cdreq_req_nxtSt;

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
      cdreq_req_curSt <= CDREQ_IDLE;
    else
      cdreq_req_curSt <= cdreq_req_nxtSt;
  end

  always_comb begin
    case(cdreq_req_curSt)
      CDREQ_IDLE:       cdreq_req_nxtSt = (cdreq_hs_en      ) ? CDREQ_ALLOCATE    : CDREQ_IDLE;
      CDREQ_ALLOCATE:   cdreq_req_nxtSt = (cac_hit          ) ? CDREQ_SEND_RSP    : CDREQ_INIT_SDREQ;
      CDREQ_INIT_SDREQ: cdreq_req_nxtSt = (sdreq_hs_compack ) ? CDREQ_WAIT_SURSP  : CDREQ_INIT_SDREQ;
      CDREQ_WAIT_SURSP: cdreq_req_nxtSt = (sursp_hs_en      ) ? CDREQ_SEND_RSP    : CDREQ_WAIT_SURSP;
      CDREQ_SEND_RSP:   cdreq_req_nxtSt = (cursp_hs_compack ) ? CDREQ_IDLE        : CDREQ_SEND_RSP;
      default:          cdreq_req_nxtSt = CDREQ_IDLE;
    endcase // cdreq_req_curSt
  end

  // ----------------------------------------------------------------
  // SUREQ state controller FSM
  // ----------------------------------------------------------------
  logic [2:0] sureq_req_curSt;
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
              if(!snp_hit || (snp_hit && ((sureq_op_bf == SUREQ_INV) || (sureq_blk_curSt == EXCLUSIVE) || (sureq_blk_curSt == SHARED)))) begin
                sureq_req_nxtSt = SUREQ_SEND_RSP;
              end
              else begin
                if(sureq_blk_curSt == MIGRATED)
                  sureq_req_nxtSt = SUREQ_INIT_CUREQ;
                else
                  sureq_req_nxtSt = SUREQ_INIT_SDREQ;
              end
            end
      SUREQ_INIT_CUREQ: sureq_req_nxtSt = (cureq_hs_compack ) ? SUREQ_WAIT_CDRSP  : SUREQ_INIT_CUREQ;
      SUREQ_WAIT_CDRSP: sureq_req_nxtSt = (cdrsp_hs_en      ) ? SUREQ_INIT_SDREQ  : SUREQ_WAIT_CDRSP;
      SUREQ_INIT_SDREQ: sureq_req_nxtSt = (sdreq_hs_compack ) ? SUREQ_WAIT_SURSP  : SUREQ_INIT_SDREQ;
      SUREQ_WAIT_SURSP: sureq_req_nxtSt = (sursp_hs_en      ) ? SUREQ_SEND_RSP    : SUREQ_WAIT_SURSP;
      SUREQ_SEND_RSP:   sureq_req_nxtSt = (sdrsp_hs_compack ) ? SUREQ_IDLE        : SUREQ_SEND_RSP;
      default:          sureq_req_nxtSt = SUREQ_IDLE;
    endcase // sureq_req_curSt
  end

  // ----------------------------------------------------------------
  // outbound channels handshake control
  // ----------------------------------------------------------------
  assign cursp_valid = (cac_hit && (cdreq_req_curSt == CDREQ_SEND_RSP)) ? 1'b1 : 1'b0;
  assign cureq_valid = 1'b0;
  assign sdreq_valid = (cdreq_req_curSt == CDREQ_INIT_SDREQ)  ? 1'b1 : 1'b0;
  assign sdrsp_valid = (sureq_req_curSt == SUREQ_SEND_RSP) ? 1'b1 : 1'b0;

  // ----------------------------------------------------------------
  // Determine L1 request hit or miss
  // ----------------------------------------------------------------
  assign cdreq_blk_curSt  = cac_mem[cdreq_addr_bf[`IDX]][`ST];
  assign sureq_blk_curSt  = cac_mem[sureq_addr_bf[`IDX]][`ST];

  assign cac_wr   = (cdreq_ot && ((cdreq_op_bf == CDREQ_MD) || (cdreq_op_bf == CDREQ_WB) || (cdreq_op_bf == CDREQ_RFO)))  ? 1'b1 : 1'b0;
  assign cac_rd   = (cdreq_ot && (cdreq_op_bf == CDREQ_RD)) ? 1'b1 : 1'b0;
  assign cac_req  = cac_wr || cac_rd;

  assign cac_hit  = (cdreq_ot && cac_mem[cdreq_addr_bf[`IDX]][`VALID] && (cdreq_addr_bf[`ADDR_TAG] == cac_mem[cdreq_addr_bf[`IDX]][`RAM_TAG])) ? 1'b1 : 1'b0;
  assign snp_hit  = (sureq_ot && cac_mem[sureq_addr_bf[`IDX]][`VALID] && (sureq_addr_bf[`ADDR_TAG] == cac_mem[sureq_addr_bf[`IDX]][`RAM_TAG])) ? 1'b1 : 1'b0;

  assign wr_hit   = cac_wr && cac_hit;
  assign rd_hit   = cac_rd && cac_hit;
  assign wr_miss  = cac_wr && !cac_hit;
  assign rd_miss  = cac_rd && !cac_hit;

  // ----------------------------------------------------------------
  // CUREQ channel control
  // ----------------------------------------------------------------
  //assign cureq_addr = (snp_hit)

  // ----------------------------------------------------------------
  // CURSP channel control
  // ----------------------------------------------------------------
  assign cursp_data = cac_mem[cdreq_addr_bf[`IDX]][`DAT];

  // ----------------------------------------------------------------
  // SDREQ channel control
  // ----------------------------------------------------------------
  assign sdreq_addr = (!cac_hit) ? cdreq_addr_bf : {SADDR_WIDTH{1'b0}};
  assign sdreq_data = (sdreq_op == SDREQ_WB) ? cac_mem[sureq_addr_bf[`IDX]][`DAT] : {BLK_WIDTH{1'b0}};

  // ----------------------------------------------------------------
  // SDRSP channel control
  // ----------------------------------------------------------------
  assign sdrsp_data = cac_mem[sureq_addr_bf[`IDX]][`DAT];

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
        .blk_curSt  (sureq_blk_curSt),
        .snp_op     (sureq_op_bf    ),

        .blk_nxtSt  (sureq_blk_nxtSt),
        .snp_rsp    (sdrsp_rsp      )
  );

  // ----------------------------------------------------------------
  // Update block state
  // ----------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      for(int i = 0; i < NUM_BLK; i++) begin
        cac_mem[i][`ST] <= INVALID;
      end
    end
    else begin
      if(cdreq_req_curSt == CDREQ_SEND_RSP) begin
        `rtl_print_if_dff(cdreq_blk_curSt, cdreq_blk_nxtSt, cdreq_addr_bf, "state updated")
        cac_mem[cdreq_addr_bf[`IDX]][`ST] <= cdreq_blk_nxtSt;
      end
      else if(sdrsp_hs_compack) begin
        `rtl_print_if_dff(sureq_blk_curSt, sureq_blk_nxtSt, cdreq_addr_bf, "state updated")
        cac_mem[sureq_addr_bf[`IDX]][`ST] <= sureq_blk_nxtSt;
      end
    end
  end

  // ----------------------------------------------------------------
  // Update Tag
  // ----------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      for(int i = 0; i < NUM_BLK; i++) begin
        cac_mem[i][`RAM_TAG] <= {TAG_WIDTH{1'b0}};
      end
    end else begin
      if((cdreq_req_curSt == CDREQ_SEND_RSP) && !cac_hit) begin
        `rtl_print_if_dff(cac_mem[cdreq_addr_bf[`IDX]][`RAM_TAG], cdreq_addr_bf[`ADDR_TAG], cdreq_addr_bf, "tag updated")
        cac_mem[cdreq_addr_bf[`IDX]][`RAM_TAG] <= cdreq_addr_bf[`ADDR_TAG];
      end
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
      if(cdreq_op_bf == CDREQ_WB) begin
        `rtl_print_if_dff(cac_mem[cdreq_addr_bf[`IDX]][`DAT], cdreq_data_bf, cdreq_addr_bf, "data updated")
        cac_mem[cdreq_addr_bf[`IDX]][`DAT] <= cdreq_data_bf;
      end
      else if(((cdreq_op_bf == CDREQ_RFO) || (cdreq_op_bf == CDREQ_RD)) && (cdreq_req_curSt == CDREQ_SEND_RSP) && sursp_hs_en) begin
        `rtl_print_if_dff(cac_mem[cdreq_addr_bf[`IDX]][`DAT], sursp_data, cdreq_addr_bf, "data updated")
        cac_mem[cdreq_addr_bf[`IDX]][`DAT] <= sursp_data;
      end
    end
  end
endmodule // cache_mem

`endif
