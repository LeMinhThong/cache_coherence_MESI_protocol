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
  // def_blk: cache RAM structure
  // ----------------------------------------------------------------
  // |          --  Cache RAM width --
  // |State   |Tag                |Data          |
  // |3bits   |TAG_WIDTH          |BLK_WIDTH    0|
  // ----------------------------------------------------------------
  localparam NUM_IDX    = NUM_BLK/NUM_WAY;
  localparam IDX_WIDTH  = $clog2(NUM_BLK/NUM_WAY);
  localparam TAG_WIDTH  = SADDR_WIDTH - IDX_WIDTH;
  localparam RAM_WIDTH  = ST_WIDTH + TAG_WIDTH + BLK_WIDTH;

  logic [RAM_WIDTH-1:0] mem [0:(NUM_BLK/NUM_WAY)-1][0:NUM_WAY-1];

  // ----------------------------------------------------------------
  // def_blk: handshake control
  // ----------------------------------------------------------------
  logic                       cdreq_hs_en;
  logic                       cdrsp_hs_en;
  logic                       sureq_hs_en;
  logic                       sursp_hs_en;

  logic                       cureq_hs_compack; 
  logic                       cursp_hs_compack; 
  logic                       sdreq_hs_compack; 
  logic                       sdrsp_hs_compack; 

  logic [2:0]                 cdreq_hs_curSt, cdreq_hs_nxtSt;
  logic [2:0]                 cdrsp_hs_curSt, cdrsp_hs_nxtSt;
  logic [2:0]                 sureq_hs_curSt, sureq_hs_nxtSt;
  logic [2:0]                 sursp_hs_curSt, sursp_hs_nxtSt;

  // ----------------------------------------------------------------
  // def_blk: request buffer
  // ----------------------------------------------------------------
  logic                   cdreq_ot;
  logic [2:0]             cdreq_op_bf;
  logic [SADDR_WIDTH-1:0] cdreq_addr_bf;
  logic [BLK_WIDTH-1:0]   cdreq_data_bf;

  logic                   sureq_ot;
  logic [1:0]             sureq_op_bf;
  logic [SADDR_WIDTH-1:0] sureq_addr_bf;

  // ----------------------------------------------------------------
  // def_blk: cache lookup
  // ----------------------------------------------------------------
  logic [ST_WIDTH-1:0]    cdreq_blk_curSt, cdreq_blk_nxtSt;
  logic [ST_WIDTH-1:0]    sureq_blk_curSt, sureq_blk_nxtSt;

  logic                   cdreq_way_0_hit;
  logic                   cdreq_way_1_hit;
  logic                   cdreq_way_2_hit;
  logic                   cdreq_way_3_hit;

  logic                   sureq_way_0_hit;
  logic                   sureq_way_1_hit;
  logic                   sureq_way_2_hit;
  logic                   sureq_way_3_hit;

  logic [IDX_WIDTH-1:0]   cdreq_idx;
  logic [IDX_WIDTH-1:0]   sureq_idx;

  logic [SADDR_WIDTH-1:0] evict_blk_2_addr;

  logic [1:0]             cdreq_hit_way;
  logic [1:0]             cdreq_inv_way;
  logic [1:0]             cdreq_way;

  logic [1:0]             sureq_way;

  logic                   cac_wr;
  logic                   cac_rd;
  logic                   cac_hit;
  logic                   fill_inv_blk;
  logic                   evict_ack;
  logic                   wr_hit;
  logic                   rd_hit;
  logic                   wr_miss;
  logic                   rd_miss;
  logic [3:0]             cache_lookup;

  logic                   snp_hit;

  // ----------------------------------------------------------------
  // def_blk: corner_case detector
  // ----------------------------------------------------------------
  logic cdreq_corner_rd_rfo_hit_migrated;
  logic cdreq_corner_md_miss;
  logic cdreq_corner_wb_not_hit_migrated;
  logic cdreq_corner_triger;
  logic cdreq_corner_ack;

  logic sureq_corner_triger;
  logic sureq_corner_ack;
  // ----------------------------------------------------------------
  // def_blk: phase controller
  // ----------------------------------------------------------------
  logic [3:0]             cdreq_req_curSt, cdreq_req_nxtSt;
  logic [2:0]             sureq_req_curSt, sureq_req_nxtSt;

  logic                   cdreq_init_sdreq_inv;
  logic                   sureq_init_cureq_inv;
  logic                   sureq_init_cureq_rfo;

  logic [2:0]             cdreq_2_sdreq;
  logic [2:0]             sureq_2_sdreq;

  logic                   blk_valid_in_l1;

  // ----------------------------------------------------------------
  // imp_blk: handshake CompAck
  // ----------------------------------------------------------------
  // FIXME always allowed to receive flit
  assign cdreq_hs_en      = (!rst_n) ? 1'b0 : cdreq_valid;
  assign cdrsp_hs_en      = (!rst_n) ? 1'b0 : cdrsp_valid;
  assign sureq_hs_en      = (!rst_n) ? 1'b0 : sureq_valid;
  assign sursp_hs_en      = (!rst_n) ? 1'b0 : sursp_valid;

  assign cureq_hs_compack = cureq_valid && cureq_ready;
  assign cursp_hs_compack = cursp_valid && cursp_ready;
  assign sdreq_hs_compack = sdreq_valid && sdreq_ready;
  assign sdrsp_hs_compack = sdrsp_valid && sdrsp_ready;

  // ----------------------------------------------------------------
  // imp_blk: handshake controller - ready signals
  // ----------------------------------------------------------------
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

  assign cdreq_ready = (cdreq_hs_curSt == HS_ASSERT);
  assign cdrsp_ready = (cdrsp_hs_curSt == HS_ASSERT);
  assign sureq_ready = (sureq_hs_curSt == HS_ASSERT);
  assign sursp_ready = (sursp_hs_curSt == HS_ASSERT);

  // ----------------------------------------------------------------
  // imp_blk: handshake control - valid signals
  // ----------------------------------------------------------------
  assign sdreq_valid =  ( (cdreq_req_curSt == CDREQ_INIT_SDREQ) ||
                          (cdreq_req_curSt == CDREQ_EVICT_ACK ) ||
                          (sureq_req_curSt == SUREQ_INIT_SDREQ)
                        );

  assign cursp_valid =  ( (cdreq_req_curSt == CDREQ_SEND_RSP) &&
                          (cac_hit || cdreq_corner_ack)
                        );

  assign cureq_valid =  ( (sureq_req_curSt == SUREQ_INIT_CUREQ) ||
                          (cdreq_req_curSt == CDREQ_INIT_CUREQ)
                        );

  assign sdrsp_valid =  (sureq_req_curSt == SUREQ_SEND_RSP);

  // ----------------------------------------------------------------
  // imp_blk: corner_case detector
  // ----------------------------------------------------------------
  assign cdreq_corner_rd_rfo_hit_migrated = (cdreq_req_curSt == CDREQ_ALLOCATE) &&
                                            ((cdreq_op_bf == CDREQ_RD) || (cdreq_op_bf == CDREQ_RFO)) &&
                                            cac_hit &&
                                            (cdreq_blk_curSt == MIGRATED);

  assign cdreq_corner_md_miss             = (cdreq_req_curSt == CDREQ_ALLOCATE) &&
                                            (cdreq_op_bf == CDREQ_MD) &&
                                            !cac_hit;

  assign cdreq_corner_wb_not_hit_migrated = (cdreq_req_curSt == CDREQ_ALLOCATE) &&
                                            (cdreq_op_bf == CDREQ_WB) &&
                                            (!cac_hit || (cdreq_blk_curSt != MIGRATED));

  assign cdreq_corner_triger              = cdreq_corner_rd_rfo_hit_migrated ||
                                            cdreq_corner_md_miss ||
                                            cdreq_corner_wb_not_hit_migrated;

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
      cdreq_corner_ack <= 1'b0;
    else begin
      if(cdreq_corner_triger)
        cdreq_corner_ack <= 1'b1;
      else if(cursp_hs_compack)
        cdreq_corner_ack <= 1'b0;
    end
  end

  assign sureq_corner_triger  = (sureq_req_curSt == SUREQ_ALLOCATE) &&
                                (sureq_op_bf == SUREQ_INV) &&
                                snp_hit &&
                                ((sureq_blk_curSt == EXCLUSIVE) || (sureq_blk_curSt == MIGRATED) || (sureq_blk_curSt == MODIFIED));

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
      sureq_corner_ack <= 1'b0;
    else begin
      if(sureq_corner_triger)
        sureq_corner_ack <= 1'b1;
      else if(sdrsp_hs_compack)
        sureq_corner_ack <= 1'b0;
    end
  end

  // ----------------------------------------------------------------
  // imp_blk: allocate CDREQ
  // ----------------------------------------------------------------
  // FIXME: 1 slot buffer: blocking transaction (oustanding has not supported yet)
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
  // imp_blk: allocate SUREQ
  // ----------------------------------------------------------------
  // FIXME: 1 slot buffer: blocking transaction (oustanding has not supported yet)
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
  // imp_blk: way set associative
  // ----------------------------------------------------------------
  assign cdreq_way_0_hit  = ((mem[cdreq_idx][0][`VALID]) && (mem[cdreq_idx][0][`RAM_TAG] == cdreq_addr_bf[`ADDR_TAG]));
  assign cdreq_way_1_hit  = ((mem[cdreq_idx][1][`VALID]) && (mem[cdreq_idx][1][`RAM_TAG] == cdreq_addr_bf[`ADDR_TAG]));
  assign cdreq_way_2_hit  = ((mem[cdreq_idx][2][`VALID]) && (mem[cdreq_idx][2][`RAM_TAG] == cdreq_addr_bf[`ADDR_TAG]));
  assign cdreq_way_3_hit  = ((mem[cdreq_idx][3][`VALID]) && (mem[cdreq_idx][3][`RAM_TAG] == cdreq_addr_bf[`ADDR_TAG]));

  assign sureq_way_0_hit  = ((mem[sureq_idx][0][`VALID]) && (mem[sureq_idx][0][`RAM_TAG] == sureq_addr_bf[`ADDR_TAG]));
  assign sureq_way_1_hit  = ((mem[sureq_idx][1][`VALID]) && (mem[sureq_idx][1][`RAM_TAG] == sureq_addr_bf[`ADDR_TAG]));
  assign sureq_way_2_hit  = ((mem[sureq_idx][2][`VALID]) && (mem[sureq_idx][2][`RAM_TAG] == sureq_addr_bf[`ADDR_TAG]));
  assign sureq_way_3_hit  = ((mem[sureq_idx][3][`VALID]) && (mem[sureq_idx][3][`RAM_TAG] == sureq_addr_bf[`ADDR_TAG]));

  // ----------------------------------------------------------------
  // imp_blk: replacement policy
  // ----------------------------------------------------------------
  logic                 promote_ack;
  logic [IDX_WIDTH-1:0] promote_idx;
  logic [1:0]           promote_way;
  logic [1:0]           evict_way;

  always_comb begin
    //if(cac_hit && cursp_hs_compack) begin
    if(!cdreq_corner_ack && cac_hit && cursp_hs_compack) begin
      promote_ack = 1'b1;
      promote_idx = cdreq_idx;
      promote_way = cdreq_way;
    end
    //else if(snp_hit && sdrsp_hs_compack && (sureq_op_bf == SUREQ_RD)) begin
    else if(!sureq_corner_ack && snp_hit && sdrsp_hs_compack && (sureq_op_bf == SUREQ_RD)) begin
      promote_ack = 1'b1;
      promote_idx = sureq_idx;
      promote_way = sureq_way;
    end
    else begin
      promote_ack = 1'b0;
      promote_idx = {IDX_WIDTH{1'b0}};
      promote_way = 2'b00;
    end
  end

`ifdef PLRU_REPL
  logic [2:0] repl_tree [0:NUM_IDX-1];
  logic [2:0] tree_bit;

  assign tree_bit         = repl_tree[cdreq_idx];
  // promote could occurres when executes SUREQ
  // but determines evict way is only occures when executes CDREQ
  // --> only cdreq_idx is considered to determine evict_way

  assign evict_way[1]     = tree_bit[2];
  assign evict_way[0]     = tree_bit[2] ? tree_bit[0] : tree_bit[1];

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      for(int i=0; i < NUM_IDX; i++) begin
        repl_tree[i] <= 3'b000;
      end
    end
    else if(promote_ack) begin
      unique case(promote_way)
        2'b00:
              begin
                repl_tree[promote_idx][2] <= 1'b1;
                repl_tree[promote_idx][1] <= 1'b1;
              end
        2'b01:
              begin
                repl_tree[promote_idx][2] <= 1'b1;
                repl_tree[promote_idx][1] <= 1'b0;
              end
        2'b10:
              begin
                repl_tree[promote_idx][2] <= 1'b0;
                repl_tree[promote_idx][0] <= 1'b1;
              end
        2'b11:
              begin
                repl_tree[promote_idx][2] <= 1'b0;
                repl_tree[promote_idx][0] <= 1'b0;
              end
      endcase
    end
  end

`elsif THESIS_REPL
  localparam REPL_CNT_WIDTH = 2;
  localparam REPL_CNT_MAX   = (1<<REPL_CNT_WIDTH) - 1;
  localparam REPL_THRESHOLD = (1<<(REPL_CNT_WIDTH-1));

  logic [REPL_CNT_WIDTH-1:0] repl_tree [0:NUM_IDX-1][0:2];
  
  logic [REPL_CNT_WIDTH-1:0] repl_tree_n2;
  logic [REPL_CNT_WIDTH-1:0] repl_tree_n1;
  logic [REPL_CNT_WIDTH-1:0] repl_tree_n0;

  assign repl_tree_n2 = repl_tree[cdreq_idx][2];
  assign repl_tree_n1 = repl_tree[cdreq_idx][1];
  assign repl_tree_n0 = repl_tree[cdreq_idx][0];

  assign evict_way[1] = (repl_tree[cdreq_idx][2] >= REPL_THRESHOLD);
  assign evict_way[0] = (repl_tree[cdreq_idx][2] >= REPL_THRESHOLD) ? (repl_tree[cdreq_idx][0] >= REPL_THRESHOLD) : (repl_tree[cdreq_idx][1] >= REPL_THRESHOLD);

  //assign evict_way[1] = ((repl_tree[cdreq_idx][2] >= REPL_THRESHOLD) || (repl_tree[cdreq_idx][0] == REPL_CNT_MAX));
  //assign evict_way[0] = (repl_tree[cdreq_idx][2] >= REPL_THRESHOLD) ? (repl_tree[cdreq_idx][0] >= REPL_THRESHOLD) : (repl_tree[cdreq_idx][1] >= REPL_THRESHOLD);

  function automatic logic [REPL_CNT_WIDTH-1:0] incr1(input logic [REPL_CNT_WIDTH-1:0] var0);
    return (var0 == REPL_CNT_MAX) ? var0 : var0 + 1;
  endfunction

  function automatic logic [REPL_CNT_WIDTH-1:0] decr1(input logic [REPL_CNT_WIDTH-1:0] var0);
    return (var0 == 0) ? 0 : var0 - 1;
  endfunction

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      for(int i=0; i < NUM_IDX; i++) begin
        repl_tree[i][2] <= REPL_THRESHOLD;
        repl_tree[i][1] <= REPL_THRESHOLD;
        repl_tree[i][0] <= REPL_THRESHOLD;
      end
    end
    else if(promote_ack) begin
      unique case(promote_way)
        2'b00:
              begin
                repl_tree[promote_idx][2] <= incr1(repl_tree[promote_idx][2]);
                repl_tree[promote_idx][1] <= incr1(repl_tree[promote_idx][1]);
              end
        2'b01:
              begin
                repl_tree[promote_idx][2] <= incr1(repl_tree[promote_idx][2]);
                repl_tree[promote_idx][1] <= decr1(repl_tree[promote_idx][1]);
              end
        2'b10:
              begin
                repl_tree[promote_idx][2] <= decr1(repl_tree[promote_idx][2]);
                repl_tree[promote_idx][0] <= incr1(repl_tree[promote_idx][0]);
              end
        2'b11:
              begin
                repl_tree[promote_idx][2] <= decr1(repl_tree[promote_idx][2]);
                repl_tree[promote_idx][0] <= decr1(repl_tree[promote_idx][0]);
              end
      endcase // promote_way
    end
  end
`else
  $fatal("can not identify replacement policy");
`endif

  // ----------------------------------------------------------------
  // imp_blk: cache lookup
  // ----------------------------------------------------------------
  assign cdreq_idx        = cdreq_addr_bf[`IDX];
  assign sureq_idx        = sureq_addr_bf[`IDX];

  assign evict_blk_2_addr = {mem[cdreq_idx][cdreq_way][`RAM_TAG], cdreq_idx};

  assign cac_hit          = (cdreq_ot && (cdreq_way_3_hit || cdreq_way_2_hit || cdreq_way_1_hit || cdreq_way_0_hit));
  assign snp_hit          = (sureq_ot && (sureq_way_3_hit || sureq_way_2_hit || sureq_way_1_hit || sureq_way_0_hit));

  always_comb begin
    unique case({sureq_way_3_hit, sureq_way_2_hit, sureq_way_1_hit, sureq_way_0_hit})
      4'b0001: sureq_way = 2'b00;
      4'b0010: sureq_way = 2'b01;
      4'b0100: sureq_way = 2'b10;
      4'b1000: sureq_way = 2'b11;
      4'b0000: sureq_way = 2'b00;
    endcase
  end

  always_comb begin
    unique case({cdreq_way_3_hit, cdreq_way_2_hit, cdreq_way_1_hit, cdreq_way_0_hit})
      4'b0001: cdreq_hit_way = 2'b00;
      4'b0010: cdreq_hit_way = 2'b01;
      4'b0100: cdreq_hit_way = 2'b10;
      4'b1000: cdreq_hit_way = 2'b11;
      4'b0000: cdreq_hit_way = 2'b00;
    endcase
  end

  assign fill_inv_blk     = !(mem[cdreq_idx][3][`VALID] && mem[cdreq_idx][2][`VALID] && mem[cdreq_idx][1][`VALID] && mem[cdreq_idx][0][`VALID]);
  
  assign cdreq_inv_way    = (!mem[cdreq_idx][0][`VALID]) ? 2'b00 :
                            (!mem[cdreq_idx][1][`VALID]) ? 2'b01 :
                            (!mem[cdreq_idx][2][`VALID]) ? 2'b10 :
                            (!mem[cdreq_idx][3][`VALID]) ? 2'b11 : 2'b00;

  assign evict_ack        = cdreq_ot && !(cac_hit || fill_inv_blk);

  assign cdreq_way        = (cac_hit)       ? cdreq_hit_way :
                            (fill_inv_blk)  ? cdreq_inv_way : evict_way;

  assign cdreq_blk_curSt  = mem[cdreq_idx][cdreq_way][`ST];
  assign sureq_blk_curSt  = mem[sureq_idx][sureq_way][`ST];

  assign cac_wr           = ( cdreq_ot &&
                              ((cdreq_op_bf == CDREQ_MD) || (cdreq_op_bf == CDREQ_WB) || (cdreq_op_bf == CDREQ_RFO))
                            );

  assign cac_rd           = ( cdreq_ot &&
                              (cdreq_op_bf == CDREQ_RD)
                            );

  assign wr_hit           = cac_wr && cac_hit;
  assign rd_hit           = cac_rd && cac_hit;
  assign wr_miss          = cac_wr && !cac_hit;
  assign rd_miss          = cac_rd && !cac_hit;

  assign cache_lookup     = {wr_miss, rd_miss, wr_hit, rd_hit};

  // ----------------------------------------------------------------
  // imp_blk: common CDERQ SUREQ controller
  // ----------------------------------------------------------------
  // FIXME: assume that SUREQ accessed block is always present in L1
  assign blk_valid_in_l1      = 1'b1;

  assign cdreq_init_sdreq_inv = ( ((cdreq_op_bf == CDREQ_RFO) || (cdreq_op_bf == CDREQ_MD)) &&
                                  (cdreq_blk_curSt == SHARED) &&
                                  !evict_ack
                                );

  assign sureq_init_cureq_inv = ( ((sureq_op_bf == SUREQ_RFO) || (sureq_op_bf == SUREQ_INV)) &&
                                  (sureq_blk_curSt != MIGRATED) &&
                                  snp_hit &&
                                  blk_valid_in_l1
                                );

  assign sureq_init_cureq_rfo = ( (sureq_op_bf == SUREQ_RFO) &&
                                  (sureq_blk_curSt == MIGRATED) &&
                                  snp_hit &&
                                  blk_valid_in_l1
                                );
  // ----------------------------------------------------------------
  // imp_blk: CDERQ phase controller
  // ----------------------------------------------------------------
  logic cdreq_init_sdreq;
  logic evict_init_wb_inv;
  logic evict_retrive;
  logic evict_init_sdreq_wb;
  logic evict_init_sdreq_inv;

  assign cdreq_init_sdreq     = !cac_hit || cdreq_init_sdreq_inv;

  assign evict_init_sdreq_wb  = (cdreq_blk_curSt == MIGRATED) || (cdreq_blk_curSt == MODIFIED);

  assign evict_init_sdreq_inv = ((cdreq_blk_curSt == SHARED) && (cdreq_op_bf == CDREQ_RFO));

  assign evict_init_wb_inv    = evict_init_sdreq_wb || evict_init_sdreq_inv;

  assign evict_retrive  = 1'b0;

  always_comb begin
    if(!rst_n)
      cdreq_req_nxtSt = CDREQ_IDLE;
    else begin
      case(cdreq_req_curSt)
        CDREQ_IDLE:             cdreq_req_nxtSt = (cdreq_hs_en          ) ? CDREQ_ALLOCATE        : CDREQ_IDLE; 
        CDREQ_ALLOCATE:         cdreq_req_nxtSt = (cdreq_corner_triger  ) ? CDREQ_SEND_RSP        :
                                                  (evict_ack            ) ? CDREQ_INIT_CUREQ      :
                                                  (cdreq_init_sdreq     ) ? CDREQ_INIT_SDREQ      : CDREQ_SEND_RSP;
        CDREQ_INIT_CUREQ:       cdreq_req_nxtSt = (cureq_hs_compack     ) ? CDREQ_WAIT_CDRSP      : CDREQ_INIT_CUREQ; 
        CDREQ_WAIT_CDRSP:       cdreq_req_nxtSt = (cdrsp_hs_en          ) ? ((evict_init_wb_inv ) ? CDREQ_EVICT_ACK : CDREQ_INIT_SDREQ) : CDREQ_WAIT_CDRSP; 
        CDREQ_EVICT_ACK:        cdreq_req_nxtSt = (sdreq_hs_compack     ) ? CDREQ_WAIT_EVICT_COMP : CDREQ_EVICT_ACK;
        CDREQ_WAIT_EVICT_COMP:  cdreq_req_nxtSt = (sursp_hs_en          ) ? CDREQ_INIT_SDREQ      : CDREQ_WAIT_EVICT_COMP;
        CDREQ_INIT_SDREQ:       cdreq_req_nxtSt = (sdreq_hs_compack     ) ? CDREQ_WAIT_SURSP      : CDREQ_INIT_SDREQ;
        CDREQ_WAIT_SURSP:       cdreq_req_nxtSt = (sursp_hs_en          ) ? CDREQ_SEND_RSP        : CDREQ_WAIT_SURSP;
        CDREQ_SEND_RSP:         cdreq_req_nxtSt = (cursp_hs_compack     ) ? CDREQ_IDLE            : CDREQ_SEND_RSP;
        default:                cdreq_req_nxtSt = CDREQ_IDLE;
      endcase // cdreq_req_curSt
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
      cdreq_req_curSt <= CDREQ_IDLE;
    else
      cdreq_req_curSt <= cdreq_req_nxtSt;
  end

  // ----------------------------------------------------------------
  // imp_blk: SUREQ phase controller
  // ----------------------------------------------------------------
  logic sureq_init_cureq;
  logic sureq_init_wb;
  logic sureq_init_wb_after_cureq;

  assign sureq_init_cureq           =   ( sureq_init_cureq_inv ||
                                          (snp_hit && (sureq_blk_curSt == MIGRATED))
                                        );
  
  assign sureq_init_wb              =   ( snp_hit &&
                                          (sureq_blk_curSt == MODIFIED)
                                        );

  //assign sureq_init_wb_after_cureq  =   ( (sureq_blk_curSt == MODIFIED) ||
  //                                        (sureq_blk_curSt == MIGRATED)
  //                                      );
  assign sureq_init_wb_after_cureq  =   ( sureq_ot &&
                                          ((sureq_blk_curSt == MODIFIED) || (sureq_blk_curSt == MIGRATED))
                                        );

  always_comb begin
    if(!rst_n)
      sureq_req_nxtSt = SUREQ_IDLE;
    else begin
      case(sureq_req_curSt)
        SUREQ_IDLE:       sureq_req_nxtSt = (sureq_hs_en          ) ? SUREQ_ALLOCATE    : SUREQ_IDLE;
        SUREQ_ALLOCATE:   sureq_req_nxtSt = (sureq_corner_triger  ) ? SUREQ_SEND_RSP    :
                                            (sureq_init_cureq     ) ? SUREQ_INIT_CUREQ  :
                                            (sureq_init_wb        ) ? SUREQ_INIT_SDREQ  : SUREQ_SEND_RSP;
        SUREQ_INIT_CUREQ: sureq_req_nxtSt = (cureq_hs_compack     ) ? SUREQ_WAIT_CDRSP  : SUREQ_INIT_CUREQ;
        SUREQ_WAIT_CDRSP: sureq_req_nxtSt = (cdrsp_hs_en          ) ? ((sureq_init_wb_after_cureq) ? SUREQ_INIT_SDREQ : SUREQ_SEND_RSP) : SUREQ_WAIT_CDRSP;
        SUREQ_INIT_SDREQ: sureq_req_nxtSt = (sdreq_hs_compack     ) ? SUREQ_WAIT_SURSP  : SUREQ_INIT_SDREQ;
        SUREQ_WAIT_SURSP: sureq_req_nxtSt = (sursp_hs_en          ) ? SUREQ_SEND_RSP    : SUREQ_WAIT_SURSP;
        SUREQ_SEND_RSP:   sureq_req_nxtSt = (sdrsp_hs_compack     ) ? SUREQ_IDLE        : SUREQ_SEND_RSP;
        default:          sureq_req_nxtSt = SUREQ_IDLE;
      endcase // sureq_req_curSt
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
      sureq_req_curSt <= SUREQ_IDLE;
    else
      sureq_req_curSt <= sureq_req_nxtSt;
  end

  //-----------------------------------------------------------------
  // imp_blk: cdreq init sdreq
  //-----------------------------------------------------------------
  always_comb begin
    cdreq_2_sdreq = SDREQ_RD;
    case(1'b1)
      cache_lookup[READ_HIT]:   cdreq_2_sdreq = SDREQ_RD;
      cache_lookup[WRITE_HIT]:  cdreq_2_sdreq = (cdreq_blk_curSt == SHARED) ? SDREQ_INV : SDREQ_RD;
      cache_lookup[READ_MISS]:  cdreq_2_sdreq = SDREQ_RD;
      cache_lookup[WRITE_MISS]: cdreq_2_sdreq = SDREQ_RFO;
      default: ;
    endcase // cache_lookup
  end

  //-----------------------------------------------------------------
  // imp_blk: sureq init sdreq
  //-----------------------------------------------------------------
  assign sureq_2_sdreq =  ( (sureq_blk_curSt == MODIFIED) ||
                            (sureq_blk_curSt == MIGRATED)
                          ) ? SDREQ_WB : SDREQ_RD;

  // ----------------------------------------------------------------
  // imp_blk: channel payload control
  // ----------------------------------------------------------------
  // CUREQ channel control
  //assign cureq_op   = (sureq_req_curSt == SUREQ_INIT_CUREQ) ? ( ((sureq_op_bf == SUREQ_RFO ) && (sureq_blk_curSt == MIGRATED) ) ? CUREQ_RFO :
  assign cureq_op   = (sureq_req_curSt == SUREQ_INIT_CUREQ) ? ( (sureq_init_cureq_rfo ) ? CUREQ_RFO :
                                                              ( sureq_init_cureq_inv  ) ? CUREQ_INV : CUREQ_RD) :
                      (cdreq_req_curSt == CDREQ_INIT_CUREQ) ? ( (cdreq_blk_curSt == MIGRATED) ? CUREQ_RFO : CUREQ_INV ) : CUREQ_RD;

  assign cureq_addr = (sureq_req_curSt == SUREQ_INIT_CUREQ) ? sureq_addr_bf     :
                      (cdreq_req_curSt == CDREQ_INIT_CUREQ) ? evict_blk_2_addr  : {SADDR_WIDTH{1'b0}};

  // CURSP channel control
  // FIXME: cursp_rsp is fixed at OKAY
  assign cursp_rsp  = cdreq_corner_ack ? CURSP_ERROR : CURSP_OKAY;

  assign cursp_data = ( cdreq_ot &&
                        !cdreq_corner_ack &&
                        ((cdreq_op_bf == CDREQ_RD) || (cdreq_op_bf == CDREQ_RFO))
                      ) ? mem[cdreq_idx][cdreq_way][`DAT] : {BLK_WIDTH{1'b0}};

  // SDREQ channel control
  assign sdreq_op   = (cdreq_req_curSt == CDREQ_EVICT_ACK ) ? (evict_init_sdreq_inv ? SDREQ_INV : SDREQ_WB) :
                      (cdreq_req_curSt == CDREQ_INIT_SDREQ) ? cdreq_2_sdreq :
                      (sureq_req_curSt == SUREQ_INIT_SDREQ) ? sureq_2_sdreq : SDREQ_RD;

  assign sdreq_addr = (cdreq_req_curSt == CDREQ_INIT_SDREQ) ? cdreq_addr_bf     :
                      (cdreq_req_curSt == CDREQ_EVICT_ACK ) ? evict_blk_2_addr  :
                      (sureq_req_curSt == SUREQ_INIT_SDREQ) ? sureq_addr_bf     : {SADDR_WIDTH{1'b0}};
  //assign sdreq_addr = ((cdreq_req_curSt == CDREQ_INIT_SDREQ) || (cdreq_req_curSt == CDREQ_EVICT_ACK) ) ? (evict_ack ? evict_blk_2_addr : cdreq_addr_bf)  :
  //                    (sureq_req_curSt == SUREQ_INIT_SDREQ                                            ) ? sureq_addr_bf                                   : {SADDR_WIDTH{1'b0}};

  assign sdreq_data = (sdreq_op == SDREQ_WB) ? ((evict_ack) ? mem[cdreq_idx][cdreq_way][`DAT] : mem[sureq_idx][sureq_way][`DAT]) : {BLK_WIDTH{1'b0}};

  // SDRSP channel control
  assign sdrsp_rsp  = (sureq_corner_ack) ? SDRSP_ERROR : (snp_hit) ? SDRSP_OKAY : SDRSP_INV;

  assign sdrsp_data = ( snp_hit &&
                        ((sureq_op_bf == SUREQ_RD) || (sureq_op_bf == SUREQ_RFO))
                      ) ? mem[sureq_idx][sureq_way][`DAT] : {BLK_WIDTH{1'b0}};

  //-----------------------------------------------------------------
  // imp_blk: CDREQ affects on cache state transition
  //-----------------------------------------------------------------
  always_comb begin
    cdreq_blk_nxtSt = INVALID;
    case(1'b1)
      cache_lookup[READ_HIT]:   cdreq_blk_nxtSt = cdreq_blk_curSt;
      cache_lookup[WRITE_HIT]:  cdreq_blk_nxtSt = (cdreq_req_curSt == CDREQ_SEND_RSP) ? ((cdreq_op_bf == CDREQ_WB) ? MODIFIED : MIGRATED) : cdreq_blk_curSt;
      cache_lookup[READ_MISS]:
            begin
              if(cdreq_req_curSt == CDREQ_SEND_RSP) begin
                case(sursp_rsp)
                  SURSP_SNOOP:  cdreq_blk_nxtSt = SHARED;
                  SURSP_FETCH:  cdreq_blk_nxtSt = EXCLUSIVE;
                  default:      cdreq_blk_nxtSt = INVALID;
                endcase // sursp_rsp
              end
              else              cdreq_blk_nxtSt = INVALID;
            end
      cache_lookup[WRITE_MISS]: cdreq_blk_nxtSt = (cdreq_req_curSt == CDREQ_SEND_RSP) ? MIGRATED : INVALID;
      // WRITE_MISS only occurred when RFO to INVALID, if CDREQ is MD or WB, then state has to VALID
      default: ;
    endcase // cache_lookup
  end

  //-----------------------------------------------------------------
  // imp_blk: SUREQ affects on cache state transition
  //-----------------------------------------------------------------
  always_comb begin
    //if(sureq_blk_curSt != INVALID) begin
    if(snp_hit) begin
      case(sureq_op_bf)
        SUREQ_RD:   sureq_blk_nxtSt = SHARED;
        SUREQ_RFO:  sureq_blk_nxtSt = INVALID;
        SUREQ_INV:  sureq_blk_nxtSt = INVALID;
        default:    sureq_blk_nxtSt = sureq_blk_curSt;
      endcase // sureq_blk_curSt
    end
    else            sureq_blk_nxtSt = sureq_blk_curSt;
  end

  // ----------------------------------------------------------------
  // imp_blk: update block state
  // ----------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      for(int i = 0; i < (NUM_BLK/NUM_WAY); i++) begin
        for(int ii = 0; ii < NUM_WAY; ii++) begin
          mem[i][ii][`ST] <= INVALID;
        end
      end
    end
    else begin
      if((cdreq_req_curSt == CDREQ_SEND_RSP) && !cdreq_corner_ack)
        mem[cdreq_idx][cdreq_way][`ST] <= cdreq_blk_nxtSt;
      if(sdrsp_hs_compack && !sureq_corner_ack)
        // avoid assign state <-- INVALID while wait sursp_ready asserted (in SUREQ_RFO)
        // if state <-- INVALID then sdrsp_data <-- 0x0)
        mem[sureq_idx][sureq_way][`ST] <= sureq_blk_nxtSt;
    end
    //else if(!cdreq_corner_ack) begin
    //  if(cdreq_req_curSt == CDREQ_SEND_RSP)
    //    mem[cdreq_idx][cdreq_way][`ST] <= cdreq_blk_nxtSt;
    //  else if(sdrsp_hs_compack)
    //    // avoid assign state <-- INVALID while wait sursp_ready asserted (in SUREQ_RFO)
    //    // if state <-- INVALID then sdrsp_data <-- 0x0)
    //    mem[sureq_idx][sureq_way][`ST] <= sureq_blk_nxtSt;
    //end
  end

  // ----------------------------------------------------------------
  // imp_blk: update Tag
  // ----------------------------------------------------------------
  logic asg_tag_trigger;

  assign asg_tag_trigger = ((cdreq_req_curSt == CDREQ_SEND_RSP) && !cac_hit);
  // assign tag only before blk assigned because when state <-- VALID, then cdreq_addr_bf <-- 0x0

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      for(int i = 0; i < (NUM_BLK/NUM_WAY); i++) begin
        for(int ii = 0; ii < NUM_WAY; ii++) begin
          mem[i][ii][`RAM_TAG] <= {TAG_WIDTH{1'b0}};
        end
      end
    end
    else if(!cdreq_corner_ack) begin
      if(asg_tag_trigger) begin
        mem[cdreq_idx][cdreq_way][`RAM_TAG] <= cdreq_addr_bf[`ADDR_TAG];
      end
    end
  end

  // ----------------------------------------------------------------
  // imp_blk: update data
  // ----------------------------------------------------------------
  logic asgData_in_cdreq_ack;
  logic asgData_in_sursp_ack;
  logic asgData_in_cdrsp_ack;

  //assign asgData_in_cdreq =  (cdreq_op_bf == CDREQ_WB);
  assign asgData_in_cdreq_ack = ( (cdreq_op_bf == CDREQ_WB) &&
                                  (cdreq_req_curSt == CDREQ_ALLOCATE) &&
                                  !cdreq_corner_triger
                                );

  assign asgData_in_sursp_ack = ( ((cdreq_op_bf == CDREQ_RFO) || (cdreq_op_bf == CDREQ_RD)) &&
                                  !cdreq_init_sdreq_inv &&
                                  !sureq_init_wb &&
                                  !sureq_init_wb_after_cureq &&
                                  sursp_hs_en
                                );

  assign asgData_in_cdrsp_ack = ( ((sureq_blk_curSt == MIGRATED) || (cdreq_blk_curSt == MIGRATED)) &&
                                  cdrsp_hs_en
                                );

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      for(int i = 0; i < (NUM_BLK/NUM_WAY); i++) begin
        for(int ii = 0; ii < NUM_WAY; ii++) begin
          mem[i][ii][`DAT] <= {BLK_WIDTH{1'b0}};
        end
      end
    end
    else if(!cdreq_corner_ack) begin
      if      (asgData_in_cdreq_ack)   mem[cdreq_idx][cdreq_way][`DAT] <= cdreq_data_bf;
      else if (asgData_in_sursp_ack)   mem[cdreq_idx][cdreq_way][`DAT] <= sursp_data;
      else if (asgData_in_cdrsp_ack) begin
        if      (cdreq_req_curSt == CDREQ_WAIT_CDRSP) mem[cdreq_idx][cdreq_way][`DAT] <= cdrsp_data;
        else if (sureq_req_curSt == SUREQ_WAIT_CDRSP) mem[sureq_idx][sureq_way][`DAT] <= cdrsp_data;
      end
    end
  end
endmodule // cache_mem

`endif
