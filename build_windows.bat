@echo off
SetLocal EnableDelayedExpansion

set "projectOwnerName=Nexus Application"
set "projectName=Open-Panda3D"
set "projectNameFull=%projectOwnerName%'s %projectName%"
title %projectNameFull% Builder

set "ROOT_DIR=%~dp0"
set "ROOT_DIR=!ROOT_DIR:~0,-1!"

if "%CD%" NEQ "!ROOT_DIR!" (
    cd /d "!ROOT_DIR!"
)

for %%I in (.) do set "DirectoryName=%%~nxI"
if "!DirectoryName!" NEQ "!ROOT_DIR!" (
    set "ROOT_DIR=!CD!"
)

reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32BIT || set OS=64BIT

goto :root

:root

set "wantDirLoggingCLS=False"
set "wantExtraLogging=False"

set "panda3dToolsVersionNumber=1.10.16"
set "panda3dVersion=panda3d-%panda3dToolsVersionNumber%"

set "minSupportedPythonMajorVersion=3"
set "minExistingPythonMinorVersion=4"
set "minExistingPythonVersion=%minSupportedPythonMajorVersion%.%minExistingPythonMinorVersion%"

set "minSupportedPythonMinorVersion=8"
set "minSupportedPythonVersion=%minSupportedPythonMajorVersion%.%minSupportedPythonMinorVersion%"

set "latestSupportedPythonMinorVersion=13"
set "latestSupportedPythonVersion=%minSupportedPythonMajorVersion%.%latestSupportedPythonMinorVersion%"

set "minRecommendedPythonMajorVersion=3"
set "latestRecommendedPythonMinorVersion=13"
set "recommendedPythonVersion=%minRecommendedPythonMajorVersion%.%latestRecommendedPythonMinorVersion%"

set "THIRDPARTY_DIR=thirdparty"
set "WIN_NSIS_DIR=win-nsis"
set "WIN_WGET_DIR=win-wget"
set "WIN_7ZIP_DIR=win-7zip"

set "DirSDK=%CD%\%THIRDPARTY_DIR%\%WIN_NSIS_DIR%"

set "seconds=5"
set "defaultKey=N"
set "cancelKey=C"
set "returnTo="

:check_thirdparty

echo Enter the system bit type you want to compile %projectName% for.
echo.

echo Toon Tip: You can leave this blank to get your system's bit type!
echo.

set "bitDialog=bit"
set "dashBitDialog=-!bitDialog!"
set "spaceBitDialog= !bitDialog!"

set "COMPILE_FOR_BIT_FALLBACK=64"
set "COMPILE_FOR_BIT_INPUT_PREFIX=System Type: "
set /P "COMPILE_FOR_BIT_INPUT=!COMPILE_FOR_BIT_INPUT_PREFIX!"
echo.

if "!COMPILE_FOR_BIT_INPUT!" EQU "" (
    goto :system_type
)

set "returnTo=return_from_bit_dial_length"
call :get_var_length "%COMPILE_FOR_BIT_INPUT%" bitDialLength

:return_from_bit_dial_length

if %bitDialLength% EQU 0 (
    echo The "bitDialLength" variable length is set to %bitDialLength%.
    echo.
    goto :system_type
)  else if %bitDialLength% EQU 2 (
    goto :check_system_type
)

set /a bitDialLength=%bitDialLength% - 2

if "%wantExtraLogging%" EQU "True"  (
    echo The "bitDialLength" variable length is %bitDialLength%
    echo.
)

call set "COMPILE_FOR_BIT_INPUT=%%COMPILE_FOR_BIT_INPUT:!COMPILE_FOR_BIT_INPUT:~-%bitDialLength%!=%%"

if "%wantExtraLogging%" EQU "True"  (
    echo The stripped "COMPILE_FOR_BIT_INPUT" variable is set to "!COMPILE_FOR_BIT_INPUT!"
    echo.
)

set "returnTo=return_to_stripped_bit_input_length"
call :get_var_length "%COMPILE_FOR_BIT_INPUT%" strippedBitDialLength

:return_to_stripped_bit_input_length

echo The "strippedBitDialLength" variable length is set to %strippedBitDialLength%.
echo.

if "%wantExtraLogging%" EQU "True"  (
    echo The "strippedBitDialLength" variable length is set to %strippedBitDialLength%.
    echo.
)

if %strippedBitDialLength% EQU 2 (
    if "%wantExtraLogging%" EQU "True"  (
        echo The "strippedBitDialLength" variable length equals %strippedBitDialLength%.
        echo.
    )
    goto :check_system_type
) else (
    goto :check_thirdparty
)

:get_var_length
set "str=%~1"
set "len=0"

:var_length_loop
if not "%str%"=="" (
    set "str=%str:~1%"
    set /a len+=1
    goto :var_length_loop
)

set "%~2=%len%"

if "%returnTo%" NEQ "" (
    goto :%returnTo%
) else (
    goto :return_from_get_var_length
)

pause

:check_system_type

echo Hello from the ":check_system_type" section!
echo.

if "%wantExtraLogging%" EQU "True" (
    echo The "COMPILE_FOR_BIT_INPUT" variable is set to "!COMPILE_FOR_BIT_INPUT!"
    echo.
)

if "%COMPILE_FOR_BIT_INPUT%" == "32" (
    echo Gotcha, will be compiling for %COMPILE_FOR_BIT_INPUT%-bit systems!
    echo.
    set "thirdpartyBit=32"
    set "thirdpartyBitDirSuffix="
    goto :thirdparty_tools
) else if "%COMPILE_FOR_BIT_INPUT%" == "64" (
    echo Gotcha, will be compiling for %COMPILE_FOR_BIT_INPUT%-bit systems!
    echo.
    set "thirdpartyBit=64"
    set "thirdpartyBitDirSuffix=-x!thirdpartyBit!"
    goto :thirdparty_tools
) else (
    echo Error: Please enter "32", "64", or leave it blank to get your system default.
    echo.
    echo What you entered: "!COMPILE_FOR_BIT_INPUT!"
    echo.
    goto :check_thirdparty
)

echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
echo Fetching %projectNameFull%'s ThirdParty Dependencies
echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
echo.

:system_type

if %OS%==32BIT (
    :SystemType32
    echo System is 32-bit, setting ThirdParty Tools accordingly...
    echo.
    set "thirdpartyBit=32"
    set "thirdpartyBitDirSuffix="
    goto :thirdparty_tools
) else if %OS%==64BIT (
    :SystemType64
    echo System is 64-bit, setting ThirdParty Tools accordingly...
    echo.
    set "thirdpartyBit=64"
    set "thirdpartyBitDirSuffix=-x!thirdpartyBit!"
    goto :thirdparty_tools
) else (
    echo System is %OS% which is not supported. Please try again with a 32-bit or a 64-bit system!
    echo.
    set "thirdpartyBit=0"
    goto :ending
)

:thirdparty_tools

set "PANDA_THIRDPARTY_TOOLS_FILE=%panda3dVersion%-tools-win%thirdpartyBit%.zip"

if not exist "%DirSDK%" (

    if not exist "%PANDA_THIRDPARTY_TOOLS_FILE%" (
        "%THIRDPARTY_DIR%\%WIN_WGET_DIR%\wget" https://www.panda3d.org/download/%panda3dVersion%/%PANDA_THIRDPARTY_TOOLS_FILE%
    )

    if not exist "%panda3dVersion%" (
        "%THIRDPARTY_DIR%\%WIN_7ZIP_DIR%\7z" x %PANDA_THIRDPARTY_TOOLS_FILE%
    )

    robocopy "%panda3dVersion%\%THIRDPARTY_DIR%" "%THIRDPARTY_DIR%" /E /NFL /MOVE
    rmdir /q %panda3dVersion%
)

goto :build

:build

echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
echo Building %projectNameFull%
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

echo Windows SDK Version is set to Windows %WIN_SDK%
echo.

echo Enter how many threads you want to use to compile %projectName%.
echo.

set "THREAD_COUNT=2"
set /P THREAD_COUNT="Thread Count (default is %THREAD_COUNT%) [%THREAD_COUNT%]: "
echo.

echo Thread Count is set to %THREAD_COUNT%
echo.

goto :setPythonVersion

:setPythonVersion

set "INPUT_VERSION_NAME=Python"
set "INPUT_VERSION=Python"

set "RECOMMENDED_PYTHON_VERSION=%recommendedPythonVersion%"
set "PYTHON_VERSION=%recommendedPythonVersion%"
set /P "PYTHON_VERSION=Python Version (i.e. (recommended) %recommendedPythonVersion% for Python v%recommendedPythonVersion% (Supported versions are Python v%minSupportedPythonVersion% - Python v%latestSupportedPythonVersion%) [%PYTHON_VERSION%]: "
echo.

set "InputVersion=%PYTHON_VERSION%"

set "WIN_PYTHON_DIR=win-python%PYTHON_VERSION%%thirdpartyBitDirSuffix%"

set "WIN_PYTHON_PATH=%CD%\%THIRDPARTY_DIR%\%WIN_PYTHON_DIR%"
set "WIN_PYTHON_PATH=%THIRDPARTY_DIR%\%WIN_PYTHON_DIR%"
set "WIN_PYTHON_FULL_PATH=%CD%\%THIRDPARTY_DIR%\%WIN_PYTHON_DIR%"
set "WIN_PIP_FULL_PATH=%WIN_PYTHON_FULL_PATH%\Scripts"
set "WIN_PIP_FULL_APP=%WIN_PIP_FULL_PATH%\pip.exe"

if exist "%WIN_PIP_FULL_APP%" (
    echo The "WIN_PIP_FULL_APP" variable exists at: "%WIN_PIP_FULL_APP%"
    echo.
    echo The "PYTHON_VERSION" variable is set to: "!PYTHON_VERSION!"
    echo.

    set "SELECTED_PYTHON_PATH=!WIN_PYTHON_PATH!\python.exe"
    set "FULL_SELECTED_PYTHON_PATH=!WIN_PYTHON_FULL_PATH!\python.exe"

    for /f "tokens=1,2 delims=." %%a in ("!PYTHON_VERSION!") do (
        set "wholeNumber=%%a"
        set "decimalPart=%%b"
    )

    if "%wantExtraLogging%" EQU "True" (
        echo Whole Number: !wholeNumber!
        echo Decimal Part: !decimalPart!
        echo.
    )

    if !wholeNumber! LEQ 2 (
        echo Python v!wholeNumber! is not supported. Please enter a new Python version.
        echo.
        goto :setPythonVersion
    )

    if !wholeNumber! GEQ 4 (
        echo This version of python does not exist yet. Please enter a new Python version.
        echo.
        goto :setPythonVersion
    )

    if !decimalPart! LSS !minSupportedPythonMinorVersion! (
        echo Python v!wholeNumber!.!decimalPart! is not supported. Please enter a new Python version.
        echo.
        goto :setPythonVersion
    )

    if !decimalPart! GEQ 13 (
        "!SELECTED_PYTHON_PATH!" "!WIN_PIP_FULL_APP!" install audioop-lts
    )
)

if not exist "%FULL_SELECTED_PYTHON_PATH%" (
    set "ENTERED_PYTHON_VERSION=%PYTHON_VERSION%"
    set "PYTHON_VERSION=%RECOMMENDED_PYTHON_VERSION%"
    echo Error: The python path you selected does NOT exist! Please enter a valid Python Path. The patch your entered: %SELECTED_PYTHON_PATH%
    echo.
    goto :setPythonVersion
) else (
    echo The chosen python path exists at "%SELECTED_PYTHON_PATH%"!
    set "PYTHON_VERSION=%RECOMMENDED_PYTHON_VERSION%"
    echo.
    goto :compile_installer
)

:compile_installer

echo Current Directory is set to "%CD%"
echo.

set "makepandaDir=makepanda"
set "makepandaPath=%CD%\!makepandaDir!"
set "makePandaBat=!makepandaDir!\makepanda.bat"
set "makePandaBatFullPath=%CD%\!makePandaBat!"

if exist "!makePandaBatFullPath!" (
    echo The "makePandaBatFullPath" path exists at: "%makePandaBatFullPath%"
    echo.
) else (
    echo Error: The "!makePandaBat!" file does not exist at "!makePandaBatFullPath!"
    echo This should NOT be happening. Please ensure the repository was cloned before trying again
    echo.
    goto :endOfScript
)

if "%CD%" NEQ "!ROOT_DIR!" (
    cd /d "!ROOT_DIR!"
)

if "%wantDirLoggingCLS%" EQU "True" (
    cls
)

if exist "!makePandaBatFullPath!" (
    call "!makePandaBat!" --everything --installer --msvc-version=%MSVC_VERSION% --windows-sdk=%WIN_SDK% --no-eigen --threads=%THREAD_COUNT% %PYTHON_VERSION%
)

echo.

goto :ending

:ending

echo Finished compiling a new installer build for %projectName%.
echo.

pause

:countdownToExitScript

set "secondsTilScriptExit=%seconds%"

for /L %%i in (%secondsTilScriptExit%,-1,1) do (
    cls

    if !secondsTilScriptExit! EQU 1 (
        set "secondWord=  !secondsTilScriptExit! second"
    ) else (
        if !secondsTilScriptExit! GEQ 10 (
            set "secondWord= !secondsTilScriptExit! seconds"
        ) else (
            set "secondWord=  !secondsTilScriptExit! seconds"
        )
    )

    echo ----------------------
    echo  Script will exit in:
    echo     !secondWord!
    echo ----------------------
    echo.
    echo Press [%cancelKey%] to cancel...
    echo.

    choice /N /t 1 /c %cancelKey%%defaultKey% /d %defaultKey%
    if !ErrorLevel! == %cancelKey% goto :cancel
    if !ErrorLevel! == 1 goto :cancel
    if !ErrorLevel! == %defaultKey% goto :countdownTimerFinished
    if errorlevel == 0 (
        set /a "secondsTilScriptExit-=1"
        if !secondsTilScriptExit! == 0 (
            echo Time is up!
            echo.
            if !ErrorLevel! == 2 goto :countdownTimerFinished
            goto :countdownTimerFinished
        )
    )
)

goto :countdownToExitScript

:countdownTimerFinished

cls

echo ----------------------
echo  Script will exit in:
echo     !secondsTilScriptExit! seconds
echo ----------------------
echo.
echo Timer finished! The script will be closing soon...
echo.

goto :exitScript

:cancel
cls
echo Countdown cancelled by user.
echo.
goto :root

:endOfScript

echo The script has reached its end!
echo.

pause
cls
goto :root
EndLocal

:exitScript

cls
EndLocal
exit /b

