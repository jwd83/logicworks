@echo off
echo ====================================
echo LogicWorks Love2D Package Builder
echo ====================================
echo.

set L2D_DIR=l2d
set LOVE_FILE=LogicWorks.love
set TEMP_DIR=temp_love_build

:: Clean and create l2d directory
echo Cleaning Love2D distribution directory...
if exist "%L2D_DIR%" rmdir /s /q "%L2D_DIR%"
mkdir "%L2D_DIR%"

:: Create temporary build directory
if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%"
mkdir "%TEMP_DIR%"

:: Copy only the game source files (no Love2D runtime)
echo Copying game source files...
copy main.lua "%TEMP_DIR%\"
copy components.lua "%TEMP_DIR%\"
copy grid.lua "%TEMP_DIR%\"
copy logic.lua "%TEMP_DIR%\"
copy ui.lua "%TEMP_DIR%\"

:: Copy documentation
copy README.md "%TEMP_DIR%\"
copy test_adder.lua "%TEMP_DIR%\"

:: Create conf.lua for Love2D configuration
echo Creating Love2D configuration...
(
echo function love.conf(t)
echo     t.identity = "LogicWorks"
echo     t.title = "LogicWorks - 2D Logic Workshop"
echo     t.author = "LogicWorks Team"
echo     t.url = "https://github.com/jwd83/logicworks"
echo     t.description = "Build and test digital logic circuits"
echo.
echo     t.window.title = "LogicWorks - Logic Workshop"
echo     t.window.icon = nil
echo     t.window.width = 1200
echo     t.window.height = 800
echo     t.window.borderless = false
echo     t.window.resizable = true
echo     t.window.minwidth = 800
echo     t.window.minheight = 600
echo     t.window.fullscreen = false
echo     t.window.fullscreentype = "desktop"
echo     t.window.vsync = 1
echo     t.window.msaa = 0
echo     t.window.highdpi = false
echo.
echo     t.modules.audio = true
echo     t.modules.event = true
echo     t.modules.graphics = true
echo     t.modules.image = true
echo     t.modules.joystick = false
echo     t.modules.keyboard = true
echo     t.modules.math = true
echo     t.modules.mouse = true
echo     t.modules.physics = false
echo     t.modules.sound = true
echo     t.modules.system = true
echo     t.modules.thread = false
echo     t.modules.timer = true
echo     t.modules.touch = false
echo     t.modules.video = false
echo     t.modules.window = true
echo end
) > "%TEMP_DIR%\conf.lua"

:: Create the .love file (just a renamed ZIP file)
echo Creating .love package...
powershell -command "Compress-Archive -Path '%TEMP_DIR%\*' -DestinationPath '%L2D_DIR%\%LOVE_FILE%' -Force"

:: Create installation instructions
echo Creating installation instructions...
(
echo LogicWorks - Love2D Distribution
echo ================================
echo.
echo This is a Love2D native package that requires Love2D to be installed.
echo.
echo Installation:
echo 1. Download and install Love2D from: https://love2d.org/
echo 2. Double-click LogicWorks.love to run the game
echo   OR
echo 3. Drag LogicWorks.love onto the Love2D executable
echo   OR  
echo 4. From command line: love LogicWorks.love
echo.
echo Advantages of .love files:
echo - Much smaller file size (source code only)
echo - Cross-platform (works on Windows, Mac, Linux)
echo - Easy to modify and inspect
echo - Standard Love2D distribution format
echo.
echo Game Info:
echo - Build Date: %DATE% %TIME%
echo - Repository: https://github.com/jwd83/logicworks
echo - Requires: Love2D 11.0 or later
echo.
echo Controls:
echo - Left Click: Select and place components
echo - Right Click: Delete components  
echo - Space: Step clock
echo - R: Reset simulation
echo - C: Clear all
) > "%L2D_DIR%\INSTALL.txt"

:: Create launcher script for convenience (if Love2D is in PATH)
echo Creating launcher script...
(
echo @echo off
echo echo Starting LogicWorks via Love2D...
echo love LogicWorks.love
echo if errorlevel 1 (
echo     echo.
echo     echo Error: Love2D not found in PATH
echo     echo Please install Love2D from https://love2d.org/
echo     echo Or drag LogicWorks.love onto love.exe
echo     pause
echo ^)
) > "%L2D_DIR%\run_with_love.bat"

:: Clean up temp directory
rmdir /s /q "%TEMP_DIR%"

:: Get file size of the .love file
for %%A in ("%L2D_DIR%\%LOVE_FILE%") do set LOVE_SIZE=%%~zA

echo.
echo ====================================
echo Love2D Package Complete!
echo ====================================
echo.
echo Package created: %L2D_DIR%\%LOVE_FILE%
echo File size: %LOVE_SIZE% bytes
echo.
echo Contents:
echo - LogicWorks.love (Love2D game package)
echo - INSTALL.txt (installation instructions)
echo - run_with_love.bat (launcher script)
echo.
echo To run:
echo 1. Install Love2D from https://love2d.org/
echo 2. Double-click LogicWorks.love
echo.
echo This .love file is cross-platform and much smaller than
echo the full executable distribution!
echo.
pause