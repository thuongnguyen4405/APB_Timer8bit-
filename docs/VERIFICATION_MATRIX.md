# VPlan 4 sections — exact Testname mapping (03-Nov-2026)

Each Excel Testname has exactly one `testcase/<Testname>.sv`, and each contains its own `run_scenario()` with explicit APB setup, enable/poll/clear and PASS checks.

**Verification status: NOT RUN on protected RTL.**

| Section | Testname | Method |
|---|---|---|
| Register | `register_reset_test` | Directed |
| Register | `register_rw_test` | Directed |
| Register | `register_reset_on_fly_test` | Directed |
| Register | `reserved_fields_address_test` | Directed |
| Register | `tsr_w1c_test` | Directed |
| Register | `tsr_selective_clear_test` | Directed |
| Register | `random_register_access_test` | Constrained-Random |
| Clock Divisor | `clock_div1_test` | Directed |
| Clock Divisor | `clock_div2_test` | Directed |
| Clock Divisor | `clock_div4_test` | Directed |
| Clock Divisor | `clock_div8_test` | Directed |
| Counter | `counter_load_test` | Directed |
| Counter | `timer_enable_disable_test` | Directed |
| Counter | `counter_count_up_test` | Directed |
| Counter | `counter_count_down_test` | Directed |
| Counter | `counter_overflow_test` | Directed |
| Counter | `counter_underflow_test` | Directed |
| Counter | `random_counter_config_test` | Constrained-Random |
| Interrupt | `overflow_interrupt_test` | Directed |
| Interrupt | `underflow_interrupt_test` | Directed |
| Interrupt | `interrupt_mask_test` | Directed |
| Interrupt | `irq_enable_independence_test` | Directed |
| Interrupt | `status_polling_test` | Directed |
| Interrupt | `random_irq_mask_test` | Constrained-Random |

**Limits:** Counter internal state is not exposed; LOAD and count-up/down are checked using external status events and timing proxies, not per-cycle internal counter values. Divider checks use broad APB-polling-based wrap timing, not exact duty-cycle checks. The TCR LOAD bit is explicitly cleared by software because self-clear is not specified. IRQ check uses observed rising edges, not pulse/level width.
