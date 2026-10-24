`timescale 1ns/1ps
module testbench;
  import timer_pkg::*;
  import test_pkg::*;
  dut_if d_if();
  timer_top u_dut(
    .ker_clk(d_if.ker_clk), .pclk(d_if.pclk), .presetn(d_if.presetn),
    .psel(d_if.psel), .penable(d_if.penable), .pwrite(d_if.pwrite),
    .paddr(d_if.paddr), .pwdata(d_if.pwdata), .prdata(d_if.prdata),
    .pready(d_if.pready), .interrupt(d_if.interrupt)
  );

  initial begin // 50 MHz APB clock
    d_if.pclk=0;
    forever #10ns d_if.pclk=~d_if.pclk;
  end
  initial begin // 200 MHz kernel clock
    d_if.ker_clk=1;
    forever #2.5ns d_if.ker_clk=~d_if.ker_clk;
  end
  initial begin
    d_if.presetn=0;
    d_if.psel=0; d_if.penable=0; d_if.pwrite=0;
    d_if.paddr=0; d_if.pwdata=0;
  end
  initial begin : run_test
    string name;
    base_test t;
    if (!$value$plusargs("TESTNAME=%s",name)) name="register_reset_test";
    // The same OOP/polymorphism pattern as the I2C training environment:
    // construct a derived class and assign it to a base_test handle.
    case (name)
      "register_reset_test": begin
        register_reset_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "register_rw_test": begin
        register_rw_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "register_reset_on_fly_test": begin
        register_reset_on_fly_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "reserved_fields_address_test": begin
        reserved_fields_address_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "tsr_w1c_test": begin
        tsr_w1c_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "tsr_selective_clear_test": begin
        tsr_selective_clear_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "random_register_access_test": begin
        random_register_access_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "clock_div1_test": begin
        clock_div1_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "clock_div2_test": begin
        clock_div2_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "clock_div4_test": begin
        clock_div4_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "clock_div8_test": begin
        clock_div8_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "counter_load_test": begin
        counter_load_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "timer_enable_disable_test": begin
        timer_enable_disable_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "counter_count_up_test": begin
        counter_count_up_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "counter_count_down_test": begin
        counter_count_down_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "counter_overflow_test": begin
        counter_overflow_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "counter_underflow_test": begin
        counter_underflow_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "random_counter_config_test": begin
        random_counter_config_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "overflow_interrupt_test": begin
        overflow_interrupt_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "underflow_interrupt_test": begin
        underflow_interrupt_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "interrupt_mask_test": begin
        interrupt_mask_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "irq_enable_independence_test": begin
        irq_enable_independence_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "status_polling_test": begin
        status_polling_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      "random_irq_mask_test": begin
        random_irq_mask_test selected_test;
        selected_test = new(d_if);
        t = selected_test;
      end
      default: $fatal(1,"Unknown +TESTNAME=%s",name);
    endcase
    if (t==null) $fatal(1,"No derived testcase object was created");
    t.run_test(); // dynamic dispatch -> derived run_scenario()
    $finish;
  end
  initial begin // prevent silent hangs; note long random runs
    #1ms;
    $fatal(1,"[WATCHDOG] 1ms timeout: no final test result");
  end
endmodule
