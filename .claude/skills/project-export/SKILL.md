---
name: project-export
description: Run the export process to push the latest version of the project to the public repository. Use when asked to export the latest version of the project for public release.
---

## Overview

Builds Windows and Web releases, pushes a git tag to all remotes, creates a GitHub release, and deploys the web build to itch.io. The script reads the version from `game/project.godot` and the release notes from `CHANGELOG.md` automatically — no edits to the script are needed between releases.

## Pre-export checklist

These must be done and committed **before** running the script:

1. **Bump version** in `game/project.godot` — change `config/version = "X.Y.Z"`
2. **Promote CHANGELOG** — rename `## Unreleased` to `## [X.Y.Z] — YYYY-MM-DD`
3. **Commit everything** to `main` and push to both remotes (`git push origin main && git push public main`)

The script will error if the version in `project.godot` doesn't match `-Version`, and will warn if an `## Unreleased` block still exists in the changelog.

## Running the export

```powershell
# From the repo root or any subdirectory — the script resolves paths from the git root
.\.claude\skills\project-export\scripts\export.ps1
```

No arguments needed for a standard release. The script will:
- Auto-detect the version from `game/project.godot`
- Auto-extract release notes from the matching `## [X.Y.Z]` block in `CHANGELOG.md`
- Auto-discover Godot at `$env:USERPROFILE\bin\godot.exe` if not on PATH
- Export Windows and Web builds to `builds/`
- Zip both to `dist/`
- Push the git tag to both `origin` (TR-Rouge) and `public` (tetrouge) remotes
- Create a GitHub release on `SomeAsianGuy14/tetrouge` with both zips attached
- Push the web build to itch.io via butler

## Optional parameters

| Parameter | Default | Notes |
|-----------|---------|-------|
| `-Version` | read from `project.godot` | If passed, must match `project.godot` or the script errors |
| `-GodotPath` | auto-discovered | Falls back to `$env:USERPROFILE\bin\godot.exe`; pass explicitly if needed |
| `-ItchUser` | `SomeAsianGuy14` | itch.io username |
| `-ItchGame` | `tetrouge` | itch.io game slug |

## Error recovery

**Web zip fails (PermissionDenied on index.js):**
The OS or antivirus held a lock on the freshly-written web files. Wait a few seconds and re-zip manually:
```powershell
Compress-Archive -Path "builds\web\*" -DestinationPath "dist\TR-vX.Y.Z-web.zip" -Force
gh release upload vX.Y.Z "dist\TR-vX.Y.Z-web.zip" --repo SomeAsianGuy14/tetrouge
```

**GitHub release missing (tag not on `public` remote):**
```powershell
git push public vX.Y.Z
# Then re-run gh release create, or upload missing zips with gh release upload
```

**itch.io push fails:** Check that butler is authenticated (`butler login`) and retry:
```powershell
butler push builds\web SomeAsianGuy14/tetrouge:html --userversion X.Y.Z
```
