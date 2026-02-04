@setlocal DisableDelayedExpansion
@echo off
set "scriptver=1.0"

set "_args=%*"
set "_elv="
if not defined _args goto :NoProgArgs
if "%~1"=="" set "_args="&goto :NoProgArgs
set _args=%_args:"=%
for %%A in (%_args%) do (
    if /i "%%A"=="-wow" (set _rel1=1) else if /i "%%A"=="-arm" (set _rel2=1)
)
:NoProgArgs

set "_cmdf=%~f0"
if exist "%SystemRoot%\Sysnative\cmd.exe" if not defined _rel1 (
    setlocal EnableDelayedExpansion
    start "" %SystemRoot%\Sysnative\cmd.exe /c ""!_cmdf!" -wow %*"
    exit /b
)
if exist "%SystemRoot%\SysArm32\cmd.exe" if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" if not defined _rel2 (
    setlocal EnableDelayedExpansion
    start "" %SystemRoot%\SysArm32\cmd.exe /c ""!_cmdf!" -arm %*"
    exit /b
)

set "SysPath=%SystemRoot%\System32"
set "Path=%SystemRoot%\System32;%SystemRoot%\System32\Wbem;%SystemRoot%\System32\WindowsPowerShell\v1.0\"
if exist "%SystemRoot%\Sysnative\reg.exe" (
    set "SysPath=%SystemRoot%\Sysnative"
    set "Path=%SystemRoot%\Sysnative;%SystemRoot%\Sysnative\Wbem;%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\;%Path%"
)

for /f "tokens=6 delims=[]. " %%i in ('ver') do set "build=%%i"

if %build% LSS 17763 (
    echo =============================================================
    echo   The script is compatible only with Windows 10 v1809 and later
    echo =============================================================
    echo.
    pause
    goto :EOF
)

reg query "HKU\S-1-5-19" 1>nul 2>nul
if %ERRORLEVEL% equ 0 goto :START_SCRIPT

echo =====================================================
echo   This script needs to be executed as Administrator.
echo =====================================================
echo.
pause
goto :EOF

:START_SCRIPT
set "FlightSigningEnabled=0"
bcdedit /enum {current} | findstr /I /R /C:"^flightsigning *Yes$" >nul 2>&1
if %ERRORLEVEL% equ 0 set "FlightSigningEnabled=1"

:CHOICE_MENU
cls
title InsiderEnroller v%scriptver%
set "choice="
echo.
echo 0 - Canary Channel
echo 1 - Dev Channel
echo 2 - Beta Channel
echo 3 - Release Preview Channel
echo.
echo 4 - Stop receiving Windows Insider builds
echo 5 - Exit without making any changes
echo.
set /p "choice=Choice: "
echo.
if /I "%choice%"=="0" goto :ENROLL_CAN
if /I "%choice%"=="1" goto :ENROLL_DEV
if /I "%choice%"=="2" goto :ENROLL_BETA
if /I "%choice%"=="3" goto :ENROLL_RP
if /I "%choice%"=="4" goto :STOP_INSIDER
if /I "%choice%"=="5" goto :EOF
goto :CHOICE_MENU

:ENROLL_RP
set "Channel=ReleasePreview"
set "Fancy=Release Preview Channel"
set "BRL=8"
set "Content=Mainline"
set "Ring=External"
set "RID=11"
goto :ENROLL

:ENROLL_BETA
set "Channel=Beta"
set "Fancy=Beta Channel"
set "BRL=4"
set "Content=Mainline"
set "Ring=External"
set "RID=11"
goto :ENROLL

:ENROLL_DEV
set "Channel=Dev"
set "Fancy=Dev Channel"
set "BRL=2"
set "Content=Mainline"
set "Ring=External"
set "RID=11"
goto :ENROLL

:ENROLL_CAN
set "Channel=CanaryChannel"
set "Fancy=Canary Channel"
set "BRL="
set "Content=Mainline"
set "Ring=External"
set "RID=11"
goto :ENROLL

:RESET_INSIDER_CONFIG
reg delete "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Account"              /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability"        /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Cache"                /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\ClientState"          /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI"                   /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Restricted"           /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\ToastNotification"    /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\WUMUDCat" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\Ring%Ring%" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingExternal" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingPreview" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingInsiderSlow" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingInsiderFast" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v BranchReadinessLevel /f >nul 2>&1
reg delete "HKLM\SYSTEM\Setup\WindowsUpdate" /v AllowWindowsUpdate /f >nul 2>&1
reg delete "HKLM\SYSTEM\Setup\MoSetup" /v AllowUpgradesWithUnsupportedTPMOrCPU /f >nul 2>&1
reg delete "HKLM\SYSTEM\Setup\LabConfig" /v BypassRAMCheck /f >nul 2>&1
reg delete "HKLM\SYSTEM\Setup\LabConfig" /v BypassSecureBootCheck /f >nul 2>&1
reg delete "HKLM\SYSTEM\Setup\LabConfig" /v BypassStorageCheck /f >nul 2>&1
reg delete "HKLM\SYSTEM\Setup\LabConfig" /v BypassTPMCheck /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\PCHC" /v UpgradeEligibility /f >nul 2>&1
goto :EOF

:ADD_INSIDER_CONFIG
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator" /f /t REG_DWORD /v EnableUUPScan /d 1 >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\Ring%Ring%" /f /t REG_DWORD /v Enabled /d 1 >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\WUMUDCat" /f /t REG_DWORD /v WUMUDCATEnabled /d 1 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /f /t REG_DWORD /v EnablePreviewBuilds /d 2 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /f /t REG_DWORD /v IsBuildFlightingEnabled /d 1 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /f /t REG_DWORD /v IsConfigSettingsFlightingEnabled /d 1 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /f /t REG_DWORD /v IsConfigExpFlightingEnabled /d 0 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /f /t REG_DWORD /v TestFlags /d 32 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /f /t REG_DWORD /v RingId /d %RID% >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /f /t REG_SZ /v Ring /d "%Ring%" >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /f /t REG_SZ /v ContentType /d "%Content%" >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /f /t REG_SZ /v BranchName /d "%Channel%" >nul

if %build% LSS 21990 (
    reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Strings" /f /t REG_SZ /v StickyXaml /d "<StackPanel xmlns=""http://schemas.microsoft.com/winfx/2006/xaml/presentation""><TextBlock Style=""{StaticResource BodyTextBlockStyle }"">This device has been enrolled to the Windows Insider program using InsiderEnroller v%scriptver%. If you want to change settings of the enrollment or stop receiving Windows Insider builds, please use the script. <Hyperlink NavigateUri=""https://github.com/abbodi1406/offlineinsiderenroll"" TextDecorations=""None"">Learn more</Hyperlink></TextBlock><TextBlock Text=""Applied configuration"" Margin=""0,20,0,10"" Style=""{StaticResource SubtitleTextBlockStyle}"" /><TextBlock Style=""{StaticResource BodyTextBlockStyle }"" Margin=""0,0,0,5""><Run FontFamily=""Segoe MDL2 Assets"">&#xECA7;</Run> <Span FontWeight=""SemiBold"">%Fancy%</Span></TextBlock><TextBlock Text=""Channel: %Channel%"" Style=""{StaticResource BodyTextBlockStyle }"" /><TextBlock Text=""Content: %Content%"" Style=""{StaticResource BodyTextBlockStyle }"" /><TextBlock Text=""Telemetry settings notice"" Margin=""0,20,0,10"" Style=""{StaticResource SubtitleTextBlockStyle}"" /><TextBlock Style=""{StaticResource BodyTextBlockStyle }"">Windows Insider Program requires your diagnostic data collection settings to be set to <Span FontWeight=""SemiBold"">Full</Span>. You can verify or modify your current settings in <Span FontWeight=""SemiBold"">Diagnostics & feedback</Span>.</TextBlock><Button Command=""{StaticResource ActivateUriCommand}"" CommandParameter=""ms-settings:privacy-feedback"" Margin=""0,10,0,0""><TextBlock Margin=""5,0,5,0"">Open Diagnostics & feedback</TextBlock></Button></StackPanel>" >nul
)

reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /f /t REG_DWORD /v UIHiddenElements /d 65535 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /f /t REG_DWORD /v UIDisabledElements /d 65535 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /f /t REG_DWORD /v UIServiceDrivenElementVisibility /d 0 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /f /t REG_DWORD /v UIErrorMessageVisibility /d 192 >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /f /t REG_DWORD /v AllowTelemetry /d 3 >nul

if defined BRL (
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f /t REG_DWORD /v BranchReadinessLevel /d %BRL% >nul
)

reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /f /t REG_DWORD /v UIHiddenElements_Rejuv /d 65534 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /f /t REG_DWORD /v UIDisabledElements_Rejuv /d 65535 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection" /f /t REG_SZ /v UIRing /d "%Ring%" >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection" /f /t REG_SZ /v UIContentType /d "%Content%" >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection" /f /t REG_SZ /v UIBranch /d "%Channel%" >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection" /f /t REG_DWORD /v UIOptin /d 1 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /f /t REG_SZ /v RingBackup /d "%Ring%" >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /f /t REG_SZ /v RingBackupV2 /d "%Ring%" >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /f /t REG_SZ /v BranchBackup /d "%Channel%" >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Cache" /f /t REG_SZ /v PropertyIgnoreList /d "AccountsBlob;;CTACBlob;FlightIDBlob;ServiceDrivenActionResults" >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Cache" /f /t REG_SZ /v RequestedCTACAppIds /d "WU;FSS" >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Account" /f /t REG_DWORD /v SupportedTypes /d 3 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Account" /f /t REG_DWORD /v Status /d 8 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /f /t REG_DWORD /v UseSettingsExperience /d 0 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\ClientState" /f /t REG_DWORD /v AllowFSSCommunications /d 0 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\ClientState" /f /t REG_DWORD /v UICapabilities /d 1 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\ClientState" /f /t REG_DWORD /v IgnoreConsolidation /d 1 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\ClientState" /f /t REG_DWORD /v MsaUserTicketHr /d 0 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\ClientState" /f /t REG_DWORD /v MsaDeviceTicketHr /d 0 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\ClientState" /f /t REG_DWORD /v ValidateOnlineHr /d 0 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\ClientState" /f /t REG_DWORD /v LastHR /d 0 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\ClientState" /f /t REG_DWORD /v ErrorState /d 0 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\ClientState" /f /t REG_DWORD /v PilotInfoRing /d 3 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\ClientState" /f /t REG_DWORD /v RegistryAllowlistVersion /d 4 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\ClientState" /f /t REG_DWORD /v FileAllowlistVersion /d 1 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI" /f /t REG_DWORD /v UIControllableState /d 0 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection" /f /t REG_DWORD /v UIDialogConsent /d 0 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection" /f /t REG_DWORD /v UIUsage /d 26 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection" /f /t REG_DWORD /v OptOutState /d 25 >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection" /f /t REG_DWORD /v AdvancedToggleState /d 24 >nul
reg add "HKLM\SYSTEM\Setup\WindowsUpdate" /f /t REG_DWORD /v AllowWindowsUpdate /d 1 >nul
reg add "HKLM\SYSTEM\Setup\MoSetup" /f /t REG_DWORD /v AllowUpgradesWithUnsupportedTPMOrCPU /d 1 >nul
reg add "HKLM\SYSTEM\Setup\LabConfig" /f /t REG_DWORD /v BypassRAMCheck /d 1 >nul
reg add "HKLM\SYSTEM\Setup\LabConfig" /f /t REG_DWORD /v BypassSecureBootCheck /d 1 >nul
reg add "HKLM\SYSTEM\Setup\LabConfig" /f /t REG_DWORD /v BypassStorageCheck /d 1 >nul
reg add "HKLM\SYSTEM\Setup\LabConfig" /f /t REG_DWORD /v BypassTPMCheck /d 1 >nul
reg add "HKCU\SOFTWARE\Microsoft\PCHC" /f /t REG_DWORD /v UpgradeEligibility /d 1 >nul

if %build% LSS 21990 goto :EOF

:: For Windows 11 builds — simplified registry import for StickyMessage
(
    echo Windows Registry Editor Version 5.00
    echo.
    echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Strings]
    echo "StickyMessage"="{\"Message\":\"Device Enrolled Using InsiderEnroller v%scriptver%\",\"LinkTitle\":\"\",\"LinkUrl\":\"\",\"DynamicXaml\":\"^<StackPanel xmlns=\\\\\"http://schemas.microsoft.com/winfx/2006/xaml/presentation\\\\\"^>^<TextBlock Style=\\\\\"{StaticResource BodyTextBlockStyle }\\\\\"^>This device has been enrolled to the Windows Insider program using InsiderEnroller v%scriptver%. If you want to change settings of the enrollment or stop receiving Windows Insider builds, please use the script. ^<Hyperlink NavigateUri=\\\\\"https://github.com/abbodi1406/offlineinsiderenroll\\\\\" TextDecorations=\\\\\"None\\\\\"^>Learn more^</Hyperlink^>^</TextBlock^>^<TextBlock Text=\\\\\"Applied configuration\\\\\" Margin=\\\\\"0,20,0,10\\\\\" Style=\\\\\"{StaticResource SubtitleTextBlockStyle}\\\" /^>^<TextBlock Style=\\\\\"{StaticResource BodyTextBlockStyle }\\\\\" Margin=\\\\\"0,0,0,5\\\\\"^>^<Run FontFamily=\\\\\"Segoe MDL2 Assets\\\\\"^>^&#xECA7;^</Run^> ^<Span FontWeight=\\\\\"SemiBold\\\\\"^>%Fancy%^</Span^>^</TextBlock^>^<TextBlock Text=\\\\\"Channel: %Channel%\\\\\" Style=\\\\\"{StaticResource BodyTextBlockStyle }\\\\\" /^>^<TextBlock Text=\\\\\"Content: %Content%\\\\\" Style=\\\\\"{StaticResource BodyTextBlockStyle }\\\\\" /^>^<TextBlock Text=\\\\\"Telemetry settings notice\\\\\" Margin=\\\\\"0,20,0,10\\\\\" Style=\\\\\"{StaticResource SubtitleTextBlockStyle}\\\" /^>^<TextBlock Style=\\\\\"{StaticResource BodyTextBlockStyle }\\\\\"^>Windows Insider Program requires your diagnostic data collection settings to be set to ^<Span FontWeight=\\\\\"SemiBold\\\\\"^>Full^</Span^>. You can verify or modify your current settings in ^<Span FontWeight=\\\\\"SemiBold\\\\\"^>Diagnostics ^& feedback^</Span^>.^</TextBlock^>^<Button Command=\\\\\"{StaticResource ActivateUriCommand}\\\" CommandParameter=\\\\\"ms-settings:privacy-feedback\\\\\" Margin=\\\\\"0,10,0,0\\\\\"^>^<TextBlock Margin=\\\\\"5,0,5,0\\\\\"^>Open Diagnostics ^& feedback^</TextBlock^>^</Button^>^</StackPanel^>\",\"Severity\":0}"
    echo.
) > "%temp%\oie.reg"
reg import "%temp%\oie.reg" >nul 2>&1
del "%temp%\oie.reg" >nul 2>&1
goto :EOF

:ENROLL
echo Applying changes...
call :RESET_INSIDER_CONFIG >nul 2>&1
call :ADD_INSIDER_CONFIG >nul 2>&1
bcdedit /set {current} flightsigning yes >nul 2>&1
echo Done.
echo.
if %FlightSigningEnabled% neq 1 goto :ASK_FOR_REBOOT
echo Press any key to exit...
pause >nul
goto :FINAL_PAUSE

:STOP_INSIDER
echo Applying changes...
call :RESET_INSIDER_CONFIG >nul 2>&1
bcdedit /deletevalue {current} flightsigning >nul 2>&1
echo Done.
echo.
if %FlightSigningEnabled% neq 0 goto :ASK_FOR_REBOOT
echo Press any key to exit...
pause >nul
goto :FINAL_PAUSE

:ASK_FOR_REBOOT
set "choice="
echo A reboot is required to finish applying changes.
set /p "choice=Would you like to reboot your PC? (y/N) "
if /I "%choice%"=="y" shutdown -r -t 0
goto :FINAL_PAUSE

:FINAL_PAUSE
echo.
echo Script execution finished.
echo Press any key to close this window...
pause >nul
goto :EOF
