// Environment creates/connects components; base_test creates APB packets.
class environment;
  virtual dut_if vif;
  mailbox #(packet) s2d_mb;
  mailbox #(packet) m2s_mb;
  stimulus stim;
  driver drv;
  monitor mon;
  scoreboard sb; // register reference model, no coverage yet
  int test_checks = 0, test_errors = 0;

  function new(virtual dut_if v);
    vif = v;
    s2d_mb = new();
    m2s_mb = new();
    stim = new(s2d_mb);
    drv = new(vif, s2d_mb);
    mon = new(vif, m2s_mb);
    sb = new(m2s_mb);
  endfunction

  task start();
    fork
      stim.run();
      drv.run();
      mon.run();
      mon.irq_watch();
      sb.run();
    join_none
  endtask


  function void expect_bit(string msg, logic got, logic want);
    test_checks++;
    if (got !== want) begin
      test_errors++;
      $error("[CHECK] %s actual=%b expected=%b", msg,got,want);
    end
  endfunction

  function void expect_mask(string msg, logic [7:0] got, bit [7:0] want, bit [7:0] mask);
    test_checks++;
    if ((got & mask) !== (want & mask)) begin
      test_errors++;
      $error("[CHECK] %s actual=%02h expected=%02h mask=%02h", msg,got,want,mask);
    end
  endfunction

  task reset_dut();
    @(negedge vif.pclk);
    vif.presetn = 0;
    repeat(5) @(negedge vif.pclk);
    vif.presetn = 1;
    sb.reset_model();
    repeat(3) @(posedge vif.pclk);
  endtask

  task check_no_errors(string test_name);
    int total_errors;
    total_errors = test_errors + sb.errors;
    if ((test_checks + sb.checks) == 0)
      $fatal(1,"[TEST FAILED] %s: NO CHECKS EXECUTED",test_name);
    if (drv.transfer_count != mon.transfer_count || sb.observations != mon.transfer_count)
      $fatal(1,"[TEST FAILED] %s: APB count DRIVER=%0d MONITOR=%0d SB=%0d",
             test_name,drv.transfer_count,mon.transfer_count,sb.observations);
    if (total_errors)
      $fatal(1,"[TEST FAILED] %s: errors=%0d",test_name,total_errors);
    $display("TEST PASSED %s checks=%0d APB=%0d IRQ_EDGES=%0d",test_name,
             test_checks+sb.checks,mon.transfer_count,mon.irq_rises);
  endtask
endclass
