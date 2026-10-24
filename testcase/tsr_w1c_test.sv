class tsr_w1c_test extends base_test;
    function new(virtual dut_if v);
        super.new(v, "tsr_w1c_test");
    endfunction

    virtual task run_scenario();
        bit seen;
        logic [7:0] status;

        // PART 1: overflow FF -> 00 sets TSR[0].
        write(8'h00, 8'h00); // disable
        write(8'h01, 8'h03); // clear old events
        write(8'h02, 8'hff); // preload FF
        write(8'h00, 8'h1c); // /8, LOAD, up
        write(8'h00, 8'h18); // LOAD=0
        write(8'h00, 8'h19); // enable
        seen = 0;
        for (int k=0; k<100; k++) begin
            read(8'h01, status);
            if (status[0]) begin seen=1; break; end
        end
        write(8'h00, 8'h18); // disable before clearing
        env.expect_bit("overflow event", seen, 1);
        write(8'h01, 8'h00); // write 0: must keep flag
        read_expect(8'h01, 8'h01, 8'h01);
        write(8'h01, 8'h01); // write 1: clear TSR[0]
        read_expect(8'h01, 8'h00, 8'h01);

        // PART 2: underflow 00 -> FF sets TSR[1].
        write(8'h02, 8'h00);
        write(8'h00, 8'h1e); // /8, LOAD, down
        write(8'h00, 8'h1a); // LOAD=0
        write(8'h00, 8'h1b); // enable
        seen = 0;
        for (int k=0; k<100; k++) begin
            read(8'h01, status);
            if (status[1]) begin seen=1; break; end
        end
        write(8'h00, 8'h1a); // disable
        env.expect_bit("underflow event", seen, 1);
        write(8'h01, 8'h00); // 0 keeps TSR[1]
        read_expect(8'h01, 8'h02, 8'h02);
        write(8'h01, 8'h02); // 1 clears TSR[1]
        read_expect(8'h01, 8'h00, 8'h02);
    endtask
endclass
