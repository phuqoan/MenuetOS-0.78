

rem This file will create kernel.mnt, for the menuet disk image. It creates a directory rem called ..\output and places the file there.

rem set this to the path to your DOS/WINDOWS command line assembler
SET FASM=C:\WINDOWS\SYSTEM\FASM154.EXE

MD ..\OUTPUT

%FASM% KERNEL.ASM ..\OUTPUT\KERNEL.MNT

echo off
echo Completed. Check the output for any errors or warnings.
echo You can pipe the output to a text file like this:
echo "build > a.txt"
echo and look in a.txt for any errors or warnings
pause