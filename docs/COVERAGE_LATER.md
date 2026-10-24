# Stage last: Functional Coverage, after all 24 tests pass

The ICTC slide calls coverage "Extra", so it is **disabled for now**.

## Why this architecture will support it later

- Each APB transaction received by Scoreboard is an **observed** transfer from Monitor.
- `packet` retains `addr`, `data`, `op`, and `rdata`.
- Config writes carry `TCR.clk_div[4:3]`, `TCR.count_down[1]`, and `TCR.timer_en[0]`.
- TIE writes carry mask `[1:0]`.
- TSR reads expose overflow `[0]` or underflow `[1]` events.
- Testbench `+TESTNAME` is independent of coverage collection.

## Later steps (DO NOT DO YET)

1. Move `future/coverage.sv` into `tb/`.
2. Include it at the beginning of `scoreboard.sv` (still inside timer_pkg).
3. Create a `timer_coverage cov;` instance in Scoreboard and `cov=new()` in `new()`.
4. Sample after `m2s_mb.get(pkt)` **only when a relevant transfer is observed**.
5. For config crossing, sample stable TCR writes with timer disabled and LOAD=0.
6. For event crossing, sample status[0]/status[1] from *observed TSR read* and last written TIE mask.
7. Add covergroups for cfg_div x direction, TIE x overflow/underflow.
8. Report actual numbers after sim; never assume 100% because 24 tests exist.

**Coverage limitation:** APB-level sampling cannot prove exact internal
`clk_in` divider duty cycle or unobservable Counter values. Need internal
probe or additional visibility for corresponding functional goals.
