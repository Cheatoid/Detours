@echo off
rem cd /d "%~dp0"

if defined DETOURS_ROOT (
    rem cd /d "%DETOURS_ROOT%"
    echo Using environment specified DETOURS_ROOT: %DETOURS_ROOT%
) else (
    set "DETOURS_ROOT=%~dp0"
    echo Using current directory as DETOURS_ROOT: %DETOURS_ROOT%
)

rem pushd "%DETOURS_ROOT%"
if not exist "%DETOURS_ROOT%\build.cmd" (
    echo build.cmd file was not found!
    exit /b 1
)
if not exist "%DETOURS_ROOT%\src" (
    echo src folder was not found!
    exit /b 1
)
if not exist "%DETOURS_ROOT%\vc" (
    echo vc folder was not found!
    exit /b 1
)

rmdir /s /q "%DETOURS_ROOT%\bin.X64" >NUL 2>&1
rmdir /s /q "%DETOURS_ROOT%\bin.X86" >NUL 2>&1
rmdir /s /q "%DETOURS_ROOT%\lib.X64" >NUL 2>&1
rmdir /s /q "%DETOURS_ROOT%\lib.X86" >NUL 2>&1
rmdir /s /q "%DETOURS_ROOT%\src\obj.X64" >NUL 2>&1
rmdir /s /q "%DETOURS_ROOT%\src\obj.X86" >NUL 2>&1
rmdir /s /q "%DETOURS_ROOT%\vc\DebugMDd" >NUL 2>&1
rmdir /s /q "%DETOURS_ROOT%\vc\Detours" >NUL 2>&1
rmdir /s /q "%DETOURS_ROOT%\vc\ReleaseMD" >NUL 2>&1
rmdir /s /q "%DETOURS_ROOT%\vc\x64" >NUL 2>&1
rem popd

if not exist "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" (
    echo vswhere program was not found; make sure to install Visual Studio!
    exit /b 2
)
for /f "usebackq tokens=* delims=" %%i in (`"C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -products * -latest -prerelease -requires Microsoft.Component.MSBuild -property installationPath`) do (
    set "InstallDir=%%i"
)
rem if defined VS_EDITION (
rem     echo Using environment specified VS_EDITION: %VS_EDITION%
rem     set "InstallDir=%InstallDir%\..\%VS_EDITION%"
rem )

rem cls
echo %InstallDir%

if not exist "%InstallDir%\VC\Auxiliary\Build\vcvars32.bat" (
    echo vcvars32.bat file was not found; make sure you have installed Windows SDK and x86 C++ workload!
    exit /b 3
)
setlocal
call "%InstallDir%\VC\Auxiliary\Build\vcvars32.bat"
if "%ERRORLEVEL%" equ "0" (
    pushd "%DETOURS_ROOT%"
    MSBuild.exe "%DETOURS_ROOT%\vc\Detours.sln" /property:Platform=x86 /property:Configuration=ReleaseMD /property:VcpkgEnabled=false
    popd
)
endlocal

if not exist "%InstallDir%\VC\Auxiliary\Build\vcvars64.bat" (
    echo vcvars64.bat file was not found; make sure you have installed Windows SDK and x64 C++ workload!
    exit /b 4
)
setlocal
call "%InstallDir%\VC\Auxiliary\Build\vcvars64.bat"
if "%ERRORLEVEL%" equ "0" (
    pushd "%DETOURS_ROOT%"
    MSBuild.exe "%DETOURS_ROOT%\vc\Detours.sln" /property:Platform=x64 /property:Configuration=ReleaseMD /property:VcpkgEnabled=false
    popd
)
endlocal

exit /b %ERRORLEVEL%
