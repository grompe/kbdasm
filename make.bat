@echo off
set include=%~pd0fasm\include
if exist %windir%\sysnative\cmd.exe goto:relaunch64
if "%1"=="" goto:make
"%~pd0fasm\fasm.exe" %*
goto:eof
:make
"%~pd0fasm\fasm.exe" kbdusru.asm
"%~pd0fasm\fasm.exe" kbdusru_undead.asm
"%~pd0fasm\fasm.exe" reg_layout.asm
goto:eof
:relaunch64
%windir%\sysnative\cmd.exe /c "%~df0" %*
goto:eof
