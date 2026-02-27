@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Error: Missing required parameter. Please provide a file name.
    echo Usage: transcribe.bat ^<filename.mp4^> [MODEL_SIZE]
    echo Example: transcribe.bat meeting.mp4
    echo          transcribe.bat meeting.mp4 large-v3
    echo.
    echo Environment variables ^(or set in .env file^):
    echo   MODEL_SIZE   Whisper model ^(default: turbo^). Options: tiny, base, small, medium, large-v3, turbo
    echo   HF_TOKEN     Hugging Face token for speaker diarization
    exit /b 1
)

REM Load .env file if present (from script directory or current directory)
set "scriptdir=%~dp0"
if exist "%scriptdir%.env" (
    for /f "usebackq tokens=1,* delims==" %%a in ("%scriptdir%.env") do (
        set "line=%%a"
        if not "!line:~0,1!"=="#" if not "%%a"=="" set "%%a=%%b"
    )
)
if exist ".env" (
    for /f "usebackq tokens=1,* delims==" %%a in (".env") do (
        set "line=%%a"
        if not "!line:~0,1!"=="#" if not "%%a"=="" set "%%a=%%b"
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

REM Check if whisper:latest image exists locally; pull from Docker Hub if not
docker image inspect whisper:latest >nul 2>&1
if %errorlevel% neq 0 (
    echo Image whisper:latest not found locally. Pulling from paulseto/whisper...
    docker pull paulseto/whisper:latest
    if %errorlevel% neq 0 (
        echo Failed to pull image. Run build.bat to build locally or check your network.
        exit /b 1
    )
    docker tag paulseto/whisper:latest whisper:latest
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

docker run --rm %DOCKER_ENV% -v "%filedir%:/app" whisper:latest "%nameonly%"

if %errorlevel% equ 0 (
    echo.
    echo === Done. Transcript: %filedir%\%outputfile%
) else (
    echo.
    echo Transcription failed. Check that the file exists and Docker image "whisper:latest" is built.
    exit /b 1
)
