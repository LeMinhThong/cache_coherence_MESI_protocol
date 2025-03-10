`ifndef FSM_CPU_REQ_CTRL_V
`define FSM_CPU_REQ_CTRL_V

`include "cache_def.v"

module fsm_cpu_req_ctrl (
      input       [3:0]   cur_state,
      input               cpu_wr_hit,
      input               cpu_rd_hit,
      input               cpu_wr_miss,
      input               cpu_rd_miss,
      input       [1:0]   bus_rsp,

      output  reg [3:0]   nxt_state,
      output  reg         cpu_wait,
      output  reg         write_back,
      output  reg [1:0]   send_bus_req
);

  wire [3:0] cache_hit_miss;

  assign cache_hit_miss = {cpu_wr_miss, cpu_rd_miss, cpu_wr_hit, cpu_rd_hit};

  always @(*)
  begin
    cpu_wait      = 1'b0;
    send_bus_req  = `BUS_NO_REQ;
    write_back    = 1'b0;
    nxt_state     = `INVALID;

    case(cur_state)
      `INVALID:
            begin
              case (cache_hit_miss)
                `READ_MISS:
                      begin
                        case(bus_rsp)
                          `BUS_NO_RSP:
                                begin
                                  cpu_wait      = 1'b1;
                                  send_bus_req  = `BUS_READ_REQ;
                                  write_back    = 1'b0;
                                  nxt_state     = `INVALID;
                                end
                          `BUS_SNOOP_FOUND_RSP:
                                begin
                                  cpu_wait      = 1'b0;
                                  send_bus_req  = `BUS_NO_REQ;
                                  write_back    = 1'b0;
                                  nxt_state     = `SHARED;
                                end
                          `BUS_FETCH_MEM_RSP:
                                begin
                                  cpu_wait      = 1'b0;
                                  send_bus_req  = `BUS_NO_REQ;
                                  write_back    = 1'b0;
                                  nxt_state     = `EXCLUSIVE;
                                end
                          default: ;
                        endcase // bus_rsp
                      end
                `WRITE_MISS:
                      begin
                        case(bus_rsp)
                          `BUS_NO_RSP:
                                begin
                                  cpu_wait      = 1'b1;
                                  send_bus_req  = `BUS_RWITM_REQ;
                                  write_back    = 1'b0;
                                  nxt_state     = `INVALID;
                                end
                          `BUS_SNOOP_FOUND_RSP, `BUS_FETCH_MEM_RSP:
                                begin
                                  cpu_wait      = 1'b0;
                                  send_bus_req  = `BUS_NO_REQ;
                                  write_back    = 1'b0;
                                  nxt_state     = `MODIFIED;
                                end
                          default: ;
                        endcase // bus_rsp
                      end
                default: ;
              endcase // cache_hit_miss
            end
      `EXCLUSIVE:
            begin
              case (cache_hit_miss)
                `READ_HIT:
                      begin
                        cpu_wait      = 1'b0;
                        send_bus_req  = `BUS_NO_REQ;
                        write_back    = 1'b0;
                        nxt_state     = `EXCLUSIVE;
                      end
                `WRITE_HIT:
                      begin
                        cpu_wait      = 1'b0;
                        send_bus_req  = `BUS_NO_REQ;
                        write_back    = 1'b0;
                        nxt_state     = `MODIFIED;
                      end
                `READ_MISS, `WRITE_MISS:
                      begin
                        cpu_wait      = 1'b1;
                        send_bus_req  = `BUS_READ_REQ;
                        write_back    = 1'b0;
                        nxt_state     = `INVALID;
                      end
                default: ;
              endcase // cache_hit_miss
            end
      `MODIFIED:
            begin
              case (cache_hit_miss)
                `READ_HIT, `WRITE_HIT:
                      begin
                        cpu_wait      = 1'b0;
                        send_bus_req  = `BUS_NO_REQ;
                        write_back    = 1'b0;
                        nxt_state     = `MODIFIED;
                      end
                `READ_MISS, `WRITE_MISS:
                      begin
                        cpu_wait      = 1'b1;
                        send_bus_req  = `BUS_READ_REQ;
                        write_back    = 1'b1;
                        nxt_state     = `INVALID;
                      end
                default: ;
              endcase // cache_hit_miss
            end
      `SHARED:
            begin
              case (cache_hit_miss)
                `READ_HIT:
                      begin
                        cpu_wait      = 1'b0;
                        send_bus_req  = `BUS_NO_REQ;
                        write_back    = 1'b0;
                        nxt_state     = `SHARED;
                      end
                `WRITE_HIT:
                      begin
                        cpu_wait      = 1'b0;
                        send_bus_req  = `BUS_INVALIDATE_REQ;
                        write_back    = 1'b0;
                        nxt_state     = `MODIFIED;
                      end
                `READ_MISS:
                      begin
                        cpu_wait      = 1'b1;
                        send_bus_req  = `BUS_READ_REQ;
                        write_back    = 1'b0;
                        nxt_state     = `INVALID;
                      end
                `WRITE_MISS:
                      begin
                        cpu_wait      = 1'b1;
                        send_bus_req  = `BUS_RWITM_REQ;
                        write_back    = 1'b0;
                        nxt_state     = `INVALID;
                      end
                default: ;
              endcase // cache_hit_miss
            end
      default: ;
    endcase // cur_state
  end
endmodule

`endif
