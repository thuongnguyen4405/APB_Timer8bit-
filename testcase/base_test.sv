// Base test: creates APB packets and sends them to Stimulus.
// Each testcase overrides run_scenario() with its own test steps.
class base_test;
    virtual dut_if vif;
    environment env;
    string test_name;

    function new(virtual dut_if v, string name = "base_test");
        vif = v;
        test_name = name;
    endfunction

    function void build();
        env = new(vif);
    endfunction

    // APB WRITE: create a packet, then let Stimulus/Driver handle the bus.
    task write(bit [7:0] addr, bit [7:0] data);
        packet pkt = new();
        pkt.op   = APB_WRITE;
        pkt.addr = addr;
        pkt.data = data;
        env.stim.send_pkt(pkt);
    endtask

    // APB READ: Driver fills pkt.rdata before pkt.done is triggered.
    task read(bit [7:0] addr, output logic [7:0] data);
        packet pkt = new();
        pkt.op   = APB_READ;
        pkt.addr = addr;
        env.stim.send_pkt(pkt);
        data = pkt.rdata;
    endtask

    // Small helper used by register tests. Expected value comes from testcase.
    task read_expect(bit [7:0] addr,
                     bit [7:0] want,
                     bit [7:0] mask = 8'hff);
        logic [7:0] actual;
        read(addr, actual);
        env.expect_mask($sformatf("READ addr=%02h", addr),
                        actual, want, mask);
    endtask

    // Must be overridden by each testcase.
    virtual task run_scenario();
        $fatal(1, "run_scenario() not implemented for %s", test_name);
    endtask

    task run_test();
        $display("[TEST] START %s", test_name);
        build();
        env.start();
        env.reset_dut();
        run_scenario();
        repeat (3) @(posedge vif.pclk);
        env.check_no_errors(test_name);
    endtask
endclass
