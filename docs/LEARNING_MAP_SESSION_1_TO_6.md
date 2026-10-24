> NOTE: earlier revision; for this simplified edition, see WHAT_CHANGED.md and COVERAGE_LATER.md.

# Which concepts have you already learned? (ICTC sessions 1–6)

| Session | Concept | Real file here |
|---|---|---|
| SS1 | `logic`, `enum`, arrays | `tb/packet.sv`, `tb/dut_interface.sv` |
| SS2 | task/function, `fork...join_none`, mailbox/event | `tb/environment.sv`, `tb/stimulus.sv`, `tb/driver.sv` |
| SS3 | `class`, `new`, interface / virtual interface | `tb/packet.sv`, `tb/dut_interface.sv` |
| SS4 | `extends`, virtual override / polymorphism | `testcase/base_test.sv`, `testcase/*_test.sv`, `testcase/test_pkg.sv` |
| SS5 | `rand`, `constraint`, `randomize() with` | `tb/packet.sv`, `testcase/random_*_test.sv` |
| SS6 | concurrent assertions, covergroups | `tb/timer_apb_assertions.sv`, `tb/coverage.sv` |

This project deliberately uses neither UVM macros nor UVM sequences/agents.

## Where to edit when writing a new testcase

1. Create `testcase/my_new_test.sv` with `class my_new_test extends base_test; ... endclass`.
2. In `testcase/test_pkg.sv`, add `include "my_new_test.sv"` after `base_test.sv`. Add a `case` branch in `tb/testbench.sv`: construct `my_new_test` and assign it to the `base_test` handle.
3. Run `make -f Makefile.dv build` once, then `make -f Makefile.dv run TESTNAME=my_new_test SEED=1`.
4. After directed passes, add `rand` fields and inline constraints to make CRV meaningful.
5. Add the test to `docs/VERIFICATION_MATRIX.md` / Excel Vplan; never mark PASS without transcript evidence.
