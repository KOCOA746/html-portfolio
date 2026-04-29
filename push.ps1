$ErrorActionPreference = "Stop"

$message = if ($args.Count -gt 0) { $args -join " " } else { "Update site files" }

function Run($command, $arguments) {
  & $command @arguments
  if ($LASTEXITCODE -ne 0) {
    throw "$command failed with exit code $LASTEXITCODE"
  }
}

if (Test-Path ".\scripts\update-html-manifest.ps1") {
  powershell -NoProfile -ExecutionPolicy Bypass -File ".\scripts\update-html-manifest.ps1"
}

Run git @("status", "--short")
Run git @("add", "-A")

$staged = git diff --cached --name-only
if (-not $staged) {
  Write-Host "No changes to push."
  exit 0
}

Run git @("commit", "-m", $message)
Run git @("push", "origin", "main")

Write-Host "Pushed to GitHub."
