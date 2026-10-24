// APB master Driver. Use negedge to drive stable signals before posedge.
// ICTC Timer does not support APB wait states.
class driver;
  virtual dut_if vif;
  mailbox #(packet) s2d_mb;
  int transfer_count=0;

  function new(virtual dut_if v, mailbox #(packet) q);
    vif=v;
    s2d_mb=q;
  endfunction

  task reset_bus();
    vif.psel=0;
    vif.penable=0;
    vif.pwrite=0;
    vif.paddr=0;
    vif.pwdata=0;
  endtask

  task run();
    packet p;
    forever begin
      s2d_mb.get(p);   // blocking: wait until the stimulus supplies a packet

      // T0 falling edge: prepare SETUP; address/data/control stable by T1 rising.
      @(negedge vif.pclk);
      vif.psel=1;
      vif.penable=0;
      vif.paddr=p.addr;
      vif.pwdata=p.data;
      vif.pwrite=(p.op==APB_WRITE);

      // T1 falling edge: drive ACCESS; address/data/control remain unchanged.
      @(negedge vif.pclk);
      vif.penable=1;

      // T2 rising edge: APB slave samples ACCESS, no-wait transfer completes.
      @(posedge vif.pclk);
      #1ps; // read responses after the same-edge DUT NBA updates
      if (vif.pready !== 1'b1)
        $fatal(1,"[DRIVER] APB no-wait violation: PREADY != 1 in ACCESS @ %0t",$time);
      if (p.op==APB_READ)
        p.rdata=vif.prdata;
      transfer_count++;

      // T2 falling edge: return bus to idle before next rising clock.
      @(negedge vif.pclk);
      reset_bus();
      ->p.done;
    end
  endtask
endclass
