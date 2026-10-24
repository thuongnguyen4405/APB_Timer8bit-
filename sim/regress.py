#!/usr/bin/env python3
"""Small deterministic regression harness for Questa, without replacing ICTC regress.pl."""
import argparse, pathlib, subprocess, csv, re, datetime, sys

ROOT = pathlib.Path(__file__).resolve().parent
NAMES = re.findall(r'^\s*"([a-z_0-9]+_test)"',
                   (ROOT/'../tb/testbench.sv').read_text(),re.M)

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--build',action='store_true')
    parser.add_argument('--quick',action='store_true',help='run a small smoke subset')
    parser.add_argument('--seeds',type=int,default=1)
    args=parser.parse_args()
    if args.build:
        proc=subprocess.run(['make','-f','Makefile.dv','build'],cwd=ROOT)
        if proc.returncode: return proc.returncode
    names=NAMES if not args.quick else [
       'register_reset_test','register_rw_test','tsr_w1c_test',
       'counter_overflow_test','overflow_interrupt_test','underflow_interrupt_test']
    rows=[]
    for name in names:
        count=args.seeds if name.startswith('random_') else 1
        for seed in range(1,count+1):
            print(f'### Running {name} seed={seed}',flush=True)
            p=subprocess.run(['make','-f','Makefile.dv','run',f'TESTNAME={name}',f'SEED={seed}'],cwd=ROOT)
            log=ROOT/'log'/f'{name}_{seed}.log'
            content=log.read_text(errors='replace') if log.exists() else ''
            status='PASS' if p.returncode==0 and f'TEST PASSED {name}' in content and 'TEST FAILED' not in content else 'FAIL'
            rows.append((name,seed,status,p.returncode))
    output=ROOT/'log'/'regression_summary.csv'
    with output.open('w',newline='') as fp:
        w=csv.writer(fp); w.writerow(['testname','seed','status','exit_code']); w.writerows(rows)
    passes=sum(r[2]=='PASS' for r in rows)
    print(f'REGRESSION {passes}/{len(rows)} PASSED; report={output}')
    return 0 if passes==len(rows) else 1

if __name__=='__main__': sys.exit(main())
