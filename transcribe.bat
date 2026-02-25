@echo off
setlocal

if "%~1"=="" (
    echo Error: Missing required parameter. Please provide a file name.
    echo Usage: transcribe.bat ^<filename.mp4^>
    echo Example: transcribe.bat meeting.mp4
    exit /b 1
)

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

echo.
echo Transcribing: %nameonly%
echo Transcript will be saved as: %outputfile%
echo.
echo NOTE: Whisper writes the .txt file only when transcription finishes.
echo      On CPU this can take many minutes. Do not interrupt (Ctrl+C).
if defined HF_TOKEN (
    echo      HF_TOKEN set - speaker diarization enabled ^(see .srt for labels^).
    echo      If you get 403: accept terms at https://huggingface.co/pyannote/speaker-diarization-community-1 or unset HF_TOKEN.
)
echo.

if defined HF_TOKEN (
    docker run --rm -e HF_TOKEN=%HF_TOKEN% -v "%filedir%:/app" whisper:latest "%nameonly%"
) else (
    docker run --rm -v "%filedir%:/app" whisper:latest "%nameonly%"
)

if %errorlevel% equ 0 (
    echo.
    echo === Done. Transcript: %filedir%\%outputfile%
) else (
    echo.
    echo Transcription failed. Check that the file exists and Docker image "whisper:latest" is built.
    exit /b 1
)
