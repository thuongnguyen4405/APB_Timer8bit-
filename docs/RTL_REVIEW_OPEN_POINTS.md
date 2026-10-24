# Protected RTL — pre-simulation review and open questions

Source: Project 1 slides 182–190 and user screenshots (22 Oct 2026). The RTL `.vp` files are protected. **No internal implementation is assumed.**

| Topic | Confirmed by slide | Open / should be resolved by waveform or DUT owner |
|---|---|---|
| APB | APB slave, no wait, no error; address/data 8-bit | Is PRDATA combinational during ACCESS or registered at the completion edge? Monitor uses `#1ps` after edge. |
| `TCR.LOAD` | Writing `1` halts count and loads TDR | Is LOAD level-sensitive or edge-sensitive? Does it self-clear? TB asserts then explicitly clears before enabling. |
| Counter | 8-bit up/down; wrap triggers TSR bit | Are internal ticks phase-aligned with `ker_clk`? Timed tests use broad margin. |
| Clock divider | /1 /2 /4 /8 from 200 MHz kernel clock | Ratio check uses time between successive overflow flags with 30% tolerance. Confirm clock switching/phase. |
| TSR[1:0] | Hardware-set, W1C; 0→255 underflow; 255→0 overflow | Hardware set and APB clear in same clock? Set/clear priority undefined; these races are intentionally not checked. |
| Interrupt | TIE[1:0] enables sources | Pulse versus level, deassert after W1C, CDC latency unspecified; do not require immediate falling edge. |
| Reset | `presetn` is active low; default register values zero | Reset synchronizer / deassert latency unspecified; check after several pclk cycles. |
| CDC | PCLK 50 MHz, kernel CLK 200 MHz, divider output domain | APB config transfer into counter clock domain not documented; setup waits implicitly through APB transactions. |
| Counter observability | No counter port shown in top | No direct cycle-by-cycle reference counter checker possible; event-based and measured wrap period checks are black-box alternatives. |
| Protected file lists | RTL files named timer_register.vp, timer_clock_divisor.vp, timer_interrupt.vp, timer_counter.vp, timer_top.v | Questa must accept protected syntax and all RTL module names as shown in screenshots. |

## Hard blockers that must not be 'guessed away'

1. **Questa is not available in the file-creation runtime** and protected RTL bytes were not provided; compilation and simulation have not occurred. If the first build fails, preserve the full compiler log and fix against actual diagnostics.
2. **TCR.LOAD semantics** might differ from the chosen two-write sequence. Check with waveform after first smoke test before trusting counter/divider/IRQ tests.
3. **Timer output lacks counter value**. Internal counter-level checks require an approved probe or optional hierarchical access, and should not be faked with TDR reads (TDR is load data, not count value).
4. **Read sample timing** is fixed at APB ACCESS `posedge pclk + 1ps`. If DUT PRDATA settles at another time, use a clocking block/edge-aligned monitor based on observed protocol rather than manipulating DUT.
