#!/bin/bash
echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
echo Installing Panda3D
echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
echo Mounting DMG...
"/usr/bin/hdiutil" attach Open-Panda-1.11.2-py3.13.dmg
echo Running Installer...
sudo installer -pkg "/Volumes/Panda3D SDK 1.11.2/Panda3D.mpkg" -verboseR -target "/Library/Developer/"
echo Detaching...
"/usr/bin/hdiutil" detach "/Volumes/Panda3D SDK 1.11.2" -force
echo Installed
