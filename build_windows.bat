@echo off
title Nexus Applications' Open-Panda3D Builder

if not exist thirdparty/win-nsis (

    set PROGRAM_FILES_X86="%ProgramFiles(x86)%"

    echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    echo Fetching ThirdParty Dependencies
    echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

    if not exist "%PROGRAM_FILES_X86%" (
        set PANDA_THIRDPARTY_TOOLS_FILE = panda3d-1.10.15-tools-win32.zip

        echo.
        echo System is 32-bit, setting ThirdParty Tools accordingly
        echo.
    )

    if exist "%PROGRAM_FILES_X86%" (
        set PANDA_THIRDPARTY_TOOLS_FILE = panda3d-1.10.15-tools-win64.zip

        echo.
        echo System is 64-bit, setting ThirdParty Tools accordingly
        echo.
    )

    if not exist "%PANDA_THIRDPARTY_TOOLS_FILE%" (
        "thirdparty\win-wget\wget" https://www.panda3d.org/download/panda3d-1.10.15/%PANDA_THIRDPARTY_TOOLS_FILE%
    )

    if not exist panda3d-1.10.15 (
        "thirdparty\win-7zip\7z" x %PANDA_THIRDPARTY_TOOLS_FILE%
    )

    robocopy "panda3d-1.10.15\thirdparty" "thirdparty" /E /NFL /MOVE
    rmdir /q panda3d-1.10.15
)

echo.
echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
echo Building Nexus Applications' Open-Panda3D
echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

echo.
set "MSVC_VERSION=14.3"
set /P "MSVC_VERSION=Microsoft Visual C++ Version (i.e. 2022 is 14.3) [%MSVC_VERSION%]: "

echo.
echo Microsoft Visual Studio Version is set to %MSVC_VERSION%
echo.

set "WIN_SDK=11"
set /P WIN_SDK="Windows SDK Version (i.e. 11 for Windows 11): "

echo.
echo Windows SDK Version is set to Windows 11
echo.

set /P THREADS="Thread Count: "

echo.
echo Thread Count is set to %THREADS%
echo.

"thirdparty\win-python3.13-x64\python" makepanda/makepanda.py --everything --installer --msvc-version=%MSVC_VERSION% --windows-sdk=%WIN_SDK% --no-eigen --threads=%THREADS%

pause
