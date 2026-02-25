@echo off
echo Adding "Transcribe with Whisper" to right-click menu for .mp4 and .m4v...

reg add "HKCU\SOFTWARE\Classes\SystemFileAssociations\.mp4\shell\TranscribeWithWhisper" /ve /d "Transcribe with Whisper" /f
reg add "HKCU\SOFTWARE\Classes\SystemFileAssociations\.mp4\shell\TranscribeWithWhisper\command" /ve /t REG_EXPAND_SZ /d "cmd /k call \"%%USERPROFILE%%\transcribe.bat\" \"%%1\"" /f

reg add "HKCU\SOFTWARE\Classes\SystemFileAssociations\.m4v\shell\TranscribeWithWhisper" /ve /d "Transcribe with Whisper" /f
reg add "HKCU\SOFTWARE\Classes\SystemFileAssociations\.m4v\shell\TranscribeWithWhisper\command" /ve /t REG_EXPAND_SZ /d "cmd /k call \"%%USERPROFILE%%\transcribe.bat\" \"%%1\"" /f

echo Done. "Transcribe with Whisper" added to right-click menu for .mp4 and .m4v.
