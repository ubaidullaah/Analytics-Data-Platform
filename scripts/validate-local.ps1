# Local validation script for Windows PowerShell
# Usage: .\scripts\validate-local.ps1

Write-Host "🔍 Running local CI validation checks..." -ForegroundColor Yellow
Write-Host ""

# Check if Python is available
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Python is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Check if pip is available
if (-not (Get-Command pip -ErrorAction SilentlyContinue)) {
    Write-Host "❌ pip is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
pip install -q -r requirements.txt 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Warning: Some dependencies may not be installed" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🔍 Running Python linting checks..." -ForegroundColor Yellow

# Black check
Write-Host "  - Running Black..." -ForegroundColor Cyan
black --check --diff Airflow/dags/
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ❌ Black check failed" -ForegroundColor Red
    exit 1
}
Write-Host "  ✅ Black check passed" -ForegroundColor Green

# isort check
Write-Host "  - Running isort..." -ForegroundColor Cyan
isort --check-only --diff Airflow/dags/
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ❌ isort check failed" -ForegroundColor Red
    exit 1
}
Write-Host "  ✅ isort check passed" -ForegroundColor Green

# Flake8 check
Write-Host "  - Running Flake8..." -ForegroundColor Cyan
flake8 Airflow/dags/ --max-line-length=120 --extend-ignore=E203,W503 --exclude=__pycache__
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ⚠️  Flake8 found some issues (non-blocking)" -ForegroundColor Yellow
} else {
    Write-Host "  ✅ Flake8 check passed" -ForegroundColor Green
}

Write-Host ""
Write-Host "🔍 Validating Airflow DAGs..." -ForegroundColor Yellow

# Check Python syntax
Write-Host "  - Checking Python syntax..." -ForegroundColor Cyan
Get-ChildItem -Path "Airflow/dags/*.py" | ForEach-Object {
    python -m py_compile $_.FullName
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ❌ Python syntax check failed for $($_.Name)" -ForegroundColor Red
        exit 1
    }
}
Write-Host "  ✅ Python syntax check passed" -ForegroundColor Green

Write-Host ""
Write-Host "🔍 Validating YAML files..." -ForegroundColor Yellow

# YAML linting
if (Get-Command yamllint -ErrorAction SilentlyContinue) {
    Write-Host "  - Running yamllint..." -ForegroundColor Cyan
    yamllint -d '{extends: default, rules: {line-length: {max: 200}}}' Airflow/docker-compose.yaml DBT_fintech_project/dbt_project.yml
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ⚠️  YAML linting found some issues (non-blocking)" -ForegroundColor Yellow
    } else {
        Write-Host "  ✅ YAML validation passed" -ForegroundColor Green
    }
} else {
    Write-Host "  ⚠️  yamllint not installed, skipping" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🔍 Validating DBT project..." -ForegroundColor Yellow

# DBT validation
if (Get-Command dbt -ErrorAction SilentlyContinue) {
    Write-Host "  - Checking DBT project structure..." -ForegroundColor Cyan
    Push-Location DBT_fintech_project
    dbt debug --target dev 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ⚠️  DBT debug requires Snowflake connection" -ForegroundColor Yellow
    }
    dbt list --target dev 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ⚠️  DBT list requires Snowflake connection" -ForegroundColor Yellow
    }
    Pop-Location
    Write-Host "  ✅ DBT validation completed" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  DBT not installed, skipping" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ All local validation checks completed!" -ForegroundColor Green
Write-Host ""
Write-Host "You can now push your changes with confidence." -ForegroundColor Cyan

