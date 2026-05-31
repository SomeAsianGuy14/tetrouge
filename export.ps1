# Export TR v0.1.0 and create a GitHub release
# Usage: .\export.ps1 [-GodotPath "C:\path\to\godot.exe"]

param(
    [string]$GodotPath = "godot",
    [string]$Version = "0.1.0"
)

$ErrorActionPreference = "Stop"

# Add gh to PATH if not already present
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    $env:PATH += ";C:\Program Files\GitHub CLI"
}

$ProjectDir = Join-Path $PSScriptRoot "game"
$BuildsDir  = Join-Path $PSScriptRoot "builds"
$WinDir     = Join-Path $BuildsDir "windows"
$WebDir     = Join-Path $BuildsDir "web"
$DistDir    = Join-Path $PSScriptRoot "dist"

# ── Prepare output directories ─────────────────────────────────────────────
Write-Host "Preparing build directories..."
New-Item -ItemType Directory -Force $WinDir | Out-Null
New-Item -ItemType Directory -Force $WebDir | Out-Null
New-Item -ItemType Directory -Force $DistDir | Out-Null

# ── Export Windows ─────────────────────────────────────────────────────────
Write-Host "Exporting Windows build..."
& $GodotPath --headless --path $ProjectDir --export-release "Windows Desktop" "$WinDir\TR.exe" 2>&1
if (-not (Test-Path "$WinDir\TR.exe")) {
    Write-Error "Windows export failed - TR.exe not found"
    exit 1
}

# ── Export Web ─────────────────────────────────────────────────────────────
Write-Host "Exporting Web build..."
& $GodotPath --headless --path $ProjectDir --export-release "Web" "$WebDir\index.html" 2>&1
if (-not (Test-Path "$WebDir\index.html")) {
    Write-Error "Web export failed - index.html not found"
    exit 1
}

# ── Zip artifacts ──────────────────────────────────────────────────────────
$WinZip = Join-Path $DistDir "TR-v$Version-windows.zip"
$WebZip = Join-Path $DistDir "TR-v$Version-web.zip"

Write-Host "Zipping Windows build -> $WinZip"
Compress-Archive -Path "$WinDir\*" -DestinationPath $WinZip -Force

Write-Host "Zipping Web build -> $WebZip"
Compress-Archive -Path "$WebDir\*" -DestinationPath $WebZip -Force

# ── Tag and push ───────────────────────────────────────────────────────────
$Tag = "v$Version"
Write-Host "Tagging $Tag..."
git -C $PSScriptRoot tag $Tag
git -C $PSScriptRoot push origin $Tag

# ── Create GitHub release ──────────────────────────────────────────────────
Write-Host "Creating GitHub release $Tag..."
gh release create $Tag `
    --repo SomeAsianGuy14/tetrouge `
    --title "Tetrouge $Tag" `
    --notes "Initial public release." `
    $WinZip $WebZip


Write-Host "Done. Release $Tag published."
