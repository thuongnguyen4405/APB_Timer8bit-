# How to explain this verification environment in an interview

## Why this is NOT UVM
I used SystemVerilog classes, events, queues, mailboxes, inheritance and polymorphism
from ICTC Sessions 1–6. I did not use `uvm_*` macros or a UVM factory.

## Transaction flow
`testcase -> environment.apb_write/read -> stimulus.pkt_q -> s2d_mb -> Driver -> DUT`
`DUT -> Monitor -> m2s_mb -> Scoreboard`

## Handshake
A testcase calls `stim.send_pkt(pkt)`, which pushes to a queue and waits
for `pkt.done`. The Driver performs SETUP and ACCESS, returns bus to IDLE,
then triggers `->pkt.done`. Thus the read API only returns after the APB
transfer has completed.

## Scoreboard: what I can honestly claim
It checks APB readback of stable RW registers TCR, TDR and TIE.
It checks reserved fields are zero. It **does not** implement a complete
cycle-accurate Counter model, and does not model asynchronous TSR hardware flags.
Those are checked in directed scenarios using actual status/IRQ observations.

## Useful debug procedure
Compile -> confirm selected +TESTNAME -> watch Driver SETUP/ACCESS ->
inspect Monitor packet -> compare Scoreboard expected/actual -> read
waveform -> decide if DUT, TB sampling, or checker caused failure.
For randomized tests, record and replay `-sv_seed`.

## Scope honest limitations
Protected RTL is not available here. No actual DUT simulation result
is asserted by this project ZIP. Do not say '24/24 PASS' until regression.
