@echo off
title ELA - setting up....
setlocal EnableExtensions EnableDelayedExpansion

for /F "tokens=1,* delims=~= " %%a in (%~dp0\cons.txt) do set %%a=%%b

call %~dp0\intro.cmd

rem color 3f
echo Welcome
echo.

net session >nul 2>&1
if not %errorLevel%==0 (
	echo Failure: Current permissions inadequate. 
	echo.
	echo Exit and run as Administrator.
	goto END
)

ping 127.0.0.1 -n 2 > nul

for /f "tokens=2* delims= " %%d in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v path 2^>nul') do (
	for %%f in (%%~e) do (
		set globalpath=%%f;!globalpath!
		if %%f==%~dp0 (
			for /f "tokens=2* delims= " %%h in ('reg query HKEY_CURRENT_USER\Environment /v path 2^>nul') do (
				for %%j in (%%~i) do (
					if %%j==%~dp0 ( 
						echo Ela is already setup globally and locally.
						echo.
						echo Press anykey to exit....
						goto END
					)
				)
			)
			echo Ela is already setup globally.
			echo.
			choice /M "Also setup locally"
			echo.
			if !errorLevel!==1 ( goto :LOCALSETUP ) else ( echo Press anykey to exit.... )
			goto END
		)
	)
)

for /f "tokens=2* delims= " %%l in ('reg query HKEY_CURRENT_USER\Environment /v path 2^>nul') do (
	for %%n in (%%~m) do (
		set localpath=%%n;!localpath!
		if %%n==%~dp0 (
			echo Ela is already setup locally.
			echo.
			choice /M "Also setup globally"
			echo.
			if !errorLevel!==1 ( goto :GLOBALSETUP ) else ( echo Press anykey to exit.... )
			goto END
		)
	)
)

echo Configuring...
echo.
ping 127.0.0.1 -n 2 > nul

choice /M "Do yo want to setup globally"
echo.

if %errorLevel%==1 ( call :GLOBALSETUP ) else ( call :LOCALSETUP )
goto END

:GLOBALSETUP
echo Administrative permissions required. Detecting permissions...
echo.
ping 127.0.0.1 -n 2 > nul
net session >nul 2>&1
if not %errorLevel%==0 (
	echo Failure: Current permissions inadequate. 
	echo.
	echo Exit and run as Administrator.
) else (
	echo Success: Administrative permissions confirmed.
	echo.
	echo Setting globally...
	ping 127.0.0.1 -n 2 > nul
	setx /m path %~dp0;!globalpath!
	call :SETUPCOMPLETE
)
goto END

:LOCALSETUP
echo Setting locally...
ping 127.0.0.1 -n 2 > nul
setx path %~dp0;!localpath!

:SETUPCOMPLETE
ping 127.0.0.1 -n 5 > nul
echo.
echo Setup complete. Press anykey to exit....

:END
endlocal
pause > nul