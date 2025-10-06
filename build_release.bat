@echo off
echo ====================================
echo LogicWorks Release Builder
echo ====================================
echo.

set DIST_DIR=dist\LogicWorks
set TEMP_ZIP=logicworks_temp.zip

:: Clean and create dist directory
echo Cleaning distribution directory...
if exist "%DIST_DIR%" rmdir /s /q "%DIST_DIR%"
mkdir "%DIST_DIR%"

:: Copy Love2D runtime files
echo Copying Love2D runtime...
copy love.exe "%DIST_DIR%\LogicWorks.exe"
copy lovec.exe "%DIST_DIR%\LogicWorks_Console.exe"
echo Copying DLL files...
for %%f in (*.dll) do copy "%%f" "%DIST_DIR%\"
echo Copying ICO files...
for %%f in (*.ico) do copy "%%f" "%DIST_DIR%\"

:: Copy game source files
echo Copying game source files...
copy main.lua "%DIST_DIR%\"
copy components.lua "%DIST_DIR%\"
copy grid.lua "%DIST_DIR%\"
copy logic.lua "%DIST_DIR%\"
copy ui.lua "%DIST_DIR%\"

:: Copy documentation and tools
echo Copying documentation...
copy README.md "%DIST_DIR%\"
copy test_adder.lua "%DIST_DIR%\"

:: Create a launcher script for easy running
echo Creating launcher...
(
echo @echo off
echo echo Starting LogicWorks...
echo LogicWorks.exe .
echo pause
) > "%DIST_DIR%\Start_LogicWorks.bat"

:: Create version info file
echo Creating version info...
(
echo LogicWorks - 2D Logic Workshop Game
echo Version: 1.0.0 Beta
echo Build Date: %DATE% %TIME%
echo.
echo This is a standalone distribution of LogicWorks.
echo No additional installation required - just run Start_LogicWorks.bat
echo.
echo Controls:
echo - Left Click: Select and place components
echo - Right Click: Delete components
echo - Space: Step clock
echo - R: Reset simulation
echo - C: Clear all
echo.
echo For more information, see README.md
echo Repository: https://github.com/jwd83/logicworks
) > "%DIST_DIR%\VERSION.txt"

:: Create a distributable zip file (manual step)
echo.
echo Note: To create a distributable zip file:
echo 1. Navigate to the dist folder
echo 2. Right-click the LogicWorks folder
echo 3. Select "Send to" > "Compressed (zipped) folder"
echo 4. Rename to LogicWorks_v1.0.0_Beta.zip

echo.
echo ====================================
echo Build Complete!
echo ====================================
echo.
echo Distribution created in: %DIST_DIR%
echo To create zip: Follow the manual zip instructions above
echo.
echo Contents:
echo - LogicWorks.exe (main executable)
echo - LogicWorks_Console.exe (with console for debugging)
echo - All required DLLs and game files
echo - Start_LogicWorks.bat (easy launcher)
echo - README.md and documentation
echo.
echo Ready for distribution!
echo.
pause