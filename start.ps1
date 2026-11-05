$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Python = Join-Path $ProjectRoot ".venv\Scripts\python.exe"

if (-not (Test-Path $Python)) {
    if (-not (Get-Command py -ErrorAction SilentlyContinue)) {
        Write-Error "Python 3 was not found. Install Python 3.10 or newer, then run this script again."
        Read-Host "Press Enter to close"
        return
    }
    & py -3.13 -m venv (Join-Path $ProjectRoot ".venv")
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Python 3.13 was not available; trying the default Python 3 installation."
        & py -3 -m venv (Join-Path $ProjectRoot ".venv")
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Could not create the Python environment."
            Read-Host "Press Enter to close"
            return
        }
    }
}

Set-Location $ProjectRoot
& $Python -m pip install --disable-pip-version-check -r requirements.txt
if ($LASTEXITCODE -ne 0) {
    Write-Error "Dependency installation failed. Read the error above."
    Read-Host "Press Enter to close"
    return
}
Write-Host "Website: http://127.0.0.1:8000"
Write-Host "Leave this window open while using the website. Press Ctrl+C to stop it."
& $Python -m uvicorn app.main:app --reload --port 8000
