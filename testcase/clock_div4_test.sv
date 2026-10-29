
 // VPlan: Clock Divisor | clock_div4_test | Directed
class clock_div4_test extends base_test;

  function new(virtual dut_if v);
    super.new(v, "clock_div4_test");
  endfunction

  virtual task run_scenario();
    bit first, second;
    logic [7:0] status;
    realtime t_first, t_second, interval_ns;

    // KER_CLK = 200 MHz => 5 ns
    // Divider /4 => Counter tick = 20 ns
    // 8-bit Counter => 256 * 20 = 5120 ns
    // Tolerance +/-30% => 3584 to 6656 ns


    // ==========================================
    // PART 1: DIVIDER /4 - COUNT UP
    // ==========================================

    $display("[DIV/4] START COUNT UP");

    // 1. Disable Timer, clear TSR.
    write(8'h00, 8'h00);
    write(8'h01, 8'h03);

    // 2. Load Counter = 00.
    write(8'h02, 8'h00);
    write(8'h00, 8'h14); // DIV/4, LOAD=1, UP
    write(8'h00, 8'h10); // Clear LOAD
    write(8'h00, 8'h11); // Enable Count Up

    // 3. Poll first Overflow: TSR[0].
    first = 0;

    for (int k = 0; k < 300; k++) begin
      read(8'h01, status);

      if (status[0]) begin
        first = 1;
        break;
      end
    end

    env.expect_bit("UP: first overflow", first, 1);
    if (!first) return;

    t_first = $realtime / 1ns;

    // 4. Clear Overflow using W1C.
    // Timer continues counting.
    write(8'h01, 8'h01);

    // 5. Poll second Overflow.
    second = 0;

    for (int k = 0; k < 300; k++) begin
      read(8'h01, status);

      if (status[0]) begin
        second = 1;
        break;
      end
    end

    env.expect_bit("UP: second overflow", second, 1);

    t_second = $realtime / 1ns;

    write(8'h00, 8'h10); // Stop Timer

    if (!second) return;

    // 6. Check Overflow interval.
    interval_ns = t_second - t_first;

    $display("[DIV/4 UP] Interval = %0.2f ns",
             interval_ns);

    env.test_checks++;

    if (interval_ns < 3584.0 ||
        interval_ns > 6656.0) begin

      env.test_errors++;

      $error("[DIV/4 UP] Interval outside +/-30%% tolerance");
    end


    // ==========================================
    // PART 2: DIVIDER /4 - COUNT DOWN
    // ==========================================

    $display("[DIV/4] START COUNT DOWN");

    // 1. Disable Timer, clear TSR.
    write(8'h00, 8'h10);
    write(8'h01, 8'h03);

    // 2. Load Counter = FF.
    write(8'h02, 8'hFF);
    write(8'h00, 8'h16); // DIV/4, DOWN, LOAD=1
    write(8'h00, 8'h12); // Clear LOAD, keep DOWN
    write(8'h00, 8'h13); // Enable Count Down

    // 3. Poll first Underflow: TSR[1].
    first = 0;

    for (int k = 0; k < 300; k++) begin
      read(8'h01, status);

      if (status[1]) begin
        first = 1;
        break;
      end
    end

    env.expect_bit("DOWN: first underflow", first, 1);
    if (!first) return;

    t_first = $realtime / 1ns;

    // 4. Clear Underflow using W1C.
    // Timer continues counting.
    write(8'h01, 8'h02);

    // 5. Poll second Underflow.
    second = 0;

    for (int k = 0; k < 300; k++) begin
      read(8'h01, status);

      if (status[1]) begin
        second = 1;
        break;
      end
    end

    env.expect_bit("DOWN: second underflow", second, 1);

    t_second = $realtime / 1ns;

    write(8'h00, 8'h12); // Stop Timer

    if (!second) return;

    // 6. Check Underflow interval.
    interval_ns = t_second - t_first;

    $display("[DIV/4 DOWN] Interval = %0.2f ns",
             interval_ns);

    env.test_checks++;

    if (interval_ns < 3584.0 ||
        interval_ns > 6656.0) begin

      env.test_errors++;

      $error("[DIV/4 DOWN] Interval outside +/-30%% tolerance");
    end

    $display("[DIV/4] UP and DOWN checks completed");

  endtask

endclass
