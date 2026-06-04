# Export Tetrouge and publish to GitHub + itch.io
# Usage: .\export.ps1 [-Version "0.1.1"] [-GodotPath "C:\path\to\godot.exe"] [-ItchUser "username"] [-ItchGame "game-slug"]

param(
    [string]$GodotPath = "godot",
    [string]$Version = "0.2.1",
    [string]$ItchUser = "SomeAsianGuy14",
    [string]$ItchGame = "tetrouge"
)

$ErrorActionPreference = "Stop"

# Add gh to PATH if not already present
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    $env:PATH += ";C:\Program Files\GitHub CLI"
}

# Find butler
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


# ── Push web build to itch.io ──────────────────────────────────────────────
Write-Host "Pushing web build to itch.io ($ItchUser/$ItchGame:html)..."
& $ButlerCmd push $WebDir "$ItchUser/$ItchGame`:html" --userversion $Version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "itch.io push failed (exit $LASTEXITCODE)"
    exit 1
}

Write-Host "Done. Release $Tag published to GitHub and itch.io."
