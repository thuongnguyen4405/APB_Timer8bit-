// VPlan: Counter | counter_count_down_test | Directed; no scenario helper hidden in env.
class counter_count_down_test extends base_test;
  function new(virtual dut_if v);
    super.new(v,"counter_count_down_test");
  endfunction
  virtual task run_scenario();
    bit hit;
    logic [7:0] status;
    // 1. Disable, clear TSR, LOAD TDR=10, direction DOWN and /1.
    write(8'h00,8'h00);
    write(8'h01,8'h03);
    write(8'h02,8'h10);
    write(8'h00,8'h06);
    write(8'h00,8'h02);
    // 2. Enable; observe terminal event via TSR[1].
    write(8'h00,8'h03);
    hit=0;
    for (int k=0;k<200;k++) begin
      read(8'h01,status);
      if (status[1]) begin hit=1; break; end
    end
    write(8'h00,8'h02);
    // 3. PASS: down-counter eventually underflows 00 -> FF.
    env.expect_bit("count-down underflow seen",hit,1);
  endtask
endclass
