`timescale 1ns/1ps
// Black-box APB protocol checks from Session 6 SVA.
// These only check requirements explicitly supported by Project 1 slides.
module timer_apb_assertions(
  input logic pclk, presetn, psel, penable, pready, pwrite,
  input logic [7:0] paddr, pwdata
);
  // No wait states: the APB ACCESS completes immediately.
  property p_no_wait;
    @(posedge pclk) disable iff (!presetn)
    (psel && penable) |-> (pready === 1'b1);
  endproperty
  apb_no_wait_a: assert property(p_no_wait)
    else $fatal(1,"[TEST FAILED][SVA] APB ACCESS not ready");

  // A valid SETUP must be followed by ACCESS, holding its parameters.
  // SETUP->ACCESS is a contract imposed on OUR APB driver as well.
  property p_setup_to_access;
    @(posedge pclk) disable iff (!presetn)
    (psel && !penable) |=>
      (psel && penable &&
       $stable(paddr) && $stable(pwrite) && $stable(pwdata));
  endproperty
  apb_setup_access_a: assert property(p_setup_to_access)
    else $fatal(1,"[TEST FAILED][SVA] APB SETUP/ACCESS sequence or stability violation");
endmodule
