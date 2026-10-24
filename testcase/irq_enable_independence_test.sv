// VPlan: Interrupt | irq_enable_independence_test | Directed; no scenario helper hidden in env.
class irq_enable_independence_test extends base_test;
  function new(virtual dut_if v);
    super.new(v,"irq_enable_independence_test");
  endfunction
  virtual task run_scenario();
    int before_irq;
    bit hit;
    logic [7:0] status;
    // 1. Enable overflow ONLY; generate underflow, expect no IRQ.
    write(8'h00,8'h00);
    write(8'h03,8'h01);
    write(8'h01,8'h03);
    write(8'h02,8'h00);
    write(8'h00,8'h1e);
    write(8'h00,8'h1a);
    before_irq=env.mon.irq_rises;
    write(8'h00,8'h1b);
    hit=0;
    for (int k=0;k<100;k++) begin
      read(8'h01,status);
      if (status[1]) begin hit=1; break; end
    end
    write(8'h00,8'h1a);
    env.expect_bit("underflow generated",hit,1);
    env.expect_bit("only overflow enabled => IRQ absent",env.mon.irq_rises==before_irq,1);
    // 2. Reset, enable underflow ONLY, generate overflow.
    env.reset_dut();
    write(8'h00,8'h00);
    write(8'h03,8'h02);
    write(8'h01,8'h03);
    write(8'h02,8'hff);
    write(8'h00,8'h1c);
    write(8'h00,8'h18);
    before_irq=env.mon.irq_rises;
    write(8'h00,8'h19);
    hit=0;
    for (int k=0;k<100;k++) begin
      read(8'h01,status);
      if (status[0]) begin hit=1; break; end
    end
    write(8'h00,8'h18);
    env.expect_bit("overflow generated",hit,1);
    env.expect_bit("only underflow enabled => IRQ absent",env.mon.irq_rises==before_irq,1);
    // PASS: TIE bits independently mask unrelated event sources.
  endtask
endclass
