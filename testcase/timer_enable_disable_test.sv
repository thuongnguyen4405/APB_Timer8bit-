class timer_enable_disable_test extends base_test;
    function new(virtual dut_if v);
        super.new(v, "timer_enable_disable_test");
    endfunction

    virtual task run_scenario();
        bit found;
        logic [7:0] status;
        // LOAD 0x20, /8, count up, timer disabled.
        write(8'h00, 8'h00);
        write(8'h01, 8'h03);
        write(8'h02, 8'h20);
        write(8'h00, 8'h1c);
        write(8'h00, 8'h18);

        // If counting while disabled, 224*40ns ~ 8960ns causes overflow.
        #11000ns;
        read_expect(8'h01, 8'h00, 8'h01);

        // Enable: it should now be able to wrap and set TSR[0].
        write(8'h00, 8'h19);
        found = 0;
        for (int k=0; k<500; k++) begin
            read(8'h01, status);
            if (status[0]) begin found=1; break; end
        end
        write(8'h00, 8'h18);
        env.expect_bit("overflow after enabling timer", found, 1);
    endtask
endclass
