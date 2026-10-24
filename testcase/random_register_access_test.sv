// VPlan: Register | random_register_access_test | Constrained-Random; no scenario helper hidden in env.
class random_register_access_test extends base_test;
  function new(virtual dut_if v);
    super.new(v,"random_register_access_test");
  endfunction
  virtual task run_scenario();
    packet p;
    bit [7:0] addr, data, expected;
    // 1. Hold timer off to avoid uncontrolled TCR side effects.
    write(8'h00,8'h00);
    // 2. Generate legal APB register/reserved-address writes using CRV.
    repeat (60) begin
      p=new();
      if (!p.randomize() with {
            addr dist {8'h00 := 1, 8'h02 := 1, 8'h03 := 1, [8'h04:8'hff] :/ 1};
            op == APB_WRITE;
          })
        $fatal(1,"Random APB packet constraint failed");
      addr=p.addr; data=p.data;
      case (addr)
        8'h00: expected = data & 8'h1a; // safe TCR: stop and LOAD=0
        8'h02: expected = data;
        8'h03: expected = data & 8'h03;
        default: expected = 8'h00; // reserved region
      endcase
      // Transmit random payload to TIE/reserved addresses; don't mask away
      // the stimulus intended to test reserved-bit write-ignore behavior.
      if (addr == 8'h00)
        write(addr,expected); // timer disabled, LOAD=0
      else
        write(addr,data);
      if (addr == 8'h00)
        read_expect(addr,expected,8'hfb); // LOAD readback excluded
      else
        read_expect(addr,expected,8'hff);
    end
    // PASS: observed readback matches defined fields; reserved addresses are 0.
  endtask
endclass
