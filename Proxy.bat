@echo off

::::::::::::::::::::::::::::::::::::::::::::
:: Elevate.cmd - Version 4
:: Automatically check & get admin rights
:: see "https://stackoverflow.com/a/12264592/1016343" for description
::::::::::::::::::::::::::::::::::::::::::::
@echo off
CLS
ECHO.
ECHO =============================
ECHO Running Admin shell
ECHO =============================

:init
setlocal DisableDelayedExpansion
set cmdInvoke=1
set winSysFolder=System32
set "batchPath=%~dpnx0"
rem this works also from cmd shell, other than %~0
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
ECHO.
ECHO **************************************
ECHO Invoking UAC for Privilege Escalation
ECHO **************************************

ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO args = "ELEV " >> "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"
  
if '%cmdInvoke%'=='1' goto InvokeCmd 

ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
goto ExecElevation

:InvokeCmd
ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
ECHO UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
"%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
exit /B

:gotPrivileges
setlocal & cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

::::::::::::::::::::::::::::
::START
::::::::::::::::::::::::::::

:choices
cls
mode con: cols=63 lines=15
set /A errorlevel=0 >nul
set /A choice=0 >nul
echo           ^_^_^_^_^_^_^_^_^_^_^_^_^_^_^_^_^_^_^_^_^_^_^_^_^_^_^_^_^_
echo          ^|                            ^|
echo          ^|  [1] Set Proxy Servers     ^|
echo          ^|    [2] Enable Proxy        ^|
echo          ^|    [3] Disable Proxy       ^|
echo          ^|      [4] To EXIT           ^|
echo          ^|                            ^|
echo          ^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=
echo.
echo You Can Also Press [CTRL]+[C] key Together To exit As well :D
echo.
echo.
set /p choice="What would you like To do: "
if "%choice%" == "1" goto 1 
if "%choice%" == "2" goto 2
if "%choice%" == "3" goto 3
if "%choice%" == "4" goto exit
goto :choices

:1
cls
echo                 [Set Proxy Server]
set /p server="Enter A  proxy Server: "
echo Yes|reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d %server% >nul
if "%errorlevel%" == "0" goto Done
if "%errorlevel%" == "1" goto Fail
goto choices

:2
cls
echo                   [Enable Proxy]
echo Yes|reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 >nul
if "%errorlevel%" == "0" goto Done
if "%errorlevel%" == "1" goto Fail
goto :choices

:3
cls
echo                  [Disable Proxy]
echo Yes|reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 >nul
if "%errorlevel%" == "0" goto Done
if "%errorlevel%" == "1" goto Fail
goto :choices

:exit
exit

:Done
echo.
echo                 ^[^>^>    Done^!    ^<^<^]
timeout /t 1 >nul
goto choices

:Fail
echo.
echo                 ^[^>^>    Failed ^:^(    ^<^<^]
timeout /t 1 >nul
goto choices