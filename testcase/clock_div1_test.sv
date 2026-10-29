
 // VPlan: Clock Divisor | clock_div1_test | Directed
class clock_div1_test extends base_test;

  function new(virtual dut_if v);
    super.new(v, "clock_div1_test");
  endfunction

  virtual task run_scenario();
    bit first, second;
    logic [7:0] status;
    realtime t_first, t_second, interval_ns;

    // KER_CLK = 200 MHz => 5 ns
    // Divider /1 => 5 ns per counter tick
    // 8-bit Counter => 256 * 5 = 1280 ns
    // Tolerance +/-30% => 896 to 1664 ns


    // ==========================================
    // PART 1: DIVIDER /1 - COUNT UP
    // ==========================================

    $display("[DIV/1] START COUNT UP");

    // 1. Disable Timer, clear TSR.
    write(8'h00, 8'h00);
    write(8'h01, 8'h03);

    // 2. Load Counter = 00.
    write(8'h02, 8'h00);
    write(8'h00, 8'h04); // LOAD=1, UP, DIV/1
    write(8'h00, 8'h00); // Clear LOAD
    write(8'h00, 8'h01); // Enable Count Up

    // 3. Poll first Overflow: TSR[0].
    first = 0;

    for (int k = 0; k < 100; k++) begin
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

    for (int k = 0; k < 100; k++) begin
      read(8'h01, status);

      if (status[0]) begin
        second = 1;
        break;
      end
    end

    env.expect_bit("UP: second overflow", second, 1);

    t_second = $realtime / 1ns;

    write(8'h00, 8'h00); // Stop Timer

    if (!second) return;

    // 6. Check Overflow interval.
    interval_ns = t_second - t_first;

    $display("[DIV/1 UP] Interval = %0.2f ns",
             interval_ns);

    env.test_checks++;

    if (interval_ns < 896.0 ||
        interval_ns > 1664.0) begin

      env.test_errors++;
      $error("[DIV/1 UP] Interval outside +/-30%% tolerance");
    end


    // ==========================================
    // PART 2: DIVIDER /1 - COUNT DOWN
    // ==========================================

    $display("[DIV/1] START COUNT DOWN");

    // 1. Disable Timer, clear TSR.
    write(8'h00, 8'h00);
    write(8'h01, 8'h03);

    // 2. Load Counter = FF.
    write(8'h02, 8'hFF);
    write(8'h00, 8'h06); // LOAD=1, DOWN, DIV/1
    write(8'h00, 8'h02); // Clear LOAD, keep DOWN
    write(8'h00, 8'h03); // Enable Count Down

    // 3. Poll first Underflow: TSR[1].
    first = 0;

    for (int k = 0; k < 100; k++) begin
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

    for (int k = 0; k < 100; k++) begin
      read(8'h01, status);

      if (status[1]) begin
        second = 1;
        break;
      end
    end

    env.expect_bit("DOWN: second underflow", second, 1);

    t_second = $realtime / 1ns;

    write(8'h00, 8'h02); // Stop Timer, keep DOWN

    if (!second) return;

    // 6. Check Underflow interval.
    interval_ns = t_second - t_first;

    $display("[DIV/1 DOWN] Interval = %0.2f ns",
             interval_ns);

    env.test_checks++;

    if (interval_ns < 896.0 ||
        interval_ns > 1664.0) begin

      env.test_errors++;
      $error("[DIV/1 DOWN] Interval outside +/-30%% tolerance");
    end

    $display("[DIV/1] UP and DOWN checks completed");

  endtask

endclass
