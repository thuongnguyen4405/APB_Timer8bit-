class register_reset_on_fly_test extends base_test;
    function new(virtual dut_if v);
        super.new(v, "register_reset_on_fly_test");
    endfunction

    virtual task run_scenario();
        bit found;
        logic [7:0] status;
        write(8'h00, 8'h00);
        write(8'h02, 8'hff); // non-default TDR
        write(8'h03, 8'h01); // non-default TIE
        write(8'h01, 8'h03); // clear status
        write(8'h00, 8'h1c); // /8 + LOAD FF, disabled
        write(8'h00, 8'h18);
        write(8'h00, 8'h19); // start

        // Wait until an overflow status really exists.
        found = 0;
        for (int k=0; k<100; k++) begin
            read(8'h01, status);
            if (status[0]) begin found=1; break; end
        end
        env.expect_bit("overflow before reset", found, 1);

        env.reset_dut(); // assert reset while timer was active
        read_expect(8'h00, 8'h00); // TCR
        read_expect(8'h01, 8'h00); // TSR
        read_expect(8'h02, 8'h00); // TDR
        read_expect(8'h03, 8'h00); // TIE
    endtask
endclass
