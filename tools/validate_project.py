#!/usr/bin/env python3
from pathlib import Path
import re
root=Path(__file__).resolve().parents[1]
manifest=[v.strip() for v in (root/'docs/TEST_MANIFEST.txt').read_text().splitlines() if v.strip()]
assert len(manifest)==24 and len(set(manifest))==24
assert not list((root/'rtl').glob('*.vp'))
all_inc=re.findall(r'`include "([^"]+)"',(root/'testcase/test_pkg.sv').read_text())
assert all_inc==['base_test.sv']+[v+'.sv' for v in manifest]
for name in manifest:
    s=(root/'testcase'/f'{name}.sv').read_text()
    assert re.search(r'class\s+'+name+r'\s+extends\s+base_test',s),name
    assert 'run_scenario' in s and s.count('endclass')==1,name
    assert 'env.setup_timer' not in s and 'verify_event(' not in s,name
s=(root/'tb/testbench.sv').read_text()
selected=re.findall(r'^\s*"([a-z_0-9]+_test)"\s*:',s,re.M)
assert selected==manifest,(selected,manifest)
s=(root/'tb/environment.sv').read_text()
for disallowed in ('task setup_timer','task start_timer','task stop_timer','task wait_status','task clear_flags'):
    assert disallowed not in s,disallowed
assert 'stim.run()' in s and 'stim.send_pkt(p)' in s
sb=(root/'tb/scoreboard.sv').read_text()
assert 'mailbox #(packet) m2s_mb' in sb
assert 'timer_coverage' not in sb and 'coverage.sv' not in sb
assert '+TESTNAME' not in sb and 'SB_TRACE' not in sb
assert (root/'future/coverage.sv').exists()
for f in (root/'sim').glob('*.f'):
    for line in f.read_text().splitlines():
        if line.strip().startswith('../') and '/rtl/' not in line:
            assert (f.parent/line.strip()).exists(),line
assert '../tb/timer_apb_assertions.sv' not in (root/'sim/tb.f').read_text()
print('STATIC PASS: 24 Vplan names, 24 files, selection, explicit scenarios, filelists, no active coverage')
print('NOT VERIFIED: Questa compile / functional simulation against ICTC protected RTL')
