// VPlan: Register | reserved_fields_address_test | Directed; no scenario helper hidden in env.
class reserved_fields_address_test extends base_test;
  function new(virtual dut_if v);
    super.new(v,"reserved_fields_address_test");
  endfunction
  virtual task run_scenario();
    // 1. Drive 1s into reserved TCR/TIE fields with timer off.
    write(8'h00,8'he0);
    read_expect(8'h00,8'h00,8'he0);
    write(8'h03,8'hfc);
    read_expect(8'h03,8'h00,8'hfc);
    // 2. Read TSR reserved bits, without software-setting the status flags.
    read_expect(8'h01,8'h00,8'hfc);
    // 3. Write/read representative reserved addresses, including boundaries.
    for (int a=4; a<=255; a+=29) begin
      write(a[7:0],8'ha5);
      read_expect(a[7:0],8'h00);
    end
    write(8'hff,8'hff);
    read_expect(8'h04,8'h00);
    read_expect(8'hff,8'h00);
    // PASS: all reserved fields/addresses read zero.
  endtask
endclass
