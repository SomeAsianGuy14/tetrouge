---
name: run-tests
description: Run the full GUT unit test suite to completion and fix any failing tests. Use when asked to run tests, check if tests pass, or verify a change didn't break anything.
---

## Overview

Runs every test in `game/tests/unit/` via GUT (Godot Unit Test) in headless mode, parses the results, and fixes any failures. Repeats until the suite is fully green or a blocker is reached.

## Step 1 — Run the suite

```powershell
# From anywhere in the repo
.\.claude\skills\run-tests\scripts\run_tests.ps1
```

Or, if you need to specify Godot explicitly:

```powershell
.\.claude\skills\run-tests\scripts\run_tests.ps1 -GodotPath "$env:USERPROFILE\bin\godot.exe"
```

The script:
- Auto-discovers Godot at `$env:USERPROFILE\bin\godot.exe` or on PATH
- Runs `godot.exe --headless --path game/ res://tests/run_tests_headless.tscn`
- Uses a minimal `Node` scene (`run_tests_headless.tscn`) so the project loads with autoloads, without the GUT GUI that hangs headlessly
- Strips ANSI color codes and prints all GUT output
- Exits with `0` when all tests pass; exits with the failure count otherwise
- Prints `GUT_RESULT: PASS` or `GUT_RESULT: FAIL (N failing test(s))` at the end

**Expected runtime:** 60–120 seconds for the full suite.

## Step 2 — Read the output

Scan the output for:

```
FAILED  <test_name>
   in <file>:<line>
   <assertion message>
```

The summary line near the end looks like:

```
Tests:  N  Passed:  N  Failed:  N  Pending:  N  Orphans: N
```

If `GUT_RESULT: PASS` — all done, no fixes needed.

If `GUT_RESULT: FAIL` — proceed to Step 3.

## Step 3 — Fix failures

For each failing test:

1. **Read the test file** — understand what the test expects.
2. **Determine root cause** — is it a broken test, or a broken implementation?
   - If the implementation changed and the test is still correct: fix the implementation.
   - If the test itself has a wrong assertion or stale expectation: fix the test.
   - Never delete a test to make it pass — fix the underlying problem.
3. **Apply the fix** — edit the relevant `.gd` file.
4. **Do not re-run yet** — batch all obvious fixes before the next run.

## Step 4 — Re-run

Repeat from Step 1. Continue until `GUT_RESULT: PASS`.

## Step 5 — Report

Once green, report:
- Total tests run
- Which tests were fixed (if any), and what was wrong
- If any test was skipped or left pending, note it

## Guardrails

- **Never `skip()` or comment out a test** to make it pass.
- **Never weaken an assertion** (e.g. changing `assert_eq` to `assert_true(true)`) — fix the real problem.
- If a failure is caused by a Godot engine bug or unrelated environment issue (not the code under test), pause and explain to the user rather than working around it.
- If the same test fails across 3 re-runs after fixes, pause and ask for guidance.
- `ERROR: BUG: Unreferenced static string` messages at shutdown are a known Godot 4.6 internal warning — they are **not test failures** and can be ignored.
- `WARNING: A Thread object is being destroyed without its completion` at shutdown is also a known Godot internal — ignore.

## Tip: isolating a single test file

GUT's `run_tests.gd` runs everything in `tests/unit/`. If you need to isolate one file, temporarily edit `run_tests.gd` to call `gut.add_script("res://tests/unit/test_foo.gd")` instead of `gut.add_directory(...)`. Restore it after debugging.
