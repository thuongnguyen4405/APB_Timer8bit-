// VPlan: Register | register_reset_test | Directed; no scenario helper hidden in env.
class register_reset_test extends base_test;
  function new(virtual dut_if v);
    super.new(v,"register_reset_test");
  endfunction
  virtual task run_scenario();
    // 1. Reset is applied by base_test.run_test().
    // 2. Read all four mapped registers.
    // 3. PASS: each returns its specified reset value, 00.
    read_expect(8'h00,8'h00); // TCR
    read_expect(8'h01,8'h00); // TSR
    read_expect(8'h02,8'h00); // TDR
    read_expect(8'h03,8'h00); // TIE
  endtask
endclass
