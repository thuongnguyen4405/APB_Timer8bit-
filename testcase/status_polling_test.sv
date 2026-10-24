// VPlan: Interrupt | status_polling_test | Directed; no scenario helper hidden in env.
class status_polling_test extends base_test;
  function new(virtual dut_if v);
    super.new(v,"status_polling_test");
  endfunction
  virtual task run_scenario();
    bit ovf,udf;
    logic [7:0] status;
    // 1. TIE=0, clear TSR, preload FF for overflow UP /8.
    write(8'h00,8'h00);
    write(8'h03,8'h00);
    write(8'h01,8'h03);
    write(8'h02,8'hff);
    write(8'h00,8'h1c);
    write(8'h00,8'h18);
    write(8'h00,8'h19);
    // 2. Poll status in software with IRQ disabled.
    ovf=0;
    for (int k=0;k<100;k++) begin
      read(8'h01,status);
      if (status[0]) begin ovf=1; break; end
    end
    write(8'h00,8'h18);
    env.expect_bit("polling overflow",ovf,1);
    write(8'h01,8'h01);
    read_expect(8'h01,8'h00,8'h01);
    // 3. Repeat polling for underflow, then clear with W1C.
    write(8'h02,8'h00);
    write(8'h00,8'h1e);
    write(8'h00,8'h1a);
    write(8'h00,8'h1b);
    udf=0;
    for (int k=0;k<100;k++) begin
      read(8'h01,status);
      if (status[1]) begin udf=1; break; end
    end
    write(8'h00,8'h1a);
    env.expect_bit("polling underflow",udf,1);
    write(8'h01,8'h02);
    read_expect(8'h01,8'h00,8'h03);
    // PASS: both status flags observable/clearable without enabling IRQ.
  endtask
endclass
