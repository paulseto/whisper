@echo off
setlocal

:: Optional first parameter: model size (default turbo). Examples: turbo, medium, large-v2
if "%~1"=="" (
    set MODEL_SIZE=turbo
) else (
    set MODEL_SIZE=%~1
)

:: Build number in format YYYYMMDD-HHMM
for /f "usebackq" %%t in (`powershell -NoProfile -Command "Get-Date -Format 'yyyyMMdd-HHmm'"`) do set BUILD_NUMBER=%%t

echo Building whisper-ctranslate2 (model: %MODEL_SIZE%, build %BUILD_NUMBER%) for current platform...
docker build --no-cache --build-arg MODEL_SIZE=%MODEL_SIZE% ^
  --tag whisper:latest ^
  --tag whisper:%BUILD_NUMBER% .
if %errorlevel% neq 0 (
    echo Build failed.
    exit /b %errorlevel%
)
echo Done. Image whisper:latest and whisper:%BUILD_NUMBER% ready locally.
