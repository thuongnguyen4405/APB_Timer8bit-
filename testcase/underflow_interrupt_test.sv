// VPlan: Interrupt | underflow_interrupt_test | Directed; no scenario helper hidden in env.
class underflow_interrupt_test extends base_test;
  function new(virtual dut_if v);
    super.new(v,"underflow_interrupt_test");
  endfunction
  virtual task run_scenario();
    int irq_before;
    bit hit;
    logic [7:0] status;
    // 1. Enable underflow IRQ TIE[1], clear TSR; LOAD 01, DOWN /8.
    write(8'h00,8'h00);
    write(8'h03,8'h02);
    write(8'h01,8'h03);
    write(8'h02,8'h01);
    write(8'h00,8'h1e);
    write(8'h00,8'h1a);
    irq_before=env.mon.irq_rises;
    // 2. Enable timer; poll underflow and observe IRQ.
    write(8'h00,8'h1b);
    hit=0;
    for (int k=0;k<150;k++) begin
      read(8'h01,status);
      if (status[1]) begin hit=1; break; end
    end
    write(8'h00,8'h1a);
    // 3. PASS: TSR[1] and IRQ occurred, W1C can clear status.
    env.expect_bit("underflow status",hit,1);
    env.expect_bit("IRQ rose",env.mon.irq_rises>irq_before,1);
    write(8'h01,8'h02);
    read_expect(8'h01,8'h00,8'h02);
  endtask
endclass
