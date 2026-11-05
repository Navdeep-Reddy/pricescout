@echo off
setlocal
set "PROJECT_ROOT=%~dp0"
set "PYTHON=%PROJECT_ROOT%.venv\Scripts\python.exe"

if not exist "%PYTHON%" (
  where py >nul 2>nul
  if errorlevel 1 goto no_python

  py -3.13 -m venv "%PROJECT_ROOT%.venv"
  if errorlevel 1 (
    echo Python 3.13 was not available. Trying the default Python 3 installation...
    py -3 -m venv "%PROJECT_ROOT%.venv"
    if errorlevel 1 goto setup_error
  )
)

cd /d "%PROJECT_ROOT%"
if errorlevel 1 goto setup_error

echo Installing or updating project dependencies. Keep this window open.
"%PYTHON%" -m pip install --disable-pip-version-check -r requirements.txt
if errorlevel 1 goto setup_error

echo.
echo Website: http://127.0.0.1:8000
echo Leave this window open while using the website. Press Ctrl+C to stop it.
"%PYTHON%" -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
echo.
echo The server has stopped. Press any key to close this window.
pause >nul
goto finish

:no_python
echo Python 3 was not found. Install Python 3.13, then run start.bat again.
goto wait_for_key

:setup_error
echo.
echo Startup failed. Read the error above, then share a screenshot if you need help.

:wait_for_key
pause

:finish
endlocal
