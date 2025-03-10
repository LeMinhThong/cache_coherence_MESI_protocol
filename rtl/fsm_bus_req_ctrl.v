`ifndef FSM_BUS_REQ_CTRL_V
`define FSM_BUS_REQ_CTRL_V

`include "cache_def.v"

module fsm_bus_req_ctrl (
      input       [3:0] cur_state,
      input       [1:0] bus_req,

      output  reg [3:0] nxt_state,
      output  reg       write_back,
      output  reg [1:0] send_bus_rsp
);
  always @(*)
  begin
    nxt_state     = `INVALID;
    write_back    = 1'b0;
    send_bus_rsp  = `BUS_NO_RSP;
    case(cur_state)
      //`VALID:
      // Bus request 
      `EXCLUSIVE:
            begin
              case(bus_req)
                `BUS_NO_REQ:
                      begin
                        nxt_state     = `EXCLUSIVE;
                        write_back    = 1'b0;
                        send_bus_rsp  = `BUS_NO_RSP;
                      end
                //`BUS_INVALIDATE_REQ:
                // only when the Processor performs a write that hits a SHARED cache line,
                // then BUS_INVALIDATE_REQ is generated to all remaining caches,
                // EXCLUSIVE state indicates cache line is presented only in this cache.
                `BUS_READ_REQ:
                      begin
                        nxt_state     = `SHARED;
                        write_back    = 1'b0;
                        send_bus_rsp  = `BUS_SNOOP_FOUND_RSP;
                      end
                `BUS_RWITM_REQ:
                      begin
                        nxt_state     = `INVALID;
                        write_back    = 1'b0;
                        send_bus_rsp  = `BUS_SNOOP_FOUND_RSP;
                      end
                default: ;
              endcase // bus_req
            end
      `MODIFIED:
            begin
              case(bus_req)
                `BUS_NO_REQ:
                      begin
                        nxt_state     = `MODIFIED;
                        write_back    = 1'b0;
                        send_bus_rsp  = `BUS_NO_RSP;
                      end
                //`BUS_INVALIDATE_REQ:
                // only when the Processor performs a write that hits a SHARED cache line,
                // then BUS_INVALIDATE_REQ is generated to all remaining caches,
                // MODIFIED state indicates cache line is presented only in this cache.
                `BUS_READ_REQ:
                      begin
                        nxt_state     = `SHARED;
                        write_back    = 1'b1;
                        send_bus_rsp  = `BUS_SNOOP_FOUND_RSP;
                      end
                `BUS_RWITM_REQ:
                      begin
                        nxt_state     = `INVALID;
                        write_back    = 1'b1;
                        send_bus_rsp  = `BUS_SNOOP_FOUND_RSP;
                      end
                default: ;
              endcase // bus_req
            end
      `SHARED:
            begin
              case(bus_req)
                `BUS_NO_REQ, `BUS_READ_REQ:
                      begin
                        nxt_state     = `SHARED;
                        write_back    = 1'b0;
                        send_bus_rsp  = `BUS_NO_RSP;
                      end
                `BUS_INVALIDATE_REQ:
                      begin
                        nxt_state     = `INVALID;
                        write_back    = 1'b0;
                        send_bus_rsp  = `BUS_NO_RSP;
                      end
                `BUS_RWITM_REQ:
                      begin
                        nxt_state     = `INVALID;
                        write_back    = 1'b0;
                        send_bus_rsp  = `BUS_SNOOP_FOUND_RSP;
                      end
                default: ;
              endcase // bus_req
            end
      default: ;
    endcase // cur_state
  end
endmodule

`endif
