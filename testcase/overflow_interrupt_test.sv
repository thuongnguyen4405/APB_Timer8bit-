// VPlan: Interrupt | overflow_interrupt_test | Directed; no scenario helper hidden in env.
class overflow_interrupt_test extends base_test;
  function new(virtual dut_if v);
    super.new(v,"overflow_interrupt_test");
  endfunction
  virtual task run_scenario();
    int irq_before;
    bit hit;
    logic [7:0] status;
    // 1. Enable overflow IRQ TIE[0], clear TSR; LOAD FE, count UP /8.
    write(8'h00,8'h00);
    write(8'h03,8'h01);
    write(8'h01,8'h03);
    write(8'h02,8'hfe);
    write(8'h00,8'h1c);
    write(8'h00,8'h18);
    irq_before=env.mon.irq_rises;
    // 2. Enable timer; poll for overflow and IRQ edge.
    write(8'h00,8'h19);
    hit=0;
    for (int k=0;k<150;k++) begin
      read(8'h01,status);
      if (status[0]) begin hit=1; break; end
    end
    write(8'h00,8'h18);
    // 3. PASS: TSR[0] and observed IRQ are asserted.
    env.expect_bit("overflow status",hit,1);
    env.expect_bit("IRQ rose",env.mon.irq_rises>irq_before,1);
    read_expect(8'h01,8'h01,8'h01);
    write(8'h01,8'h01);
    read_expect(8'h01,8'h00,8'h01);
  endtask
endclass
