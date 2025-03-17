`ifndef CACHE_MEM_TB_TOP_SV
`define CACHE_MEM_TB_TOP_SV

module cache_mem_tb_top;

  import uvm_pkg::*;
  import cache_test_pkg::*;
  `include "uvm_macros.svh";
  
  `include "cache_vip_def.svh";
  //`include "cache_if.sv"

  // ----------------------------------------------------------------
  localparam LINE_WIDTH     = 512; // 64*8
  localparam NUM_CACHE_LINE = 1024;
  localparam ADDR_WIDTH     = 32;
  localparam DATA_WIDTH     = 32;

  logic                   clk;
  logic                   rst_n;

  wire                    cpu2cac_rd;
  wire                    cpu2cac_wr;
  wire [ADDR_WIDTH-1:0]   cpu2cac_addr;
  wire [DATA_WIDTH-1:0]   cpu2cac_data;

  wire                    cac2cpu_wait;
  wire [DATA_WIDTH-1:0]   cac2cpu_data;

  wire [1:0]              bus2cac_bus_req;
  wire [1:0]              bus2cac_bus_rsp;
  wire [ADDR_WIDTH-$clog2(LINE_WIDTH/8)-1:0]  bus2cac_addr;
  wire [LINE_WIDTH-1:0]   bus2cac_data;

  wire [1:0]              cac2bus_bus_req;
  wire [1:0]              cac2bus_bus_rsp;
  wire [ADDR_WIDTH-$clog2(LINE_WIDTH/8)-1:0]  cac2bus_addr;
  wire [LINE_WIDTH-1:0]   cac2bus_data;

  wire                    cac2bus_write_back;
  
  // ----------------------------------------------------------------
  cache_if cac_if (
        .clk                (clk                ),
        .rst_n              (rst_n              ),

        .cpu2cac_rd         (cpu2cac_rd         ),
        .cpu2cac_wr         (cpu2cac_wr         ),
        .cpu2cac_addr       (cpu2cac_addr       ),
        .cpu2cac_data       (cpu2cac_data       ),

        .cac2cpu_wait       (cac2cpu_wait       ),
        .cac2cpu_data       (cac2cpu_data       ),

        .bus2cac_bus_req    (bus2cac_bus_req    ),
        .bus2cac_bus_rsp    (bus2cac_bus_rsp    ),
        .bus2cac_addr       (bus2cac_addr       ),
        .bus2cac_data       (bus2cac_data       ),

        .cac2bus_bus_req    (cac2bus_bus_req    ),
        .cac2bus_bus_rsp    (cac2bus_bus_rsp    ),
        .cac2bus_addr       (cac2bus_addr       ),
        .cac2bus_data       (cac2bus_data       ),
        .cac2bus_write_back (cac2bus_write_back )
  );

  // ----------------------------------------------------------------
  cache_mem #(
        .LINE_WIDTH     (LINE_WIDTH),
        .NUM_CACHE_LINE (NUM_CACHE_LINE),
        .ADDR_WIDTH     (ADDR_WIDTH),
        .DATA_WIDTH     (DATA_WIDTH)
  ) dut (
        .clk                (clk                ),
        .rst_n              (rst_n              ),

        .cpu2cac_rd         (cpu2cac_rd         ),
        .cpu2cac_wr         (cpu2cac_wr         ),
        .cpu2cac_addr       (cpu2cac_addr       ),
        .cpu2cac_data       (cpu2cac_data       ),

        .cac2cpu_wait       (cac2cpu_wait       ),
        .cac2cpu_data       (cac2cpu_data       ),

        .bus2cac_bus_req    (bus2cac_bus_req    ),
        .bus2cac_bus_rsp    (bus2cac_bus_rsp    ),
        .bus2cac_addr       (bus2cac_addr       ),
        .bus2cac_data       (bus2cac_data       ),

        .cac2bus_bus_req    (cac2bus_bus_req    ),
        .cac2bus_bus_rsp    (cac2bus_bus_rsp    ),
        .cac2bus_addr       (cac2bus_addr       ),
        .cac2bus_data       (cac2bus_data       ),
        .cac2bus_write_back (cac2bus_write_back )
  );

  //-------------------------------------------------------------------
  initial begin
    forever #5 clk = ~clk;
  end

  //-------------------------------------------------------------------
  initial begin
    clk   = 1'b0;
    rst_n = 1'b0;
    repeat (5) @(posedge clk);
    rst_n = 1'b1;
  end

  //-------------------------------------------------------------------
  initial begin
    uvm_pkg::uvm_config_db#(virtual cache_if)::set(null, "uvm_test_top.*", "cac_if", cac_if);
  end

  //-------------------------------------------------------------------
  initial begin
    $display("hello from cache_mem_tb");
    run_test("cache_base_test");
    $display("complete cache_mem_tb");
    $finish;
  end
endmodule: cache_mem_tb_top

`endif
