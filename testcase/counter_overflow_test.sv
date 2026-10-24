// VPlan: Counter | counter_overflow_test | Directed; no scenario helper hidden in env.
class counter_overflow_test extends base_test;
  function new(virtual dut_if v);
    super.new(v,"counter_overflow_test");
  endfunction
  virtual task run_scenario();
    bit hit;
    logic [7:0] status;
    // 1. Clear TSR, LOAD FE, count UP at /8 while disabled.
    write(8'h00,8'h00);
    write(8'h01,8'h03);
    write(8'h02,8'hfe);
    write(8'h00,8'h1c);
    write(8'h00,8'h18);
    // 2. Enable and look for overflow flag (FE->FF->00).
    write(8'h00,8'h19);
    hit=0;
    for (int k=0;k<150;k++) begin
      read(8'h01,status);
      if (status[0]) begin hit=1; break; end
    end
    write(8'h00,8'h18);
    // 3. PASS: real overflow sets TSR[0] and not TSR[1].
    env.expect_bit("overflow observed",hit,1);
    read_expect(8'h01,8'h01,8'h03);
  endtask
endclass
