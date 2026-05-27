@echo off
SetLocal EnableDelayedExpansion

set "projectOwnerName=Nexus Application"
set "OPEN_PANDA_STR=Open-Panda"
set "projectName=%OPEN_PANDA_STR%3D"
set "projectNameFull=%projectOwnerName%'s %projectName%"
title %projectNameFull% Installer

:root

REM For testing purposes...
REM ---------------------------------------------------------
REM Swap "isTest" between
REM "True/False" as needed!
set "isTest=False"
REM ---------------------------------------------------------

set "OPEN_PANDA3D_PATH_DEFAULT=C:\%OPEN_PANDA_STR%"

set "OPEN_PANDA3D_UNINSTALLER_FILE=uninst.exe"
set "OPEN_PANDA3D_UNINSTALLER=%OPEN_PANDA3D_PATH%\%OPEN_PANDA3D_UNINSTALLER_FILE%"

set "seconds=5"
set "defaultKey=N"
set "cancelKey=C"

REM For testing purposes...
if "%isTest%" == "True" (
    goto :sectionSelector
) else (
    goto :searchForFiles
)

:sectionSelector

if "%isTest%" == "False" (
    goto :searchForFiles
)

echo The "isTest" variable is set to "%isTest%"
echo.

set "nextSection="
set "nextSectionDefault=searchForFiles"

if "%nextSection%" == "" (
    set "nextSection=%nextSectionDefault%"
)

goto :%nextSection%
pause

:searchForFiles

set "searchString=%OPEN_PANDA_STR%"
set "count=0"

echo ----------------------------------------------------
echo      All ".exe" files containing "%searchString%":
echo ----------------------------------------------------
echo.

for %%F in ("*%searchString%*.exe") do (
    set /a count+=1
    set "file!count!=%%~fF"
    echo !count!. %%~nxF
)

echo.
echo ----------------------------------------------------
echo.

set "choice=%count%"

if !count! EQU 0 (
    echo No files matching containing "%searchString%" nor ending in ".exe" were found.
    echo ----------------------------------------------------
    echo.
    goto :endOfScript
) else if !count! EQU 1 (
    goto :singularFile
) else if !count! GEQ 2 (
    goto :chooseBetweenFiles
) else (
    echo Invalid variable.
    echo.
    goto :endOfScript
)

:singularFile

if defined file%choice% (
    for /f "delims=" %%A in ("!file%choice%!") do set "selectedFile=%%A"
    goto :fileVariables
) else (
    echo The "fileChoice" variable does not exist.
    echo.
    pause
    goto :searchForFiles
)

:chooseBetweenFiles

set /p "choice=Enter the number to select (1-%count%): "
echo.

if %choice% EQU 0 (
    goto :invalidFileSelection
) else if %choice% LEQ !count! (
    echo The "choice" variable is less than or equal to the "count" variable: !count!
    echo.
    if defined file%choice% (
        for /f "delims=" %%A in ("!file%choice%!") do set "selectedFile=%%A"
        echo.
        echo Successfully selected: !selectedFile!
        echo.
        goto :fileVariables
    )
) else (
    goto :invalidFileSelection
)

:invalidFileSelection

echo Invalid selection.
echo.
goto :chooseBetweenFiles

:fileVariables

set "fullFilePath=!selectedFile!"

set "delimiter=\"

set "last_pos=0"
set "varSplitCounter=0"

:loopSplitVar
call set "char=%%fullFilePath:~%varSplitCounter%,1%%"
if "%char%"=="" goto :splitVar
if "%char%"=="%delimiter%" set "last_pos=%varSplitCounter%"
set /a varSplitCounter+=1
goto :loopSplitVar

:splitVar
set /a after_pos=%last_pos% + 1
set "splitFileDirectory=!fullFilePath:~0,%last_pos%!\"
set "splitFileName=!fullFilePath:~%after_pos%!"
set "applicationName=%splitFileName%"

echo - Full Path: "%fullFilePath%"
echo - Directory of the File: "%splitFileDirectory%"
echo - File Name: %splitFileName%
echo.

goto :ensure_panda3d_directory
pause

:ensure_panda3d_directory

if not defined OPEN_PANDA3D_PATH (
    echo OPEN_PANDA3D_PATH is not defined in the environment variables...
    echo.
    if exist "%OPEN_PANDA3D_PATH_DEFAULT%" (
        echo OPEN_PANDA3D_PATH_DEFAULT exists at "%OPEN_PANDA3D_PATH_DEFAULT%"
        echo.
        set "OPEN_PANDA3D_PATH=%OPEN_PANDA3D_PATH_DEFAULT%"
        setx OPEN_PANDA3D_PATH "%OPEN_PANDA3D_PATH_DEFAULT%"
        goto :AlreadyInstalled
    ) else (
        echo OPEN_PANDA3D_PATH_DEFAULT does not exist at the given path: "%OPEN_PANDA3D_PATH_DEFAULT%"
        echo.
        goto :enterCustomOpenPanda3dDirectory
    )
) else (
    echo OPEN_PANDA3D_PATH is defined in the environment variables as "%OPEN_PANDA3D_PATH%"
    echo.
    if exist "%OPEN_PANDA3D_PATH%" (
        goto :AlreadyInstalled
    ) else (
        goto :enterCustomOpenPanda3dDirectory
    )
)

:enterCustomOpenPanda3dDirectory

set "OPEN_PANDA3D_PATH=%OPEN_PANDA3D_PATH_DEFAULT%"
set /P "OPEN_PANDA3D_PATH=Open-Panda3D Directory (Default: %OPEN_PANDA3D_PATH_DEFAULT%) [%OPEN_PANDA3D_PATH%]: "
echo.
goto :setOpenPanda3dDirectory

:setOpenPanda3dDirectory
set "ENTERED_OPEN_PANDA3D_PATH=%OPEN_PANDA3D_PATH%"

set "listOfPanda3DFolderNames=Panda Panda3D Open-Panda3D Open-Panda"
set "foundPanda3DFolder=false"
for %%a in (%listOfPanda3DFolderNames%) do (
    if not "!ENTERED_OPEN_PANDA3D_PATH:%%a=!"=="!ENTERED_OPEN_PANDA3D_PATH!" (
        if exist "!ENTERED_OPEN_PANDA3D_PATH!" (
            set "foundPanda3DFolder=true"
        ) else (
            set "foundPanda3DFolder=false"
            goto :enterCustomOpenPanda3dDirectory
        )
    )
)

if "!foundPanda3DFolder!"=="true" (
    echo The path you entered exists at: "!ENTERED_OPEN_PANDA3D_PATH!"
    echo.

    if not defined OPEN_PANDA3D_PATH (
        echo OPEN_PANDA3D_PATH is not defined in the environment variables but exists at "%OPEN_PANDA3D_PATH%"
        echo.
        setx OPEN_PANDA3D_PATH "%SystemPythonPath%"
    )

    if exist "%OPEN_PANDA3D_PATH%" (
        echo OPEN_PANDA3D_PATH is not defined in the environment variables but exists at "%OPEN_PANDA3D_PATH%"
        echo.
        goto :AlreadyInstalled
    ) else (
        echo OPEN_PANDA3D_PATH is not defined at: %OPEN_PANDA3D_PATH%
        echo.
        goto :searchForFiles
    )
) else (
    set "OPEN_PANDA3D_PATH=%OPEN_PANDA3D_PATH_DEFAULT%"
    echo Error: The path you entered is not an Open-Panda3D directory: "!ENTERED_OPEN_PANDA3D_PATH!"
    echo.
    echo Note: this can also occur if the specified directory does NOT contain at least one of the following words in its path "Panda, Panda3D, Open-Panda3D, Open-Panda":
    echo.
    goto :enterCustomOpenPanda3dDirectory
)

:AlreadyInstalled

echo %projectName% is already installed in the following location: "%OPEN_PANDA3D_PATH%"
echo.
goto :AlreadyInstalledOptions

:AlreadyInstalledOptions

set "setOptionOne=1. ^(U^)ninstall"
set "setOptionTwo=2. ^(R^)einstall"
set "setOptionThree=3. ^(E^)xit the script..."

if "%isTest%" == "False" (
    set "setOptionZero="
) else (
    set "setOptionZero=0. ^(I^)nstall"
)

:loopBackIntoOptions

echo Select how you want to proceed:
echo.

if "%setOptionZero%" NEQ "" (
    echo %setOptionZero%
)

echo %setOptionOne%
echo %setOptionTwo%
echo %setOptionThree%
echo.

:loopBackIntoOptionsWithoutDialog

set /P todoNextChoices="What do you want to do next?: "
echo.

if "%isTest%" == "True" (
    if /i "%todoNextChoices%"=="install" goto :install_Panda3D
    if /i "%todoNextChoices%"=="i" goto :install_Panda3D
    if /i "%todoNextChoices%"=="0" goto :install_Panda3D
)

if /i "%todoNextChoices%"=="uninstall" goto :uninstallSelection
if /i "%todoNextChoices%"=="u" goto :uninstallSelection
if /i "%todoNextChoices%"=="1" goto :uninstallSelection

if /i "%todoNextChoices%"=="reinstall" goto :reinstallation_section
if /i "%todoNextChoices%"=="r" goto :reinstallation_section
if /i "%todoNextChoices%"=="2" goto :reinstallation_section

if /i "%todoNextChoices%"=="exit the script..." goto :countdownToExitScript
if /i "%todoNextChoices%"=="exit the script" goto :countdownToExitScript
if /i "%todoNextChoices%"=="exit" goto :countdownToExitScript
if /i "%todoNextChoices%"=="e" goto :countdownToExitScript
if /i "%todoNextChoices%"=="3" goto :countdownToExitScript

echo Invalid input, please try again.
echo.
goto :loopBackIntoOptionsWithoutDialog
pause

:install_Panda3D

set "currentAction=install"
set "currentActionUpper=Install"

echo ----------------------------------------------------
echo %currentActionUpper%ing %projectNameFull%
echo ----------------------------------------------------
echo.

goto :application_installation

:application_installation

if exist "%OPEN_PANDA3D_PATH%" (
    REM For testing purposes...
    if "%isTest%" == "True" (
        goto :install_existing_application
    ) else (
        goto :AlreadyInstalled
    )
) else (
    :install_existing_application
    if exist %fullFilePath% (
        start /wait "" "%fullFilePath%"
        goto :finished_installation
    )
)

pause

:finished_installation

echo Sucessfully %currentAction%ed %projectName%!
echo.

goto :endOfScript
pause

:uninstallSelection

echo Select how you want to proceed:
echo.
echo 1. ^(Y^)es
echo 2. ^(N^)o
echo 3. ^(E^)xit the script...
echo.

set /P uninstallChoice="Do you want to uninstall %projectName%? (y/n): "
echo.

if /i "%uninstallChoice%"=="1" goto :Uninstall_Panda3D
if /i "%uninstallChoice%"=="yes" goto :Uninstall_Panda3D
if /i "%uninstallChoice%"=="y" goto :Uninstall_Panda3D

if /i "%uninstallChoice%"=="2" goto :Do_NOT_Uninstall_Panda3D
if /i "%uninstallChoice%"=="no" goto :Do_NOT_Uninstall_Panda3D
if /i "%uninstallChoice%"=="n" goto :Do_NOT_Uninstall_Panda3D

if /i "%uninstallChoice%"=="3" goto :countdownToExitScript
if /i "%uninstallChoice%"=="exit the script..." goto :countdownToExitScript
if /i "%uninstallChoice%"=="exit the script" goto :countdownToExitScript
if /i "%uninstallChoice%"=="exit" goto :countdownToExitScript
if /i "%uninstallChoice%"=="e" goto :countdownToExitScript

echo Invalid input, please try again.
echo.
goto :uninstallSelection

:Uninstall_Panda3D
echo ----------------------------------------------------
echo Uninstalling %projectNameFull%
echo ----------------------------------------------------
echo.

set "primaryDirectory=%CD%"

cd /d "%OPEN_PANDA3D_PATH%"

if not exist "%OPEN_PANDA3D_PATH%" (
    if not defined OPEN_PANDA3D_PATH (
        if exist "%OPEN_PANDA3D_PATH_DEFAULT%" (
            echo OPEN_PANDA3D_PATH_DEFAULT exists at "%OPEN_PANDA3D_PATH_DEFAULT%"
            echo.
            set "OPEN_PANDA3D_PATH=%OPEN_PANDA3D_PATH_DEFAULT%"
            setx OPEN_PANDA3D_PATH "%OPEN_PANDA3D_PATH_DEFAULT%"
        ) else (
            echo OPEN_PANDA3D_PATH_DEFAULT does not exist at the given path: "%OPEN_PANDA3D_PATH_DEFAULT%"
            echo.
            goto :enterCustomOpenPanda3dDirectory
        )
    ) else (
        echo OPEN_PANDA3D_PATH is defined in the environment variables as "%OPEN_PANDA3D_PATH%"
        echo.
        set "OPEN_PANDA3D_PATH=%OPEN_PANDA3D_PATH_DEFAULT%"
    )
) else (
    if exist "%OPEN_PANDA3D_UNINSTALLER%" (
        REM For testing purposes...
        if "%isTest%" == "False" (
            echo Beginning uninstalling %projectNameFull%
            echo.
            start /wait "" "%OPEN_PANDA3D_UNINSTALLER%"
        ) else (
            echo Since the "isTest" variable is set to "%isTest%", we will be skipping the booting sequence to prevent accidentally uninstalling %projectName%.
            echo.
        )
    )
)

cd /d "%primaryDirectory%"

goto :finished_uninstallation

:finished_uninstallation

echo Uninstalled %projectNameFull%!
echo.

REM For testing purposes...
if "%isTest%" == "True" (
    if exist "%OPEN_PANDA3D_PATH%" (
        goto :AlreadyInstalled
    )
)

:finished_uninstallation_selection

echo Select how you want to proceed:
echo.
echo 1. ^(R^)einstall %projectName%
echo 2. ^(E^)xit the script...
echo.

set /P reinstallAfterUninstallChoice="Do you want to reinstall %projectName%? (Y/N): "
echo.

if /i "%reinstallAfterUninstallChoice%"=="1" goto :Reinstall_Panda3D
if /i "%reinstallAfterUninstallChoice%"=="yes" goto :Reinstall_Panda3D
if /i "%reinstallAfterUninstallChoice%"=="y" goto :Reinstall_Panda3D

if /i "%reinstallAfterUninstallChoice%"=="3" goto :countdownToExitScript
if /i "%reinstallAfterUninstallChoice%"=="exit the script..." goto :countdownToExitScript
if /i "%reinstallAfterUninstallChoice%"=="exit the script" goto :countdownToExitScript
if /i "%reinstallAfterUninstallChoice%"=="exit" goto :countdownToExitScript
if /i "%reinstallAfterUninstallChoice%"=="e" goto :countdownToExitScript

echo Invalid input, please try again.
echo.
goto :finished_uninstallation_selection

pause

:Do_NOT_Uninstall_Panda3D

echo Gotcha, %projectName% will remain installed!
echo.

goto :endOfScript

:reinstallation_section

echo Select how you want to proceed:
echo.
echo 1. ^(Y^)es
echo 2. ^(N^)o
echo 3. ^(E^)xit the script...
echo.

set /P reinstallChoice="Do you want to reinstall %projectName%? (Y/N): "
echo.

if /i "%reinstallChoice%"=="1" goto :Reinstall_Panda3D
if /i "%reinstallChoice%"=="yes" goto :Reinstall_Panda3D
if /i "%reinstallChoice%"=="y" goto :Reinstall_Panda3D

if /i "%reinstallChoice%"=="2" goto :No_Reinstallation
if /i "%reinstallChoice%"=="no" goto :No_Reinstallation
if /i "%reinstallChoice%"=="n" goto :No_Reinstallation

if /i "%reinstallChoice%"=="3" goto :countdownToExitScript
if /i "%reinstallChoice%"=="exit the script..." goto :countdownToExitScript
if /i "%reinstallChoice%"=="exit the script" goto :countdownToExitScript
if /i "%reinstallChoice%"=="exit" goto :countdownToExitScript
if /i "%reinstallChoice%"=="e" goto :countdownToExitScript

echo Invalid input, please try again.
echo.
goto :reinstallation_section

:Reinstall_Panda3D

echo ----------------------------------------------------
echo Reinstalling %projectNameFull%
echo ----------------------------------------------------
echo.

set "currentAction=reinstall"
set "currentActionUpper=Reinstall"

goto :application_installation
pause

:No_Reinstallation

echo Gotcha, %projectName% will remain installed!
echo.

goto :endOfScript

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
