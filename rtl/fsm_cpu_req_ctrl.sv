`ifndef FSM_CPU_REQ_CTRL_SV
`define FSM_CPU_REQ_CTRL_SV

`include "cache_rtl_def.sv"

module fsm_cpu_req_ctrl (
      input   logic [2:0]   cur_state,
      input   logic         cpu_wr_hit,
      input   logic         cpu_rd_hit,
      input   logic         cpu_wr_miss,
      input   logic         cpu_rd_miss,
      input   logic [1:0]   bus_rsp,

      output  logic [2:0]   nxt_state,
      output  logic         cpu_wait,
      output  logic         write_back,
      output  logic [1:0]   send_bus_req
);

  localparam  READ_HIT    = 0,
              WRITE_HIT   = 1,
              READ_MISS   = 2,
              WRITE_MISS  = 3;

  logic [3:0] rd_wr_hit_miss = {cpu_wr_miss, cpu_rd_miss, cpu_wr_hit, cpu_rd_hit};

  //-----------------------------------------------------------------
  assign write_back = ((cur_state == `MODIFIED)
                      && (cpu_wr_miss || cpu_rd_miss)) ?
                      1'b1 : 1'b0;

  //-----------------------------------------------------------------
  assign cpu_wait = ((cpu_wr_hit || cpu_rd_hit)
                    && (bus_rsp == `BUS_NO_RSP)) ?
                    1'b1 : 1'b0;

  //-----------------------------------------------------------------
  always_comb begin
    send_bus_req  = `BUS_NO_REQ;
    nxt_state     = `INVALID;

    case(1'b1)
      rd_wr_hit_miss[READ_HIT]:
            begin
              case(cur_state)
                `EXCLUSIVE:
                      begin
                        send_bus_req  = `BUS_NO_REQ;
                        nxt_state     = `EXCLUSIVE;
                      end
                `MODIFIED:
                      begin
                        send_bus_req  = `BUS_NO_REQ;
                        nxt_state     = `MODIFIED;
                      end
                `SHARED:
                      begin
                        send_bus_req  = `BUS_NO_REQ;
                        nxt_state     = `SHARED;
                      end
                default: ;
              endcase // cur_state
            end
      rd_wr_hit_miss[WRITE_HIT]:
            begin
              case(cur_state)
                `EXCLUSIVE:
                      begin
                        send_bus_req  = `BUS_NO_REQ;
                        nxt_state     = `MODIFIED;
                      end
                `MODIFIED:
                      begin
                        send_bus_req  = `BUS_NO_REQ;
                        nxt_state     = `MODIFIED;
                      end
                `SHARED:
                      begin
                        send_bus_req  = `BUS_INVALIDATE_REQ;
                        nxt_state     = `MODIFIED;
                      end
                default: ;
              endcase // cur_state
            end
      rd_wr_hit_miss[READ_MISS]:
            begin
              case(bus_rsp)
                `BUS_NO_RSP:
                      begin
                        send_bus_req  = `BUS_READ_REQ;
                        nxt_state     = `INVALID;
                      end
                `BUS_SNOOP_FOUND_RSP:
                      begin
                        send_bus_req  = `BUS_NO_REQ;
                        nxt_state     = `SHARED;
                      end
                `BUS_FETCH_MEM_RSP:
                      begin
                        send_bus_req  = `BUS_NO_REQ;
                        nxt_state     = `EXCLUSIVE;
                      end
                default: ;
              endcase // bus_rsp
            end
      rd_wr_hit_miss[WRITE_MISS]:
            begin
              case(bus_rsp)
                `BUS_NO_RSP:
                      begin
                        send_bus_req  = `BUS_RWITM_REQ;
                        nxt_state     = `INVALID;
                      end
                `BUS_SNOOP_FOUND_RSP, `BUS_FETCH_MEM_RSP:
                      begin
                        send_bus_req  = `BUS_NO_REQ;
                        nxt_state     = `MODIFIED;
                      end
                default: ;
              endcase // bus_rsp
            end
    endcase // rd_wr_hit_miss
  end
endmodule // fsm_cpu_req_ctrl

`endif
