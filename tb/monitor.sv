class monitor;
  virtual dut_if vif;
  mailbox #(packet) m2s_mb;
  int transfer_count=0;
  int irq_rises=0;
  function new(virtual dut_if v, mailbox #(packet) q);
    vif=v; m2s_mb=q;
  endfunction
  task run();
    packet p;
    forever begin
      @(posedge vif.pclk);
      // Sample APB at ACCESS completion; no false transaction on SETUP.
      #1ps; // allow DUT nonblocking updates at the clock edge
      if (vif.presetn && vif.psel && vif.penable && vif.pready) begin
        p=new();
        p.op=vif.pwrite ? APB_WRITE : APB_READ;
        p.addr=vif.paddr; p.data=vif.pwdata; p.rdata=vif.prdata;
        p.issue_time=$time;
        m2s_mb.put(p);
        transfer_count++;
      end
    end
  endtask
  task irq_watch();
    forever begin
      @(posedge vif.interrupt);
      if (vif.presetn) irq_rises++;
    end
  endtask
endclass
