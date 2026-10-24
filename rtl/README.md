# DUT files are deliberately absent

Use the ICTC-provided encrypted modules in your existing remote project:

- `timer_register.vp`
- `timer_clock_divisor.vp`
- `timer_interrupt.vp`
- `timer_counter.vp`
- `timer_top.v`

We do not decrypt or reconstruct protected RTL. The installer never writes into `rtl/`.
