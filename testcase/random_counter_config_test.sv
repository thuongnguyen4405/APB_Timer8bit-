// VPlan: Counter | random_counter_config_test | Constrained-Random; no scenario helper hidden in env.
class random_counter_config_test extends base_test;
  function new(virtual dut_if v);
    super.new(v,"random_counter_config_test");
  endfunction
  virtual task run_scenario();
    timer_random_cfg cfg;
    bit [7:0] ctrl;
    bit hit;
    logic [7:0] status;
    // 1. Random TDR, direction and all 4 clk_div modes.
    repeat (20) begin
      cfg=new();
      if (!cfg.randomize()) $fatal(1,"counter randomize failed");
      env.reset_dut();
      // 2. Explicit Timer configuration from randomized legal fields.
      ctrl={3'b000,cfg.divider,1'b0,cfg.down,1'b0};
      write(8'h00,8'h00);
      write(8'h01,8'h03);
      write(8'h02,cfg.init_value);
      write(8'h00,ctrl | 8'h04);
      write(8'h00,ctrl);
      write(8'h00,ctrl | 8'h01);
      // 3. Poll selected HW flag; fail if no terminal event.
      hit=0;
      for (int k=0;k<1500;k++) begin
        read(8'h01,status);
        if (status[cfg.down]) begin hit=1; break; end
      end
      write(8'h00,ctrl);
      env.expect_bit("random counter terminal status",hit,1);
      $display("[RND COUNTER] data=%02h div=/%0d down=%0b",cfg.init_value,1<<cfg.divider,cfg.down);
    end
    // PASS: all randomized legal settings achieve selected terminal condition.
  endtask
endclass
