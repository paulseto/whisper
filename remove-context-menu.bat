@echo off
echo Removing "Transcribe with Whisper" from right-click menu...

reg delete "HKCU\SOFTWARE\Classes\SystemFileAssociations\.mp4\shell\TranscribeWithWhisper" /f 2>nul
reg delete "HKCU\SOFTWARE\Classes\SystemFileAssociations\.m4v\shell\TranscribeWithWhisper" /f 2>nul

echo Done. "Transcribe with Whisper" removed from right-click menu.
