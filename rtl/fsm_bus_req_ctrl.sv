`ifndef FSM_BUS_REQ_CTRL_SV
`define FSM_BUS_REQ_CTRL_SV

`include "cache_rtl_def.sv"

module fsm_bus_req_ctrl (
      input   logic [2:0] cur_state,
      input   logic [1:0] bus_req,

      output  logic [2:0] nxt_state,
      output  logic       write_back,
      output  logic [1:0] send_bus_rsp
);

  //-----------------------------------------------------------------
  assign write_back = ((cur_state == `MODIFIED)
                      && ((bus_req == `BUS_READ_REQ) || (bus_req == `BUS_RWITM_REQ))) ?
                      1'b1 : 1'b0;

  //-----------------------------------------------------------------
  assign send_bus_rsp = ((cur_state[0] == 1'b1)
                        && ((bus_req == `BUS_READ_REQ) || (bus_req == `BUS_RWITM_REQ))) ?
                        `BUS_SNOOP_FOUND_RSP : `BUS_NO_RSP;

  //-----------------------------------------------------------------
  always_comb begin
    nxt_state     = `INVALID;

    case(bus_req)
      `BUS_NO_REQ:          nxt_state = cur_state;
      `BUS_READ_REQ:        nxt_state = `SHARED;
      `BUS_INVALIDATE_REQ:  nxt_state = `INVALID;
      `BUS_RWITM_REQ:       nxt_state = `INVALID;
    endcase // cur_state
  end
endmodule

`endif
