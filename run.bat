@echo off
echo LogicWorks - 2D Logic Workshop Game
echo ====================================
echo.
echo Checking for Love2D installation...

REM Check if love is in PATH
where love >nul 2>&1
if %errorlevel% == 0 (
    echo Found Love2D in PATH. Starting game...
    love .
    goto :end
)

REM Check for common Love2D installation paths
set "LOVE_PATHS=C:\Program Files\LOVE\love.exe;C:\Program Files (x86)\LOVE\love.exe"

for %%i in (%LOVE_PATHS%) do (
    if exist "%%i" (
        echo Found Love2D at %%i
        echo Starting game...
        "%%i" .
        goto :end
    )
)

REM Check for portable Love2D in current directory
if exist "love.exe" (
    echo Found portable Love2D in current directory.
    echo Starting game...
    love.exe .
    goto :end
)

echo.
echo Love2D not found! Please:
echo 1. Download Love2D from https://love2d.org/
echo 2. Install it or place love.exe in this directory
echo 3. Run this script again
echo.
pause

:end