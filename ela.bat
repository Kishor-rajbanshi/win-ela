@ECHO off

REM COLOR 3F

SETLOCAL EnableExtensions EnableDelayedExpansion

FOR /F "tokens=1,* delims=~= " %%a IN (%~dp0\cons.txt) DO (
	IF "%%a" == "PATH" (
		SET INPUT_PATH=%%b;!INPUT_PATH!
	)ELSE (
		SET %%a=%%b
	)
)

SET EXPLOADED_INPUT_PATH=!INPUT_PATH:;=, !

FOR /F "skip=2 tokens=1,2*" %%N IN ('%SystemRoot%\System32\reg.exe QUERY "HKCU\Environment" /V "Path" 2^>nul') DO IF /I "%%N" == "Path" CALL SET "USERPATH=%%P"

ECHO Initializing [101;93m ELA... [0m

IF "%1" == "start" GOTO :START
IF "%1" == "stop" GOTO :STOP
IF "%1" == "restart" GOTO :RESTART
IF "%1" == "set" GOTO :SET
IF "%1" == "unset" GOTO :UNSET

CALL intro.cmd
GOTO END

:START
IF "%2"=="" GOTO END
IF NOT "%2"=="nginx" IF NOT "%2"=="mysql" IF NOT "%2"=="php-cgi" IF NOT "%2"=="php" (
	ECHO [41m %2 [0m not found. 
	GOTO END
)
QPROCESS * | FIND /I /N "%2.exe">NUL
IF "%ERRORLEVEL%"=="0" (
	ECHO [32m "%2" is already running. [0m
)ELSE (
	ECHO [36m starting "%2"... [0m
	IF "%2"=="nginx" (
		CD /D !nginx_dir! 
		START /WAIT RunHiddenConsole %2
	)
	IF "%2"=="mysql" START /WAIT RunHiddenConsole mysqld --console
	IF "%2"=="php-cgi" START /WAIT RunHiddenConsole %2 -b 127.0.0.1:9000
	IF "%2"=="php" CALL :PHP_SERVER
	ECHO [92m "%2" started. [0m
)
SHIFT
GOTO START

:STOP
IF "%2"=="" GOTO END
QPROCESS * | FIND /I /N "%2.exe">NUL
IF "%2"=="mysql" QPROCESS * | FIND /I /N "mysqld.exe">NUL
IF "%ERRORLEVEL%"=="0" (
	IF "%2"=="mysql" (
		TASKKILL /F /IM mysqld.exe>NUL
	)ELSE (
		TASKKILL /F /IM %2.exe>NUL
	)
	ECHO [31m "%2" Shutdown complete. [0m
)ELSE (
	ECHO [33m "%2" is not running. [0m
)
SHIFT
GOTO STOP

:PHP_SERVER
ECHO.
ECHO [34m available scripts [0m
FOR /f "usebackq tokens=*" %%e in (`DIR /b /a:d !php_root_dir!`) DO (
	ECHO [93m %%~nxe [0m
)
ECHO.
SET /P script=[101;43m TYPE THE SCRIPT NAME TO RUN : [0m
ECHO.
IF [%script%] == [] (
	ECHO [41m "%script%" Please type available script name. [0m
	GOTO PHP_SERVER
)
IF NOT EXIST !php_root_dir!/%script% (
	ECHO [41m "%script%" script not found. [0m
	GOTO PHP_SERVER
)
CD /D !php_root_dir!/%script%
START /WAIT RunHiddenConsole php -S 0.0.0.0:8080
ECHO Development Server @ http://localhost:8080
GOTO END

:RESTART
IF "%2"=="" GOTO END
QPROCESS * | FIND /I /N "%2.exe">NUL
IF "%2"=="mysql" QPROCESS * | FIND /I /N "mysqld.exe">NUL
IF "%ERRORLEVEL%"=="0" (
	IF "%2"=="mysql" (
		TASKKILL /F /IM mysqld.exe>NUL
	)ELSE (
		TASKKILL /F /IM %2.exe>NUL
	)
	ECHO [31m "%2" Restarting. [0m
	IF "%2"=="nginx" (
		CD /D !nginx_dir!
		START /WAIT RunHiddenConsole %2
	)
	IF "%2"=="mysql" START /WAIT RunHiddenConsole mysqld --console
	IF "%2"=="php-cgi" START /WAIT RunHiddenConsole %2 -b 127.0.0.1:9000
	IF "%2"=="php" CALL :PHP_SERVER
	ECHO [92m "%2" started. [0m

)ELSE (
	ECHO [33m "%2" is not running. [0m
)
SHIFT
GOTO RESTART

:SET
ECHO.
IF "%2" == "path" (
	FOR %%a IN (!EXPLOADED_INPUT_PATH!) DO (
		SET USERPATH=!USERPATH:%%a;=!%%a;
		ECHO "%%a" -^>[92m complete [0m
	)
	SETX PATH !USERPATH!
	ECHO Restart command prompt to apply changes.
)
IF "%2" == "composer_home" (
	SETX COMPOSER_HOME !COMPOSER_HOME!
	ECHO "COMPOSER_HOME => !COMPOSER_HOME!" [92m complete [0m
)
GOTO END

:UNSET
ECHO.
IF "%2" == "path" (
	For %%a IN (!EXPLOADED_INPUT_PATH!) DO (
		SET USERPATH=!USERPATH:%%a;=!
		ECHO "%%a" -^>[92m complete [0m
	)
	SETX PATH !USERPATH!
	ECHO Restart command prompt to apply changes.
)
IF "%2" == "composer_home" (
	REG delete HKCU\Environment /F /V COMPOSER_HOME
)
GOTO END

REM For /F "tokens=1,* delims= " %%c in ("%*") DO SET ALL_BUT_FIRST_ARG=%%d

:END
rem COLOR 0F