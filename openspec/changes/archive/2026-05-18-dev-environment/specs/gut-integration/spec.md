## ADDED Requirements

### Requirement: GUT addon installed and enabled
GUT SHALL be installed at `addons/gut/` within the Godot project and enabled as a plugin via `project.godot`. The installed version SHALL be compatible with Godot 4.6.

#### Scenario: GUT appears in editor plugins
- **WHEN** the project is opened in the Godot 4.6 editor
- **THEN** GUT appears in Project → Project Settings → Plugins as an enabled plugin

### Requirement: Test runner scene exists
A test runner scene SHALL exist at `res://tests/run_tests.tscn` that, when run, executes all test files in `tests/unit/` and prints results to the Godot output panel.

#### Scenario: Running test scene executes all tests
- **WHEN** `run_tests.tscn` is set as the main scene and the project is run
- **THEN** GUT discovers and runs all `test_*.gd` files under `tests/unit/` and prints a pass/fail summary

### Requirement: Headless CLI test run supported
A `.gutconfig.json` file SHALL exist at the project root configured so that running `godot --headless -s addons/gut/gut_cmdln.gd -gconfig=.gutconfig.json` from the `game/` directory executes all unit tests and exits with code 0 on success or non-zero on failure.

#### Scenario: Headless run exits with 0 on all passing
- **WHEN** all tests pass and the headless command is run
- **THEN** the process exits with code 0 and prints a summary to stdout

#### Scenario: Headless run exits non-zero on failure
- **WHEN** at least one test assertion fails
- **THEN** the process exits with a non-zero exit code

### Requirement: Test and addon directories excluded from exports
The directories `addons/gut/`, `tests/`, and `scenes/debug/` SHALL be listed in the export filter exclusion list so they are not included in HTML5 or Desktop release builds.

#### Scenario: Export does not include GUT
- **WHEN** an export build is produced
- **THEN** no files from `addons/gut/` or `tests/` appear in the output
