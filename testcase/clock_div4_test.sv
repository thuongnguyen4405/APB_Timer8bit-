// VPlan: Clock Divisor | clock_div4_test | Directed; no scenario helper hidden in env.
class clock_div4_test extends base_test;
  function new(virtual dut_if v);
    super.new(v,"clock_div4_test");
  endfunction
  virtual task run_scenario();
    bit first,second;
    logic [7:0] status;
    realtime t_first,t_second,interval_ns;
    // 1. Set clk_div=2'b10 (/ 4), load 00, count up, clear TSR.
    write(8'h00,8'h00);
    write(8'h01,8'h03);
    write(8'h02,8'h00);
    write(8'h00,8'h14); // LOAD; disabled
    write(8'h00,8'h10); // clear LOAD
    write(8'h00,8'h11); // enable
    // 2. Observe first overflow by polling TSR[0].
    first=0;
    for (int k=0;k<1500;k++) begin
      read(8'h01,status);
      if (status[0]) begin first=1; break; end
    end
    env.expect_bit("first overflow",first,1);
    if (!first) return;
    t_first=$realtime;
    write(8'h01,8'h01); // W1C; keep timer running
    // 3. Observe next overflow and compare approximately 256 ticks apart.
    second=0;
    for (int k=0;k<1500;k++) begin
      read(8'h01,status);
      if (status[0]) begin second=1; break; end
    end
    env.expect_bit("second overflow",second,1);
    t_second=$realtime;
    write(8'h00,8'h10); // stop
    if (!second) return;
    interval_ns=t_second-t_first;
    env.test_checks++;
    // APB polling is coarse: this is a broad frequency sanity check, not exact jitter measurement.
    $display("[DIV/4] two-wrap interval=%0.2f ns, nominal=5120 ns",interval_ns);
    if (interval_ns < 5120*0.70 || interval_ns > 5120*1.30) begin
      env.test_errors++;
      $error("[DIV/4] observed interval outside +/-30%% polling tolerance");
    end
    // PASS: both events observed and external wrap interval roughly matches the divider.
  endtask
endclass
