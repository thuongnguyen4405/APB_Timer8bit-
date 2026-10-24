// Shared transaction used by Stimulus, Driver, Monitor and Scoreboard.
// This file is included INSIDE timer_pkg.sv.
typedef enum bit {APB_WRITE, APB_READ} apb_op_e;

class packet;
    rand bit [7:0] addr;
    rand bit [7:0] data;
    rand apb_op_e op;
    logic [7:0] rdata;
    time issue_time; // timestamp filled by Monitor
    event done;                  // Driver signals APB transfer completion

    function new();
    endfunction
endclass

// Random configurations for Counter and Interrupt tests.
class timer_random_cfg;
    rand bit [7:0] init_value;
    rand bit [1:0] divider;
    rand bit down;
    rand bit [1:0] irq_mask;

    // Prefer boundary values to exercise overflow/underflow.
    // ':/' gives the WHOLE middle range a weight of 40.
    constraint boundary_c {
        init_value dist {
            8'h00 := 10,
            8'h01 := 10,
            [8'h02:8'hfd] :/ 40,
            8'hfe := 10,
            8'hff := 10
        };
    }
endclass
