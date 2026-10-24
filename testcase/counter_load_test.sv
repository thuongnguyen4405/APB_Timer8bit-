// VPlan: Counter | counter_load_test | Directed; no scenario helper hidden in env.
class counter_load_test extends base_test;
  function new(virtual dut_if v);
    super.new(v,"counter_load_test");
  endfunction
  virtual task run_scenario();
    // Black-box proxy: top-level has no counter output. TDR=52 (Vplan).
    bit hit;
    logic [7:0] status;
    realtime start_t, end_t, elapsed;
    // 1. Stop timer, write TDR=52; LOAD with timer stopped.
    write(8'h00,8'h00);
    write(8'h01,8'h03);
    write(8'h02,8'h52);
    write(8'h00,8'h1c); // /8, LOAD=1, up, disabled
    write(8'h00,8'h18); // clear LOAD
    // 2. Start timer; 52->FF->00 requires 174 up-ticks.
    write(8'h00,8'h19);
    start_t=$realtime;
    hit=0;
    for (int k=0;k<1200;k++) begin
      read(8'h01,status);
      if (status[0]) begin hit=1; break; end
    end
    end_t=$realtime;
    write(8'h00,8'h18);
    env.expect_bit("overflow reached from LOAD=52",hit,1);
    if (hit) begin
      elapsed=end_t-start_t;
      env.test_checks++;
      // /8 nominal 174*40ns=6960ns, allow APB observation/setup latency.
      if (elapsed < 5200.0 || elapsed > 8750.0) begin
        env.test_errors++;
        $error("[LOAD] t=%0.2f ns expected approx 6960ns from TDR=52",elapsed);
      end
    end
    // PASS: overflow timing is consistent with preloading 52; cannot directly observe counter.
  endtask
endclass
