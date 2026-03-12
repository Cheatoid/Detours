@echo off
rem CMake build script for Microsoft Detours
rem Builds both x86 and x64 DLLs

cd /d "%~dp0"

rem Allow passing a custom CMake generator as the first argument.  If none is
rem provided we default to the Visual Studio 18 2026 generator so that callers
rem such as build-release.yml can override it.
if "%~1"=="" (
    set "CMAKE_GENERATOR=Visual Studio 18 2026"
) else (
    set "CMAKE_GENERATOR=%~1"
)
echo Using CMake generator: %CMAKE_GENERATOR%

if defined DETOURS_ROOT (
    echo Using environment specified DETOURS_ROOT: %DETOURS_ROOT%
) else (
    set "DETOURS_ROOT=%~dp0"
    echo Using current directory as DETOURS_ROOT: %DETOURS_ROOT%
)

if not exist "%DETOURS_ROOT%\CMakeLists.txt" (
    echo CMakeLists.txt file was not found!
    exit /b 1
)
if not exist "%DETOURS_ROOT%\src" (
    echo src folder was not found!
    exit /b 1
)

rem Clean previous CMake builds
echo Cleaning previous build directories...
rmdir /s /q "%DETOURS_ROOT%\build_x86" >NUL 2>&1
rmdir /s /q "%DETOURS_ROOT%\build_x64" >NUL 2>&1
rmdir /s /q "%DETOURS_ROOT%\bin.X86" >NUL 2>&1
rmdir /s /q "%DETOURS_ROOT%\bin.X64" >NUL 2>&1
rmdir /s /q "%DETOURS_ROOT%\lib.X86" >NUL 2>&1
rmdir /s /q "%DETOURS_ROOT%\lib.X64" >NUL 2>&1

rem Find Visual Studio installation
if not exist "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" (
    echo vswhere program was not found; make sure to install Visual Studio!
    exit /b 2
)
for /f "usebackq tokens=* delims=" %%i in (`"C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -products * -latest -prerelease -requires Microsoft.Component.MSBuild -property installationPath`) do (
    set "InstallDir=%%i"
)

echo Visual Studio found at: %InstallDir%

if not exist "%InstallDir%\VC\Auxiliary\Build\vcvars32.bat" (
    echo vcvars32.bat file was not found; make sure you have installed Windows SDK and x86 C++ workload!
    exit /b 3
)
if not exist "%InstallDir%\VC\Auxiliary\Build\vcvars64.bat" (
    echo vcvars64.bat file was not found; make sure you have installed Windows SDK and x64 C++ workload!
    exit /b 4
)

rem Build x86
echo.
echo ========================================
echo Building Detours for x86 (32-bit)...
echo ========================================
setlocal
call "%InstallDir%\VC\Auxiliary\Build\vcvars32.bat"
if "%ERRORLEVEL%" equ "0" (
    cmake -B "%DETOURS_ROOT%\build_x86" -G "%CMAKE_GENERATOR%" -A Win32
    cmake --build "%DETOURS_ROOT%\build_x86" --config Release
    if exist "%DETOURS_ROOT%\build_x86\bin\Release\Detours.X86.dll" (
        if not exist "%DETOURS_ROOT%\bin.X86" mkdir "%DETOURS_ROOT%\bin.X86"
        if not exist "%DETOURS_ROOT%\lib.X86" mkdir "%DETOURS_ROOT%\lib.X86"
        copy /y "%DETOURS_ROOT%\build_x86\bin\Release\Detours.X86.dll" "%DETOURS_ROOT%\bin.X86\" >NUL
        copy /y "%DETOURS_ROOT%\build_x86\bin\Release\Detours.X86.pdb" "%DETOURS_ROOT%\bin.X86\" >NUL
        copy /y "%DETOURS_ROOT%\build_x86\lib\Release\Detours.X86.lib" "%DETOURS_ROOT%\lib.X86\" >NUL
        echo x86 build artifacts copied to bin.X86 and lib.X86
    )
)
endlocal

rem Build x64
echo.
echo ========================================
echo Building Detours for x64 (64-bit)...
echo ========================================
setlocal
call "%InstallDir%\VC\Auxiliary\Build\vcvars64.bat"
if "%ERRORLEVEL%" equ "0" (
    cmake -B "%DETOURS_ROOT%\build_x64" -G "%CMAKE_GENERATOR%" -A x64
    cmake --build "%DETOURS_ROOT%\build_x64" --config Release
    if exist "%DETOURS_ROOT%\build_x64\bin\Release\Detours.X64.dll" (
        if not exist "%DETOURS_ROOT%\bin.X64" mkdir "%DETOURS_ROOT%\bin.X64"
        if not exist "%DETOURS_ROOT%\lib.X64" mkdir "%DETOURS_ROOT%\lib.X64"
        copy /y "%DETOURS_ROOT%\build_x64\bin\Release\Detours.X64.dll" "%DETOURS_ROOT%\bin.X64\" >NUL
        copy /y "%DETOURS_ROOT%\build_x64\bin\Release\Detours.X64.pdb" "%DETOURS_ROOT%\bin.X64\" >NUL
        copy /y "%DETOURS_ROOT%\build_x64\lib\Release\Detours.X64.lib" "%DETOURS_ROOT%\lib.X64\" >NUL
        echo x64 build artifacts copied to bin.X64 and lib.X64
    )
)
endlocal

echo.
echo ========================================
echo Build Complete!
echo ========================================
echo x86 DLL: %DETOURS_ROOT%\bin.X86\Detours.X86.dll
echo x86 Lib: %DETOURS_ROOT%\lib.X86\Detours.X86.lib
echo x64 DLL: %DETOURS_ROOT%\bin.X64\Detours.X64.dll
echo x64 Lib: %DETOURS_ROOT%\lib.X64\Detours.X64.lib
echo ========================================

exit /b %ERRORLEVEL%
