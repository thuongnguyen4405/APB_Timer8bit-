// VPlan: Counter | counter_underflow_test | Directed; no scenario helper hidden in env.
class counter_underflow_test extends base_test;
  function new(virtual dut_if v);
    super.new(v,"counter_underflow_test");
  endfunction
  virtual task run_scenario();
    bit hit;
    logic [7:0] status;
    // 1. Clear TSR, LOAD 01, count DOWN /8 while disabled.
    write(8'h00,8'h00);
    write(8'h01,8'h03);
    write(8'h02,8'h01);
    write(8'h00,8'h1e);
    write(8'h00,8'h1a);
    // 2. Enable and poll TSR[1] (01->00->FF).
    write(8'h00,8'h1b);
    hit=0;
    for (int k=0;k<150;k++) begin
      read(8'h01,status);
      if (status[1]) begin hit=1; break; end
    end
    write(8'h00,8'h1a);
    // 3. PASS: underflow sets TSR[1] and not TSR[0].
    env.expect_bit("underflow observed",hit,1);
    read_expect(8'h01,8'h02,8'h03);
  endtask
endclass
