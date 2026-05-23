# Project: TR (Tetris Roguelite)

## Tech Stack
- Godot 4 (GDScript)
- GUT (Godot Unit Test) for automated testing

## Testing Requirements

**All code changes must include corresponding unit tests.**

- Test files live in `game/tests/unit/` and follow the naming convention `test_<module>.gd`
- All test files extend `GutTest`
- Run via `game/tests/run_tests.tscn`

### What to test
- Any pure function or deterministic logic (calculations, transformations, algorithms)
- Edge cases: empty inputs, boundary values, zero/max values
- State that must be preserved and restored (e.g. autoload fields like `RunState`, `Economy`)
- Anything the verification section of a tasks.md would otherwise require manual testing for

### What not to test
- Scene layout, visual appearance, or UI behaviour — test these manually
- Godot engine internals (signals firing, `queue_free` timing)
- Logic that requires a running `TetrisBoard` or full scene tree

### Conventions
- Use `before_each`/`after_each` to save and restore autoload state (`RunState`, `Economy`) so tests don't bleed into each other
- Test names describe the scenario: `test_seeded_shuffle_same_seed_produces_same_order`
- Group related tests under comment headers (`# ── Section ───`)
- Prefer multiple focused tests over one large test that checks many things
