

#  Project  — 8-bit Timer DV 

Non-UVM SystemVerilog | 24 cases | one compile, many `+TESTNAME` runs.

**Source**: ICTC Project 1 slides + `NguyenVanThuongVplan.xlsx`.
**Status**: source-level review complete; RTL `.vp` is NOT in this ZIP. No claim of Questa PASS.

## Read in this order

1. `tb/packet.sv`: one APB request/response (`packet`).
2. `tb/stimulus.sv`: packet queue -> `s2d_mb`.
3. `tb/driver.sv`: APB SETUP -> ACCESS -> idle, trigger `pkt.done`.
4. `tb/monitor.sv`: observe completed APB transfer -> `m2s_mb`.
5. `tb/scoreboard.sv`: simple register shadow model, compare readback.
6. `tb/environment.sv`: connect all components and provide APB tasks.
7. `testcase/base_test.sv`: common `build`, reset and finish check.
8. `testcase/*_test.sv`: explicit scenarios matching 24 VPlan rows.
9. `tb/testbench.sv`: **only place to read `+TESTNAME`**, select derived class.

## Running on ICTC server

```bash
# unzip, then run from unpacked project root:
bash install_into_ictc_project.sh ~/project_dva/project1
cd ~/project_dva/project1/sim
source project_env.bash  # if required by school shell
make -f Makefile.dv build
make -f Makefile.dv run TESTNAME=register_reset_test SEED=1
make -f Makefile.dv run TESTNAME=register_rw_test SEED=1
python3 regress.py --quick
python3 regress.py --seeds 3
```
example: make run TESTNAME=register_rw_test SEED=1
<img width="883" height="820" alt="image" src="https://github.com/user-attachments/assets/11a8eea6-799f-4f25-99c4-be6766e5478c" />

Compiler order from `sim/tb.f`: `dut_interface -> timer_pkg -> test_pkg -> testbench`.
Read `docs/WHAT_CHANGED.md` before copying over hand-edited server files.


