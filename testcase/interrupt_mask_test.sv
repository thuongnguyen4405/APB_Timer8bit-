// VPlan: Interrupt | interrupt_mask_test | Directed; no scenario helper hidden in env.
class interrupt_mask_test extends base_test;
  function new(virtual dut_if v);
    super.new(v,"interrupt_mask_test");
  endfunction
  virtual task run_scenario();
    int irq_before;
    bit hit;
    logic [7:0] status;
    // 1. Write TIE=00, clear TSR, LOAD FF, count UP /8.
    write(8'h00,8'h00);
    write(8'h03,8'h00);
    write(8'h01,8'h03);
    write(8'h02,8'hff);
    write(8'h00,8'h1c);
    write(8'h00,8'h18);
    irq_before=env.mon.irq_rises;
    // 2. Enable and poll overflow.
    write(8'h00,8'h19);
    hit=0;
    for (int k=0;k<100;k++) begin
      read(8'h01,status);
      if (status[0]) begin hit=1; break; end
    end
    write(8'h00,8'h18);
    // 3. PASS: overflow status sets even when IRQ is masked; no IRQ rising edge.
    env.expect_bit("masked overflow flag",hit,1);
    env.expect_bit("masked IRQ remains low",env.mon.irq_rises==irq_before,1);
  endtask
endclass
