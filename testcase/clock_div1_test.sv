
 // VPlan: Clock Divisor | clock_div8_test | Directed
class clock_div8_test extends base_test;

  function new(virtual dut_if v);
    super.new(v, "clock_div8_test");
  endfunction

  virtual task run_scenario();

    bit first, second;
    logic [7:0] status;
    realtime t_first, t_second, interval_ns;

    // KER_CLK = 200 MHz => 5 ns
    // DIV/8 => 40 ns per counter tick
    // 8-bit Counter => 256 * 40 = 10240 ns
    // Current tolerance +/-30%: 7168 - 13312 ns


    // ==========================================
    // PART 1: DIV/8 - COUNT UP
    // ==========================================

    $display("[DIV/8] START COUNT UP");

    // 1. Configure Timer, clear TSR
    write(8'h00, 8'h00); // Disable Timer
    write(8'h01, 8'h03); // Clear Overflow/Underflow
    write(8'h02, 8'h00); // TDR = 00

    write(8'h00, 8'h1C); // DIV/8, UP, LOAD=1
    write(8'h00, 8'h18); // DIV/8, UP, LOAD=0
    write(8'h00, 8'h19); // Enable Count Up

    // 2. Poll first Overflow: TSR[0]
    first = 0;

    for (int k = 0; k < 500; k++) begin
      read(8'h01, status);

      if (status[0]) begin
        first = 1;
        break;
      end
    end

    env.expect_bit("UP: first overflow", first, 1);
    if (!first) return;

    t_first = $realtime / 1ns;

    // 3. Clear Overflow using W1C
    // Timer continues counting
    write(8'h01, 8'h01);

    // 4. Poll second Overflow
    second = 0;

    for (int k = 0; k < 500; k++) begin
      read(8'h01, status);

      if (status[0]) begin
        second = 1;
        break;
      end
    end

    env.expect_bit("UP: second overflow", second, 1);
    if (!second) return;

    t_second = $realtime / 1ns;

    // 5. Stop Timer
    write(8'h00, 8'h18);

    // 6. Check Overflow interval
    interval_ns = t_second - t_first;

    $display("[DIV/8 UP] Interval = %0.2f ns",
             interval_ns);

    env.test_checks++;

    if (interval_ns < 7168.0 ||
        interval_ns > 13312.0) begin

      env.test_errors++;
      $error("[DIV/8 UP] Invalid interval");
    end


    // ==========================================
    // PART 2: DIV/8 - COUNT DOWN
    // ==========================================

    $display("[DIV/8] START COUNT DOWN");

    // 1. Configure Timer, clear TSR
    write(8'h00, 8'h18); // Disable Timer
    write(8'h01, 8'h03); // Clear Overflow/Underflow
    write(8'h02, 8'hFF); // TDR = FF

    write(8'h00, 8'h1E); // DIV/8, DOWN, LOAD=1
    write(8'h00, 8'h1A); // DIV/8, DOWN, LOAD=0
    write(8'h00, 8'h1B); // Enable Count Down

    // 2. Poll first Underflow: TSR[1]
    first = 0;

    for (int k = 0; k < 500; k++) begin
      read(8'h01, status);

      if (status[1]) begin
        first = 1;
        break;
      end
    end

    env.expect_bit("DOWN: first underflow", first, 1);
    if (!first) return;

    t_first = $realtime / 1ns;

    // 3. Clear Underflow using W1C
    // Timer continues counting
    write(8'h01, 8'h02);

    // 4. Poll second Underflow
    second = 0;

    for (int k = 0; k < 500; k++) begin
      read(8'h01, status);

      if (status[1]) begin
        second = 1;
        break;
      end
    end

    env.expect_bit("DOWN: second underflow", second, 1);
    if (!second) return;

    t_second = $realtime / 1ns;

    // 5. Stop Timer
    write(8'h00, 8'h1A);

    // 6. Check Underflow interval
    interval_ns = t_second - t_first;

    $display("[DIV/8 DOWN] Interval = %0.2f ns",
             interval_ns);

    env.test_checks++;

    if (interval_ns < 7168.0 ||
        interval_ns > 13312.0) begin

      env.test_errors++;
      $error("[DIV/8 DOWN] Invalid interval");
    end

    $display("[DIV/8] UP and DOWN checks completed");

  endtask

endclass
