@echo off
setlocal

rem Local build without MingW: uses the GCC and make that ship with STM32CubeIDE.
rem
rem Usage:
rem   Build_Local.cmd                                   -> builds Candlelight WeActStudioV2 (STM32G431)
rem   Build_Local.cmd Build\Make_G431_Slcan_WeActStudioV2  -> builds any other makefile in folder Build
rem
rem Output: Build\STM32G431_Candlelight_WeActStudioV2\*.hex / *.bin / *.elf

rem Installation folder of STM32CubeIDE (the newest C:\ST\STM32CubeIDE_* is used if not set)
set "CUBE_IDE_DIR="

rem -------------------------------------------------------------------------------------------------

cd /d "%~dp0"

set "MAKEFILE=%~1"
if "%MAKEFILE%" == "" set "MAKEFILE=Build\Make_G431_Candle_WeActStudioV2"

if not exist "%MAKEFILE%" (
    echo Makefile not found: "%MAKEFILE%"
    exit /b 1
)

if "%CUBE_IDE_DIR%" == "" (
    for /D %%i in ("C:\ST\STM32CubeIDE_*") do set "CUBE_IDE_DIR=%%~fi"
)

set "PLUGINS=%CUBE_IDE_DIR%\STM32CubeIDE\plugins"
set "GCC_BIN="
set "MAKE_BIN="
for /D %%i in ("%PLUGINS%\com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.*") do set "GCC_BIN=%%~fi\tools\bin"
for /D %%i in ("%PLUGINS%\com.st.stm32cube.ide.mcu.externaltools.make.*") do set "MAKE_BIN=%%~fi\tools\bin"

if not exist "%GCC_BIN%\arm-none-eabi-gcc.exe" (
    echo arm-none-eabi-gcc not found. Set CUBE_IDE_DIR in this file.
    exit /b 1
)
if not exist "%MAKE_BIN%\make.exe" (
    echo make not found. Set CUBE_IDE_DIR in this file.
    exit /b 1
)

rem The make plugin also contains sh.exe and mkdir.exe, so no MingW is needed.
set "PATH=%GCC_BIN%;%MAKE_BIN%;%PATH%"

echo Toolchain: %GCC_BIN%
echo Compiling '%MAKEFILE%' ...
echo:

rem The compiler fails to correctly detect changes in sourcecode --> always re-build from scratch.
for /D %%i in ("Build\STM*") do rmdir /S /Q "%%~fi"

make -s -f "%MAKEFILE%" MKDIR="mkdir -p"
if errorlevel 1 (
    echo:
    echo Build FAILED.
    exit /b 1
)

echo:
echo Build OK. Output files:
for /D %%i in ("Build\STM*") do dir /B "%%~fi\*.hex" "%%~fi\*.bin"
for /D %%i in ("Build\STM*") do echo Folder: %%~fi
exit /b 0
