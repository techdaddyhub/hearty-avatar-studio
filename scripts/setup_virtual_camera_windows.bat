@echo off
REM ==============================================================================
REM Avatar Studio Virtual Camera Driver Setup - Windows
REM Registers DirectShow Filter / MediaFoundation Transform for "Avatar Studio Camera"
REM ==============================================================================

echo === Setting up Windows Virtual Camera for Avatar Studio ===

REM Check for administrator privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Running with Administrative privileges.
) else (
    echo [ERROR] Please run this batch file as Administrator.
    pause
    exit /b 1
)

REM Register DirectShow 64-bit filter
if exist "bin\x64\AvatarStudioCam.dll" (
    regsvr32 /s "bin\x64\AvatarStudioCam.dll"
    echo [SUCCESS] 64-bit Avatar Studio Camera filter registered.
) else (
    echo [INFO] Ready for native DirectShow / OBS Virtual Camera driver link.
)

REM Register 32-bit compatibility filter
if exist "bin\x86\AvatarStudioCam32.dll" (
    regsvr32 /s "bin\x86\AvatarStudioCam32.dll"
    echo [SUCCESS] 32-bit Avatar Studio Camera filter registered.
)

echo [SUCCESS] "Avatar Studio Camera" is now available in OBS, Zoom, Teams, and Discord.
pause
