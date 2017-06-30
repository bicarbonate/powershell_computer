@echo off
setlocal
if {%3}=={} goto err
set Name=%1
set Action=%2
set NbtO=0xN
set GUID=none
set key=HKLM\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces\Tcpip
call InterfaceGUID %Name% GUID
if "%GUID%" EQU "none" goto err
set key="%key%_%GUID%"
if /i "%Action%" EQU "R" goto Read
if /i "%Action%" EQU "W" goto Write
:err
@echo Syntax EnableNBT Name Action Setting
endlocal
goto :EOF
:Read
for /f "Tokens=3" %%n in ('reg query %key% /v NetbiosOptions') do (
 set NbtO=%%n
)
set NbtO=%NbtO:~2,1%
endlocal&set %3=%NbtO%
goto :EOF
:Write
call set NbtO=%%%3%%
call :quiet>nul 2>&1
if ERRORLEVEL 0 goto finish
@echo EnableNBT was unable to update NetbiosOptions - %key%
:finish
endlocal
goto :EOF
:quiet
reg add %key% /v NetbiosOptions /t REG_DWORD /d %NbtO% /f