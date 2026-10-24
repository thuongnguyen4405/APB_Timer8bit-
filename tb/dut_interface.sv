interface dut_if;
  logic       ker_clk;   // 200 MHz timer kernel clock
  logic       pclk;      // 50 MHz APB clock
  logic       presetn;   // active-low reset
  logic       psel;
  logic       penable;
  logic       pwrite;
  logic [7:0] paddr;
  logic [7:0] pwdata;
  logic [7:0] prdata;
  logic       pready;
  logic       interrupt;
endinterface
