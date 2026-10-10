$ErrorActionPreference = "Stop"

Write-Host "=== Food Diary Flutter + Supabase setup ===" -ForegroundColor Cyan

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw "Flutter is not on PATH. Install Flutter and reopen PowerShell."
}

if (-not (Test-Path "android") -or -not (Test-Path "web")) {
  Write-Host "Generating Flutter platform folders..." -ForegroundColor Yellow
  flutter create .
}

flutter pub get

Write-Host ""
Write-Host "Next: run the Supabase SQL migration in:" -ForegroundColor Green
Write-Host "  supabase/migrations/0001_food_diary.sql"
Write-Host ""
Write-Host "Then start the local web app:" -ForegroundColor Green
Write-Host "  flutter run -d chrome --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY"
