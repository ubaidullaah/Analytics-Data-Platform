# PowerShell script to clear Git credentials
Write-Host "Clearing Git credentials..." -ForegroundColor Yellow

# Try to clear using Git Credential Manager
Write-Host "`nAttempting to clear credentials..." -ForegroundColor Cyan

# List current credentials
Write-Host "`nCurrent Git-related credentials:" -ForegroundColor Yellow
cmdkey /list | Select-String "git" | ForEach-Object { Write-Host $_ }

Write-Host "`nTo manually delete credentials:" -ForegroundColor Green
Write-Host "1. Press Windows Key + R" -ForegroundColor White
Write-Host "2. Type: control /name Microsoft.CredentialManager" -ForegroundColor White
Write-Host "3. Go to 'Windows Credentials'" -ForegroundColor White
Write-Host "4. Delete any entries containing 'github.com' or 'ubaidusman-eng'" -ForegroundColor White
Write-Host "`nOr use a Personal Access Token when pushing (recommended)" -ForegroundColor Green

