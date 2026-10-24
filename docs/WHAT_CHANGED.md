# What to change on your remote server

This document compares your uploaded `Timer8_DV_VPlan_24_Explicit_Testcases_Refactor(1).zip`
with the simplified version.

## ACTIVE components to copy (changed)

| Component | Change | Why |
| --- | --- | --- |
| `tb/packet.sv` | Use one `packet` class, package-scope enum, no unused `clone()`; keep `timer_random_cfg` with simple boundary bias | Less code and avoids `timer_packet` name errors; CRV eventually reaches boundaries |
| `tb/stimulus.sv` | Queue -> mailbox flow stays; only `send_pkt` waits for `pkt.done` | Avoid redundant waits, still synchronous from each testcase |
| `tb/scoreboard.sv` | **REWRITTEN**: basic shadow registers, direct `[n]` checks, no coverage | Easy to explain and debug |
| `tb/timer_pkg.sv` | Include only 6 active components, correct order and 1ps precision | No accidental early coverage |
| `tb/environment.sv` | Minimal edits, constructors use explicit `p=new()` and remove coverage comment | Build with consistent class names |
| `tb/driver.sv` | Comment edits only | Same APB timing and handshake |
| `tb/monitor.sv` | Comment edits only | Same APB capture and IRQ rise counter |

## Cases to copy (changed)

| Test | Change | Why |
| --- | --- | --- |
| `tsr_w1c_test.sv` | Adds independent underflow W1C check | VPlan 1.5 explicitly requires both events |
| `register_reset_on_fly_test.sv` | Waits for real overflow before reset | VPlan 1.3 requires pending event during reset |
| `timer_enable_disable_test.sv` | Loads `8'h20`, verifies disabled over > nominal wrap time | Matches VPlan 3.2 |
| `random_register_access_test.sv` | Balanced address categories using `dist` | Avoid randomizing mostly reserved addresses |
| `random_irq_mask_test.sv` | Constrain start near FE/FF or 00/01 | Match VPlan 4.6 and observe event sooner |

## Other files

- `testcase/base_test.sv`: wording only.
- Other **19** testcase `.sv` files: scenario preserved, not rewritten with helper abstractions.
- `tb/testbench.sv`, `testcase/test_pkg.sv`, `tb/dut_interface.sv`: preserved.
- `sim/regress.cfg`: replaced wrong old test names with 24 actual case names.
- `sim/Makefile.dv`: simpler build and run flow; no coverage switches until coverage is implemented.
- `future/coverage.sv`, `future/timer_apb_assertions.sv`: kept as future examples, not included by default.
- `rtl/` encrypted `.vp`: **never modified and not included**.
- Existing server `Makefile`, `regress.pl`, `project_env.bash`: **not modified**.

**IMPORTANT:** the install script backups files and copies active `.sv` files,
but it does not delete old `tb/coverage.sv` or `tb/timer_apb_assertions.sv`
on the server. Those may remain **unused**, since neither is included or instantiated.

To avoid mixing versions, do not copy only the Scoreboard and leave an old
`timer_pkg`/`environment` with unknown references. Install as a set.
