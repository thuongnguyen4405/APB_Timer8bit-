// VPlan: Register | register_rw_test | Directed; no scenario helper hidden in env.
class register_rw_test extends base_test;
  function new(virtual dut_if v);
    super.new(v,"register_rw_test");
  endfunction
  virtual task run_scenario();
    bit [7:0] patterns[0:3] = '{8'h00,8'h55,8'haa,8'hff};
    // 1. Disable timer and avoid writing action bit TCR.LOAD.
    write(8'h00,8'h00);
    // 2. Write known patterns and read back each defined RW field.
    for (int i=0; i<4; i++) begin
      write(8'h02,patterns[i]);
      read_expect(8'h02,patterns[i]); // TDR[7:0]
      write(8'h03,patterns[i]);
      read_expect(8'h03,patterns[i] & 8'h03); // TIE[1:0]
      write(8'h00,patterns[i] & 8'h1a); // TCR without LOAD or enable
      read_expect(8'h00,patterns[i] & 8'h1a,8'hfb);
    end
    // PASS: defined RW bits retain the written values, reserved bits read 0.
  endtask
endclass
