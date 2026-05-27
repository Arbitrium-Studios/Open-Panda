@echo off

:root

SetLocal DisableDelayedExpansion

:: Placing any variables here allows for them to placed as is.
:: The placement of variables such as "exclaimStr" here allows exclamation points...
:: ...to be used in echos by surrounding the variable in exclamation points like the following:
:: !exclaimStr!
set "exclaimStr=!"

SetLocal EnableDelayedExpansion

REM --------------------------------------------------------
REM Check the Windows architecture and determine with Python
REM to use; 64-bit or 32-bit. Verify that we can find the
REM 'makepanda' python script and the python interpreter.
REM If we can find both, then run 'makepanda'.
REM --------------------------------------------------------

set "wantExitScript=False"
set "wantDirLoggingCLS=False"
set "wantDirLogging=False"

set "fileName=%~nx0"

if "%wantDirLogging%" EQU "True" (
    echo Hello from the "!fileName!" file!exclaimStr!
    echo.
)

if "%wantDirLogging%" EQU "True" (
    echo Current Directory is set to "%CD%"
    echo.
)

set "P3D_PYTHON_VERSION=!PYTHON_VERSION!"

if "%wantDirLogging%" EQU "True" (
    echo The "P3D_PYTHON_VERSION" is set to "!P3D_PYTHON_VERSION!"
    echo.
)

if "!P3D_PYTHON_VERSION!" NEQ "" (
    if "%wantDirLogging%" EQU "True" (
        echo The "P3D_PYTHON_VERSION" variable is set to "!P3D_PYTHON_VERSION!"
        echo.
    )
) else (
    echo Failed to set the "P3D_PYTHON_VERSION" variable because the "P3D_PYTHON_VERSION" variable is set to "!P3D_PYTHON_VERSION!".
    echo.
    goto :ending
)

if %PROCESSOR_ARCHITECTURE% == AMD64 (
    set "suffix=-x64"
) else (
    set "suffix="
)

set "thirdparty=thirdparty"
set "thirdpartyPath=%CD%\%thirdparty%"
set "makepandaDir=makepanda"
set "makePandaPython=%makepandaDir%\makepanda.py"
set "makePandaPythonFull=%CD%\%makePandaPython%"

set "p3dPythonPath=%thirdparty%\%pythonDir%\python.exe"

if defined MAKEPANDA_THIRDPARTY set thirdparty=%MAKEPANDA_THIRDPARTY%

if not exist "%thirdpartyPath%" goto :missing1

set "p3d_python_path_long=%thirdparty%\win-python!P3D_PYTHON_VERSION!%suffix%\python.exe"

if exist "%p3d_python_path_long%" (
    if "%wantDirLogging%" EQU "True" (
        echo The python executable exists in the "%p3d_python_path_long%" directory!exclaimStr!
        echo.
    )
    set "pythonDir=win-python!P3D_PYTHON_VERSION!%suffix%"
) else (
    echo The "python.exe" file does not exist in the "%CD%\%thirdparty%" directory.
    echo.
    goto :ending
)

set "p3d_python_path=%thirdparty%\%pythonDir%\python.exe"
set "p3d_python_path_full=%CD%\%p3d_python_path%"

if not exist "%makePandaPythonFull%" goto :missing1
if not exist "%p3d_python_path%" goto :missing2

set "pythonVersionStr= !P3D_PYTHON_VERSION!"

set "compilerFlags=%*"
set "compilerFlags=!compilerFlags:%pythonVersionStr%=!"

set "compilerFlags=!compilerFlags!"

if "%wantDirLogging%" EQU "True" (
    echo The installer variables are set to "!compilerFlags!"
    echo.
)

"%p3d_python_path_full%" !makePandaPython! !compilerFlags!
if errorlevel 1 (
    if x%1 == x--slavebuild goto :PreScriptFailure
) else if errorlevel 0 (
    goto :done
)

:missing1
echo You need to change directory to the root of the panda source tree
echo before invoking makepanda. For further install instructions, read
echo the installation instructions in the file doc/INSTALL-MK.
echo.
goto :ending

:missing2
echo You seem to be missing the "thirdparty" directory. You probably checked
echo the source code out from GitHub. The GitHub repository is
echo missing the "thirdparty" directory. You will need to supplement the
echo code by downloading the "thirdparty" directory from https://www.panda3d.org
echo.
echo The "thirdparty" directory is set to: "%thirdparty%"
echo.
goto :ending

:PreScriptFailure

echo.
goto :ScriptFailure

:ScriptFailure

echo.
echo Failed to run the script for whatever reason...
echo.

goto :ending

:done

echo.
echo Finished running the "!fileName!" file!exclaimStr!
echo.

goto :ending

:ending

pause
if "%wantDirLoggingCLS%" EQU "True" (
    cls
)

endlocal
if "%wantExitScript%" EQU "True" (
    exit 1
) else (
    goto :root
)
