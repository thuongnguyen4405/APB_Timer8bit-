// VPlan: Register | tsr_selective_clear_test | Directed; no scenario helper hidden in env.
class tsr_selective_clear_test extends base_test;
  function new(virtual dut_if v);
    super.new(v,"tsr_selective_clear_test");
  endfunction
  virtual task run_scenario();
    logic [7:0] status;
    bit ovf,udf;
    // 1. Generate overflow then underflow with status not cleared in between.
    write(8'h00,8'h00);
    write(8'h01,8'h03);
    write(8'h02,8'hff);
    write(8'h00,8'h1c);
    write(8'h00,8'h18);
    write(8'h00,8'h19);
    ovf=0;
    for (int k=0;k<100;k++) begin
      read(8'h01,status);
      if (status[0]) begin ovf=1; break; end
    end
    env.expect_bit("first overflow",ovf,1);
    write(8'h00,8'h18);
    write(8'h02,8'h00);
    write(8'h00,8'h1e); // /8, count-down, LOAD, disabled
    write(8'h00,8'h1a); // remove LOAD
    write(8'h00,8'h1b); // enable count-down
    udf=0;
    for (int k=0;k<100;k++) begin
      read(8'h01,status);
      if (status[1]) begin udf=1; break; end
    end
    env.expect_bit("second underflow",udf,1);
    write(8'h00,8'h1a);
    read_expect(8'h01,8'h03,8'h03);
    // 2. Write zero: neither flag may clear.
    write(8'h01,8'h00);
    read_expect(8'h01,8'h03,8'h03);
    // 3. Clear overflow only, then underflow only.
    write(8'h01,8'h01);
    read_expect(8'h01,8'h02,8'h03);
    write(8'h01,8'h02);
    read_expect(8'h01,8'h00,8'h03);
    // PASS: W1C clears selected bits without clearing the other bit.
  endtask
endclass
