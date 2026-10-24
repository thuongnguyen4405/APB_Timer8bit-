// VPlan: Interrupt | random_irq_mask_test | Constrained-Random; no scenario helper hidden in env.
class random_irq_mask_test extends base_test;
  function new(virtual dut_if v);
    super.new(v,"random_irq_mask_test");
  endfunction
  virtual task run_scenario();
    timer_random_cfg cfg;
    bit [7:0] ctrl;
    bit seen;
    bit expected_irq;
    int irq_before;
    logic [7:0] status;
    // 1. Randomize direction, start value, /1../8 and TIE[1:0].
    repeat (16) begin
      cfg=new();
      if (!cfg.randomize() with {
          if (down) init_value inside {8'h00, 8'h01};
          else      init_value inside {8'hfe, 8'hff};
        }) $fatal(1,"IRQ randomize failed");
      env.reset_dut();
      ctrl={3'b000,cfg.divider,1'b0,cfg.down,1'b0};
      // 2. Disable; clear; configure TIE and load TDR.
      write(8'h00,8'h00);
      write(8'h01,8'h03);
      write(8'h03,{6'b0,cfg.irq_mask});
      write(8'h02,cfg.init_value);
      write(8'h00,ctrl | 8'h04);
      write(8'h00,ctrl);
      irq_before=env.mon.irq_rises;
      write(8'h00,ctrl | 8'h01);
      // 3. Poll for the event; check IRQ mask against observed rising edges.
      seen=0;
      for (int k=0;k<1500;k++) begin
        read(8'h01,status);
        if (status[cfg.down]) begin seen=1; break; end
      end
      write(8'h00,ctrl);
      env.expect_bit("random status event observed",seen,1);
      expected_irq=cfg.down ? cfg.irq_mask[1] : cfg.irq_mask[0];
      env.expect_bit("random IRQ mask matches source",env.mon.irq_rises>irq_before,expected_irq);
      $display("[RND IRQ] mask=%02b down=%0b data=%02h div=/%0d",cfg.irq_mask,cfg.down,cfg.init_value,1<<cfg.divider);
    end
    // PASS: observed HW event plus expected IRQ behavior for each random case.
  endtask
endclass
