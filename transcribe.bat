@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Error: Missing required parameter. Please provide a file name.
    echo Usage: transcribe.bat ^<filename.mp4^> [MODEL_SIZE]
    echo Example: transcribe.bat meeting.mp4
    echo          transcribe.bat meeting.mp4 large-v3
    echo.
    echo Environment variables ^(or set in env file^):
    echo   MODEL_SIZE   Whisper model ^(default: turbo^). Options: tiny, base, small, medium, large-v3, turbo
    echo   HF_TOKEN     Hugging Face token for speaker diarization
    echo.
    echo Config files ^(lowest to highest precedence^):
    echo   %%APPDATA%%\whisper\env        per-user
    echo   .\.env                         current directory
    echo   Environment variables          system/user env vars ^(highest^)
    exit /b 1
)

REM Load env files (lowest to highest precedence).
REM Only set variables that are not already defined,
REM so system/user environment variables always win.

if exist "%APPDATA%\whisper\env" (
    for /f "usebackq tokens=1,* delims==" %%a in ("%APPDATA%\whisper\env") do (
        set "line=%%a"
        if not "!line:~0,1!"=="#" if not "%%a"=="" (
            if not defined %%a set "%%a=%%b"
        )
    )
)
if exist ".env" (
    for /f "usebackq tokens=1,* delims==" %%a in (".env") do (
        set "line=%%a"
        if not "!line:~0,1!"=="#" if not "%%a"=="" (
            if not defined %%a set "%%a=%%b"
        )
    )
)

REM Second argument overrides MODEL_SIZE
if not "%~2"=="" set "MODEL_SIZE=%~2"

REM Defaults
if not defined MODEL_SIZE set "MODEL_SIZE=turbo"

REM Remove .\ prefix if present and resolve to full path for Docker mount
set "filename=%~1"
if "%filename:~0,2%"==".\" set "filename=%filename:~2%"

REM Directory of the source file (for Docker volume) and base name (for container path)
set "filedir=%~dp1"
if "%filedir:~-1%"=="\" set "filedir=%filedir:~0,-1%"
for %%f in ("%filename%") do set "basename=%%~nf"
set "outputfile=%basename%.txt"

REM Pass only the filename to the container so it finds /app/<filename>
for %%f in ("%filename%") do set "nameonly=%%~nxf"

REM Pull latest image if not available locally
docker image inspect paulseto/whisper:latest >nul 2>&1
if %errorlevel% neq 0 (
    echo Pulling paulseto/whisper:latest from Docker Hub...
    docker pull paulseto/whisper:latest
    if %errorlevel% neq 0 (
        echo Failed to pull image. Check your network connection.
        exit /b 1
    )
)

echo.
echo Transcribing: %nameonly%
echo Model:        %MODEL_SIZE%
echo Transcript will be saved as: %outputfile%
echo.
echo NOTE: Whisper writes the .txt file only when transcription finishes.
echo      On CPU this can take many minutes. Do not interrupt ^(Ctrl+C^).
if defined HF_TOKEN (
    echo      HF_TOKEN set - speaker diarization enabled ^(see .srt for labels^).
    echo      If you get 403: accept terms at https://huggingface.co/pyannote/speaker-diarization-community-1 or unset HF_TOKEN.
)
echo.

set "DOCKER_ENV=-e MODEL_SIZE=%MODEL_SIZE%"
if defined HF_TOKEN set "DOCKER_ENV=%DOCKER_ENV% -e HF_TOKEN=%HF_TOKEN%"

docker run --rm %DOCKER_ENV% -v "%filedir%:/app" paulseto/whisper:latest "%nameonly%"

if %errorlevel% equ 0 (
    echo.
    echo === Done. Transcript: %filedir%\%outputfile%
) else (
    echo.
    echo Transcription failed. Check that the file exists and Docker is running.
    exit /b 1
)
