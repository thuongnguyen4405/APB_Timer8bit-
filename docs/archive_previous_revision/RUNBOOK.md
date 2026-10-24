> NOTE: earlier revision; for this simplified edition, see WHAT_CHANGED.md and COVERAGE_LATER.md.

# RUNBOOK

## Install safely

1. Copy the ZIP onto the ICTC remote if allowed; if remote transfer is blocked, copy code per file using the screenshots/source snippets.
2. Unzip and inspect `docs/COMPONENT_CHANGELOG.md`.
3. Run `./install_into_ictc_project.sh ~/project_dva/project1` — installer backups existing TB/testcase/sim files and never touches `.vp`.
4. `cd ~/project_dva/project1/sim && source project_env.bash`
5. `make -f Makefile.dv build`
6. `make -f Makefile.dv run TESTNAME=register_reset_test SEED=1`
7. `make -f Makefile.dv run TESTNAME=counter_overflow_test SEED=1`
8. `python3 regress.py --quick` then full regression after smoke PASS.

Do not label a testcase PASS unless Questa against the real protected DUT produces success without errors.
