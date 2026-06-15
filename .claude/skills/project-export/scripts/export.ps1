# Export Tetrouge and publish to GitHub + itch.io
# Usage: .\export.ps1 [-Version "0.2.3"] [-GodotPath "C:\path\to\godot.exe"] [-ItchUser "user"] [-ItchGame "slug"]
# If -Version is omitted, the version is read from game/project.godot automatically.

param(
    [string]$GodotPath = "",
    [string]$Version   = "",
    [string]$ItchUser  = "SomeAsianGuy14",
    [string]$ItchGame  = "tetrouge"
)

$ErrorActionPreference = "Stop"

# ── Resolve repo root (works wherever this script lives) ───────────────────
$RepoRoot = git -C $PSScriptRoot rev-parse --show-toplevel 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Could not find git repo root from '$PSScriptRoot'. Is this a git repository?"
    exit 1
}
$RepoRoot = $RepoRoot.Trim()

$ProjectDir = Join-Path $RepoRoot "game"
$BuildsDir  = Join-Path $RepoRoot "builds"
$WinDir     = Join-Path $BuildsDir "windows"
$WebDir     = Join-Path $BuildsDir "web"
$DistDir    = Join-Path $RepoRoot "dist"

# ── Resolve Godot executable ───────────────────────────────────────────────
if (-not $GodotPath) {
    if (Get-Command godot -ErrorAction SilentlyContinue) {
        $GodotPath = "godot"
    } else {
        $LocalGodot = "$env:USERPROFILE\bin\godot.exe"
        if (Test-Path $LocalGodot) {
            $GodotPath = $LocalGodot
        } else {
            Write-Error "Godot not found. Add godot to PATH or pass -GodotPath 'C:\path\to\godot.exe'."
            exit 1
        }
    }
}
Write-Host "Godot: $GodotPath"

# ── Resolve and validate version ───────────────────────────────────────────
$GodotProjectFile = Join-Path $ProjectDir "project.godot"
$ProjectVersion = (Select-String -Path $GodotProjectFile -Pattern 'config/version="(.+)"').Matches[0].Groups[1].Value

if (-not $Version) {
    $Version = $ProjectVersion
    Write-Host "Version (from project.godot): $Version"
} elseif ($Version -ne $ProjectVersion) {
    Write-Error "Version mismatch: -Version '$Version' != project.godot '$ProjectVersion'. Update project.godot first."
    exit 1
}

# ── Extract release notes from CHANGELOG.md ────────────────────────────────
$ChangelogFile = Join-Path $RepoRoot "CHANGELOG.md"
$VerEscaped    = [regex]::Escape($Version)
$InVersion     = $false
$NotesLines    = [System.Collections.Generic.List[string]]::new()

foreach ($line in (Get-Content $ChangelogFile)) {
    if ($line -match "^## \[$VerEscaped\]") {
        $InVersion = $true
        continue
    }
    if ($InVersion) {
        if ($line -match "^---$") { break }
        $NotesLines.Add($line)
    }
}

if ($NotesLines.Count -gt 0) {
    $ReleaseNotes = ($NotesLines -join "`n").Trim()
    Write-Host "Release notes: extracted from CHANGELOG.md."
} else {
    $ReleaseNotes = "See CHANGELOG.md for details."
    Write-Warning "No changelog entry found for v$Version — using placeholder notes."
}

# Warn if Unreleased block still exists (forgotten to promote)
if (Select-String -Path $ChangelogFile -Pattern "^## Unreleased" -Quiet) {
    Write-Warning "CHANGELOG.md still has an '## Unreleased' block. Did you forget to promote it to [$Version]?"
}

# ── Resolve gh CLI ─────────────────────────────────────────────────────────
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    $env:PATH += ";C:\Program Files\GitHub CLI"
}

# ── Resolve butler ─────────────────────────────────────────────────────────
$ButlerCmd = "butler"
if (-not (Get-Command butler -ErrorAction SilentlyContinue)) {
    $ButlerLocal = "$env:USERPROFILE\bin\butler.exe"
    if (Test-Path $ButlerLocal) {
        $ButlerCmd = $ButlerLocal
    } else {
        Write-Error "butler not found. Install from https://itchio.itch.io/butler"
        exit 1
    }
}

# ── Prepare output directories ─────────────────────────────────────────────
Write-Host "Preparing build directories..."
New-Item -ItemType Directory -Force $WinDir | Out-Null
New-Item -ItemType Directory -Force $WebDir | Out-Null
New-Item -ItemType Directory -Force $DistDir | Out-Null

# ── Export Windows ─────────────────────────────────────────────────────────
Write-Host "Exporting Windows build..."
& $GodotPath --headless --path $ProjectDir --export-release "Windows Desktop" "$WinDir\TR.exe" 2>&1
if (-not (Test-Path "$WinDir\TR.exe")) {
    Write-Error "Windows export failed — TR.exe not found."
    exit 1
}

# ── Export Web ─────────────────────────────────────────────────────────────
Write-Host "Exporting Web build..."
& $GodotPath --headless --path $ProjectDir --export-release "Web" "$WebDir\index.html" 2>&1
if (-not (Test-Path "$WebDir\index.html")) {
    Write-Error "Web export failed — index.html not found."
    exit 1
}

# Brief pause so the OS releases file handles on freshly-written web files
# before Compress-Archive tries to read them (prevents PermissionDenied).
Write-Host "Waiting for file handles to release..."
Start-Sleep -Seconds 3

# ── Zip artifacts ──────────────────────────────────────────────────────────
$Tag    = "v$Version"
$WinZip = Join-Path $DistDir "TR-$Tag-windows.zip"
$WebZip = Join-Path $DistDir "TR-$Tag-web.zip"

Write-Host "Zipping Windows build -> $WinZip"
Compress-Archive -Path "$WinDir\*" -DestinationPath $WinZip -Force

Write-Host "Zipping Web build -> $WebZip"
for ($attempt = 1; $attempt -le 5; $attempt++) {
    try {
        Compress-Archive -Path "$WebDir\*" -DestinationPath $WebZip -Force
        break
    } catch {
        if ($attempt -eq 5) { throw }
        Write-Host "Web zip locked, retrying in 3s... ($attempt/5)"
        Start-Sleep -Seconds 3
    }
}

# ── Tag and push to all remotes ────────────────────────────────────────────
Write-Host "Tagging $Tag..."
git -C $RepoRoot tag $Tag
git -C $RepoRoot push origin $Tag
git -C $RepoRoot push public $Tag

# ── Create GitHub release ──────────────────────────────────────────────────
Write-Host "Creating GitHub release $Tag..."
$NotesFile = [System.IO.Path]::GetTempFileName()
$ReleaseNotes | Out-File -FilePath $NotesFile -Encoding utf8
try {
    gh release create $Tag `
        --repo SomeAsianGuy14/tetrouge `
        --title "Tetrouge $Tag" `
        --notes-file $NotesFile `
        $WinZip $WebZip
} finally {
    Remove-Item $NotesFile -ErrorAction SilentlyContinue
}

# ── Push web build to itch.io ──────────────────────────────────────────────
Write-Host "Pushing web build to itch.io ($ItchUser/$ItchGame`:html)..."
& $ButlerCmd push $WebDir "$ItchUser/$ItchGame`:html" --userversion $Version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "itch.io push failed (exit $LASTEXITCODE)"
    exit 1
}

Write-Host ""
Write-Host "Done. Tetrouge $Tag published to GitHub and itch.io."
