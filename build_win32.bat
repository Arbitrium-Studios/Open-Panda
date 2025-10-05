@echo off
title Open-Panda Builder
if not exist thirdparty/win-nsis (
    echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    echo Fetching ThirdParty Dependencies
    echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    if not exist panda3d-1.10.15-tools-win64.zip ( 
        "thirdparty\win-wget\wget" https://www.panda3d.org/download/panda3d-1.10.15/panda3d-1.10.15-tools-win64.zip
    )
    if not exist panda3d-1.10.15 ( 
        "thirdparty\win-7zip\7z" x panda3d-1.10.9-tools-win64.zip
    )
    robocopy "panda3d-1.10.15\thirdparty" "thirdparty" /E /NFL /MOVE
    rmdir /q panda3d-1.10.15
)

echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
echo Building Panda3D
echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
set /P THREADS="Thread Count: "
"thirdparty\win-python3.13-x64\python" makepanda/makepanda.py --everything --installer --msvc-version=14.3 --windows-sdk=11 --no-eigen --threads=%THREADS%
PAUSE

@echo off
title Open-Panda Builder
if not exist thirdparty/win-nsis (
    echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    echo Fetching ThirdParty Dependencies
    echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    if not exist panda3d-1.10.15-tools-win64.zip ( 
        "thirdparty\win-wget\wget" https://www.panda3d.org/download/panda3d-1.10.15/panda3d-1.10.15-tools-win64.zip
    )
    if not exist panda3d-1.10.15 ( 
        "thirdparty\win-7zip\7z" x panda3d-1.10.15-tools-win64.zip
    )
    robocopy "panda3d-1.10.15\thirdparty" "thirdparty" /E /NFL /MOVE
    rmdir /q panda3d-1.11.2
)

echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
echo Building Panda3D
echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
set /P THREADS="Thread Count: "
"thirdparty\win-python3.13-x64\python" makepanda/makepanda.py --everything --installer --msvc-version=14.3 --windows-sdk=11 --no-eigen --threads=%THREADS%
PAUSE
