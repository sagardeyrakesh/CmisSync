@echo off

REM call %~dp0\..\Common\Plugins\build.cmd

set WinDirNet=%WinDir%\Microsoft.NET\Framework
set msbuild="%WinDirNet%\v4.0\msbuild.exe"
if not exist %msbuild% set msbuild="%WinDirNet%\v4.0.30319\msbuild.exe"
set wixBinDir=%WIX%\bin

if not exist ..\..\bin mkdir ..\..\bin
if not exist ..\..\bin\installer mkdir ..\..\bin\installer
copy Pixmaps\cmissync-app.ico ..\..\bin\

%msbuild% /t:Clean,Build /p:Configuration=Release /p:Platform="Any CPU" "%~dp0\CmisSync.sln"

if "%1"=="installer" (
	if exist "%wixBinDir%" (
	  if exist "%~dp0\..\..\bin\installer\Oris4Sync.msi" del "%~dp0\..\..\bin\installer\Oris4Sync.msi"
	  if exist "%~dp0\..\..\bin\installer\Oris4Sync.exe" del "%~dp0\..\..\bin\installer\Oris4Sync.exe"
		"%wixBinDir%\heat.exe" dir "%~dp0\..\..\CmisSync\Common\Plugins" -cg pluginsComponentGroup -gg -scom -sreg -sfrag -srd -dr PLUGINS_DIR -var wix.pluginsdir -o plugins.wxs
		"%wixBinDir%\candle" "%~dp0\CmisSync.wxs" -ext WixUIExtension -ext WixUtilExtension -ext WiXNetFxExtension
		"%wixBinDir%\candle" "%~dp0\plugins.wxs" -ext WixUIExtension -ext WixUtilExtension -ext WiXNetFxExtension
		"%wixBinDir%\light" -ext WixUIExtension -ext WixUtilExtension -ext WiXNetFxExtension -cultures:en-us CmisSync.wixobj plugins.wixobj -droot="%~dp0\..\.." -dpluginsdir="%~dp0\..\..\CmisSync\Common\Plugins"  -o "%~dp0\..\..\bin\installer\Oris4Sync.msi" 
		if exist "%~dp0\..\..\bin\installer\Oris4Sync.msi" echo Oris4Sync.msi created.

		"%wixBinDir%\candle" "%~dp0\Oris4Sync.wxs" -ext WixUIExtension -ext WixUtilExtension -ext WiXNetFxExtension -ext WixBalExtension
		"%wixBinDir%\light" -ext WixUIExtension -ext WixUtilExtension -ext WiXNetFxExtension -ext WixBalExtension -cultures:en-us Oris4Sync.wixobj -droot="%~dp0\..\.." -o "%~dp0\..\..\bin\installer\Oris4Sync.exe" 
		if exist "%~dp0\..\..\bin\installer\Oris4Sync.exe" echo Oris4Sync.exe created.

	) else (
		echo Not building installer ^(could not find wix, Windows Installer XML toolset^)
		echo wix is available at http://wix.sourceforge.net/
	)
) else echo Not building installer, as it was not requested. ^(Issue "build.cmd installer" to build installer ^)

