@echo off
setlocal

:: Optional first parameter: model size (default turbo)
if "%~1"=="" (set MODEL_SIZE=turbo) else (set MODEL_SIZE=%~1)

:: Build number in format YYYYMMDD-HHMM
for /f "usebackq" %%t in (`powershell -NoProfile -Command "Get-Date -Format 'yyyyMMdd-HHmm'"`) do set BUILD_NUMBER=%%t

set REPO=paulseto/whisper

echo Building for amd64 and arm64 and pushing %REPO%:%BUILD_NUMBER% + %REPO%:latest...
echo Push can take several minutes; Docker Hub may rate-limit free accounts.
docker buildx create --use 2>nul
docker buildx build --platform linux/amd64,linux/arm64 --no-cache ^
  --build-arg MODEL_SIZE=%MODEL_SIZE% ^
  --tag %REPO%:%BUILD_NUMBER% ^
  --tag %REPO%:latest ^
  --push .
if %errorlevel% neq 0 (
    echo Push failed.
    exit /b %errorlevel%
)

echo Pushed. Pulling native platform image for local use...
docker pull %REPO%:%BUILD_NUMBER%
docker tag %REPO%:%BUILD_NUMBER% whisper:latest
docker tag %REPO%:%BUILD_NUMBER% whisper:%BUILD_NUMBER%
echo Done. %REPO%:%BUILD_NUMBER% and %REPO%:latest (amd64 + arm64) on Hub; whisper:latest set locally.
