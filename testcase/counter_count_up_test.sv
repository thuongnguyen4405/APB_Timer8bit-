// VPlan: Counter | counter_count_up_test | Directed; no scenario helper hidden in env.
class counter_count_up_test extends base_test;
  function new(virtual dut_if v);
    super.new(v,"counter_count_up_test");
  endfunction
  virtual task run_scenario();
    bit hit;
    logic [7:0] status;
    // 1. Disable, clear TSR, LOAD TDR=10, direction UP and /1.
    write(8'h00,8'h00);
    write(8'h01,8'h03);
    write(8'h02,8'h10);
    write(8'h00,8'h04);
    write(8'h00,8'h00);
    // 2. Enable; observe terminal event using public TSR[0].
    write(8'h00,8'h01);
    hit=0;
    for (int k=0;k<1500;k++) begin
      read(8'h01,status);
      if (status[0]) begin hit=1; break; end
    end
    write(8'h00,8'h00);
    // 3. PASS: up-count eventually wraps FF -> 00; internal intermediate count not accessible.
    env.expect_bit("count-up overflow seen",hit,1);
  endtask
endclass
