> NOTE: earlier revision; for this simplified edition, see WHAT_CHANGED.md and COVERAGE_LATER.md.

# COMPONENT CHANGELOG — READ BEFORE INSTALLING ON REMOTE

## Environment (`tb/environment.sv`) — MODIFIED
- Class is now `environment` (matching user's manually edited remote code).
- Retained `new`, `start`, `apb_write`, `apb_read`, `expect_bit`, `expect_mask`, `reset_dut`, `check_no_errors`.
- Removed scenario helpers: `stop_timer`, `setup_timer`, `start_timer`, `wait_status`, `clear_flags`.
- Added `stim.run()` to start fork, as required by user's queue-based stimulus.
- Changed stimulus invocation to `stim.send_pkt(p)` (NOT `stim.send(p)`).
- `coverage` remains inside `scoreboard.sv`, not instantiated in environment.

## Other components
- `tb/stimulus.sv` MODIFIED: class `stimulus`, queue + `send_pkt()` + `run()`; waits for `pkt.done`.
- `tb/packet.sv` MODIFIED: class `packet` (was timer_packet); random config supports full 8-bit initial values.
- `tb/driver.sv` MODIFIED NAMES ONLY: class `driver` and mailbox of `packet`; APB negedge setup/access logic unchanged.
- `tb/monitor.sv` MODIFIED NAMES ONLY: class `monitor`; observed transaction + IRQ monitor unchanged.
- `tb/scoreboard.sv` MODIFIED NAMES ONLY: class `scoreboard`; W1C not modeled as ordinary RW, and functional coverage remains inside scoreboard.
- `tb/timer_pkg.sv` UPDATED include order to user's ICTC template.
- `testcase/base_test.sv` MODIFIED: only common build/run/reset/check, plus `read_expect`; removed `verify_event` and `require_status`.
- `testcase/*.sv` REWRITTEN: 24 individual tests, with exact Excel Vplan names; no shared `clock_divisor_base_test` scenario.
- `testcase/test_pkg.sv`, `tb/testbench.sv` UPDATED: compile-one/run-many polymorphism, 24 matching names.
- `sim/tb.f` UPDATED: standalone APB assertions module is OPTIONAL and excluded from default compile.
- `tb/timer_apb_assertions.sv` RETAINED as opt-in, not instantiated.
- Protected RTL files `.vp`: NEVER INCLUDED OR MODIFIED. Original ICTC Makefile / regress.pl remain untouched.

**Important:** The ZIP is self-consistent. If the remote contains a hand-edited `environment.sv`, `packet.sv` or stimulus classes, do not mix files from different versions. Backup first and install this package together, or manually adapt all class names and task calls.
