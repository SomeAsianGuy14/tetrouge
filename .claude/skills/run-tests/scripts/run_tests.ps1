param(
    [string]$GodotPath = ""
)

# Auto-discover Godot executable
if (-not $GodotPath) {
    $fromPath = (Get-Command "godot.exe" -ErrorAction SilentlyContinue)
    $candidates = @(
        $(if ($fromPath) { $fromPath.Source } else { $null }),
        "$env:USERPROFILE\bin\godot.exe"
    ) | Where-Object { $_ -and (Test-Path $_) }
    $GodotPath = $candidates | Select-Object -First 1
}
if (-not $GodotPath) {
    Write-Error "Godot not found. Put godot.exe on PATH or pass -GodotPath."
    exit 1
}

# Resolve game directory relative to this script (4 levels up from scripts/ to repo root, then game/)
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")
$gameDir  = Join-Path $repoRoot "game"

Write-Host "Godot:   $GodotPath"
Write-Host "Project: $gameDir"
Write-Host ""

# Run via Start-Process to correctly capture stdout + stderr separately and get exit code
$tempOut = [System.IO.Path]::GetTempFileName()
$tempErr = [System.IO.Path]::GetTempFileName()

try {
    $proc = Start-Process $GodotPath `
        -ArgumentList "--headless", "--path", $gameDir, "res://tests/run_tests_headless.tscn" `
        -RedirectStandardOutput $tempOut `
        -RedirectStandardError  $tempErr `
        -Wait -NoNewWindow -PassThru

    $exitCode = $proc.ExitCode

    # Godot writes its output to stderr; stdout is usually empty
    $stdout = if (Test-Path $tempOut) { Get-Content $tempOut -Raw } else { "" }
    $stderr = if (Test-Path $tempErr) { Get-Content $tempErr -Raw } else { "" }
    $combined = ($stderr + $stdout).TrimEnd()

    # Strip ANSI/VT escape codes
    $combined = [regex]::Replace($combined, '\x1b\[[0-9;]*[mGKHF]', '')

    Write-Host $combined
} finally {
    Remove-Item $tempOut, $tempErr -ErrorAction SilentlyContinue
}

Write-Host ""
if ($exitCode -eq 0) {
    Write-Host "GUT_RESULT: PASS  (all tests passed)"
} else {
    Write-Host "GUT_RESULT: FAIL  ($exitCode failing test(s))"
}

exit $exitCode
