@echo off
title ELA - removing....
setlocal EnableExtensions EnableDelayedExpansion
ping 127.0.0.1 -n 2 > NUL

set elapath=%~dp0

set pathwithoutela=!path:%elapath%=!
if "%pathwithoutela%"=="%path%" (
	echo Ela is not configured.
	goto END
)

net session >nul 2>&1
if not %errorLevel%==0 (
	echo Failure: Current permissions inadequate. 
	echo.
	ping 127.0.0.1 -n 2 > NUL
	echo Exit and run as Administrator.
	goto END
)

for /f "tokens=2* delims= " %%a in ('REG query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH 2^>nul') do ( set globalpath=%%~b )
set globalpath=!globalpath:%elapath%=!
setx /m path !globalpath!

ping 127.0.0.1 -n 2 > NUL

for /f "tokens=2* delims= " %%c in ('reg query HKEY_CURRENT_USER\Environment /v PATH 2^>nul') do ( set localpath=%%~d )
set localpath=!localpath:%elapath%=! 
setx path !localpath!

ping 127.0.0.1 -n 2 > NUL
echo.
echo Removal successfull.
echo.
ping 127.0.0.1 -n 1 > NUL
echo Press Press anykey to exit....

:END
pause>nul