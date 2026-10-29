
class clock_div2_test extends base_test;

    function new(virtual dut_if v);
        super.new(v, "clock_div2_test");
    endfunction

    virtual task run_scenario();

        bit first, second;
        logic [7:0] status;
        realtime t_first, t_second, interval_ns;

        // KER_CLK = 200 MHz => 5 ns
        // Divider /2 => Counter tick = 10 ns
        // 8-bit Counter => 256 * 10 = 2560 ns
        // Tolerance +/-30% => 1792 ns to 3328 ns


        // ==========================================
        // PART 1: DIVIDER /2 - COUNT UP
        // ==========================================

        $display("[DIV/2] START COUNT UP");

        // Disable Timer, clear flags
        write(8'h00, 8'h00);
        write(8'h01, 8'h03);

        // Load Counter = 00
        write(8'h02, 8'h00);

        write(8'h00, 8'h0C); // DIV/2, LOAD=1
        write(8'h00, 8'h08); // DIV/2, LOAD=0
        write(8'h00, 8'h09); // DIV/2, EN=1, UP

        // Wait for first Overflow
        first = 0;

        for (int k = 0; k < 200; k++) begin
            read(8'h01, status);

            if (status[0]) begin
                first = 1;
                break;
            end
        end

        env.expect_bit("UP: first overflow", first, 1);
        if (!first) return;

        t_first = $realtime / 1ns;

        // Clear Overflow (W1C), keep running
        write(8'h01, 8'h01);

        // Wait for second Overflow
        second = 0;

        for (int k = 0; k < 200; k++) begin
            read(8'h01, status);

            if (status[0]) begin
                second = 1;
                break;
            end
        end

        env.expect_bit("UP: second overflow", second, 1);

        t_second = $realtime / 1ns;

        write(8'h00, 8'h08); // Stop Timer

        if (!second) return;

        interval_ns = t_second - t_first;

        $display("[DIV/2 UP] Interval = %0.2f ns",
                 interval_ns);

        env.test_checks++;

        if (interval_ns < 1792.0 ||
            interval_ns > 3328.0) begin

            env.test_errors++;

            $error("[DIV/2 UP] Invalid interval");
        end


        // ==========================================
        // PART 2: DIVIDER /2 - COUNT DOWN
        // ==========================================

        $display("[DIV/2] START COUNT DOWN");

        // Disable Timer, clear flags
        write(8'h00, 8'h08);
        write(8'h01, 8'h03);

        // Load Counter = FF
        write(8'h02, 8'hFF);

        write(8'h00, 8'h0E); // DIV/2, DOWN, LOAD=1
        write(8'h00, 8'h0A); // DIV/2, DOWN, LOAD=0
        write(8'h00, 8'h0B); // DIV/2, DOWN, EN=1

        // Wait for first Underflow
        first = 0;

        for (int k = 0; k < 200; k++) begin
            read(8'h01, status);

            if (status[1]) begin
                first = 1;
                break;
            end
        end

        env.expect_bit("DOWN: first underflow", first, 1);
        if (!first) return;

        t_first = $realtime / 1ns;

        // Clear Underflow (W1C), keep running
        write(8'h01, 8'h02);

        // Wait for second Underflow
        second = 0;

        for (int k = 0; k < 200; k++) begin
            read(8'h01, status);

            if (status[1]) begin
                second = 1;
                break;
            end
        end

        env.expect_bit("DOWN: second underflow", second, 1);

        t_second = $realtime / 1ns;

        write(8'h00, 8'h0A); // Stop Timer

        if (!second) return;

        interval_ns = t_second - t_first;

        $display("[DIV/2 DOWN] Interval = %0.2f ns",
                 interval_ns);

        env.test_checks++;

        if (interval_ns < 1792.0 ||
            interval_ns > 3328.0) begin

            env.test_errors++;

            $error("[DIV/2 DOWN] Invalid interval");
        end

    endtask

endclass
