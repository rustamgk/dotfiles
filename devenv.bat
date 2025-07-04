@echo off
REM Rustam's Development Environment Manager for Windows (Batch)
REM Simple wrapper that calls the PowerShell script

setlocal enabledelayedexpansion

set "PROFILE=%1"
set "COMMAND=%2"

REM Default values
if "%PROFILE%"=="" set "PROFILE=personal"
if "%COMMAND%"=="" set "COMMAND=help"

REM Validate profile
if not "%PROFILE%"=="personal" if not "%PROFILE%"=="work_sarna" if not "%PROFILE%"=="work_sdui" (
    echo [ERROR] Invalid profile: %PROFILE%
    echo Valid profiles: personal, work_sarna, work_sdui
    echo Usage: devenv.bat [PROFILE] [COMMAND]
    exit /b 1
)

REM Check if PowerShell is available
powershell -Command "exit 0" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] PowerShell is not available
    echo Please ensure PowerShell is installed and in your PATH
    exit /b 1
)

REM Execute the PowerShell script with profile
powershell -ExecutionPolicy Bypass -File "%~dp0devenv.ps1" "%PROFILE%" "%COMMAND%"

exit /b %errorlevel%
