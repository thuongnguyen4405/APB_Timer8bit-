// Functional coverage is extra credit in Project 1. Sampling occurs only
// after a scenario is configured/observed, not during randomize().
class timer_coverage;
  bit [1:0] div_sample, irq_sample;
  bit dir_sample;
  bit event_sample; // 0=overflow; 1=underflow
  covergroup cg_cfg;
    option.per_instance=1;
    cp_div : coverpoint div_sample {bins div1={0}; bins div2={1}; bins div4={2}; bins div8={3};}
    cp_dir : coverpoint dir_sample {bins up={0}; bins down={1};}
    div_x_dir : cross cp_div,cp_dir;
  endgroup
  covergroup cg_irq;
    option.per_instance=1;
    cp_mask : coverpoint irq_sample {bins disabled={0}; bins ovf={1}; bins udf={2}; bins both={3};}
    cp_event: coverpoint event_sample {bins overflow={0}; bins underflow={1};}
    mask_x_event : cross cp_mask,cp_event;
  endgroup
  function new(); cg_cfg=new(); cg_irq=new(); endfunction
  function void sample_cfg(bit [1:0] d, bit down);
    div_sample=d; dir_sample=down; cg_cfg.sample();
  endfunction
  function void sample_irq(bit [1:0] m, bit event_type);
    irq_sample=m; event_sample=event_type; cg_irq.sample();
  endfunction
endclass
