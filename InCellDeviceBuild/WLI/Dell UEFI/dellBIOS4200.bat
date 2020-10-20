@echo off 
REM Set Variables

REM Passwords
set passwordOriginal=   Vault-BWI-WLI-Dell-UEFI https://prisoner-ops-vault.vault.azure.net/
set passwordNew=        Vault-BWI-WLI-Dell-UEFI https://prisoner-ops-vault.vault.azure.net/ 

REM Set Date / Time to string for log name 
set testChar=%Date:~0,1%
set hour=%time:~0,2%
if "%hour:~0,1%" == " " set hour=0%hour:~1,1%
rem UK - set shdate_Time=%date:~0,2%%date:~3,2%%date:~6,4%_%hour%%time:~3,2%%time:~6,2%
rem us - set shdate_Time=%Date:~7,2%%Date:~4,2%%Date:~10,4%_%hour%%time:~3,2%

if %testChar% LSS 10 GOTO:UK

:US
set shdate_Time=%Date:~7,2%%Date:~4,2%%Date:~10,4%_%hour%%time:~3,2%
GOTO:skip_date

:UK
set shdate_Time=%date:~0,2%%date:~3,2%%date:~6,4%_%hour%%time:~3,2%%time:~6,2%

:skip_date

rem Log Names and Locations
set appVersion=4.2.0.0
set releaseVersion=005
set pathExecution=%~dp0
rem set pathExecution=C:\dellBIOS\x86_64\
set logDestination=x:\windows\temp\
set logName=dell_bios_%appVersion%_%releaseVersion%_%shdate_Time%
set pathLog=%logDestination%%logName%.log
set pathSuccess=%logDestination%%logName%_success.txt

rem Set Document Details
echo Dell 3190 Config 05/08/2019 Revsion %releaseVersion% -Author: S Abraham >> %pathLog%
Echo %shdate_Time% - Starting Logging of Dell Bios configuration >> %pathLog%

echo execution path set to: %pathExecution% >> %pathLog%
if Not Exist %pathSuccess% GOTO BEGIN
Del /f /q %pathSuccess% >> %pathLog%

:Begin
echo Check is HAPI is installed >> %pathLog%
rem set $drvs=driverquery.exe 

echo Install Dell HAPI >> %pathLog%
call %pathExecution%HAPI\HAPInt64.exe -i -k C-C-T-K -p "hapint64.exe" >> %pathLog%

echo ACTION - Determine if BIOS Password set >> %pathLog%
%pathExecution%cctk.exe --NumLock=Enabled >> %pathLog%
If %ERRORLEVEL% == 0 GOTO setValues

echo MESSAGE - Password must have been set, going to try to wipe  >> %pathLog%
%pathExecution%cctk.exe --setuppwd= --ValSetupPwd=%passwordOriginal%

If %ERRORLEVEL% == 0 GOTO setValues
echo ERROR - could not access BIOS - ending  >> %pathLog%
goto endFailure

:setValues
Change here for BIOS options 
echo ACTION - Turn off NumLock >> %pathLog%
%pathExecution%cctk.exe --NumLock=Disabled >> %pathLog%

echo ACTION - Enable UEFI network stack >> %pathLog%
%pathExecution%cctk.exe --uefinwstack=enable >> %pathLog%

echo ACTION - Disable Bluetooth >> %pathLog%
%pathExecution%cctk.exe --bluetoothdevice=disable >> %pathLog%

echo ACTION - Ignore Power Warnings >> %pathLog%
%pathExecution%cctk.exe --PowerWarn=Disabled >> %pathLog%

rem echo ACTION - Disable USB Boot >> %pathLog%
rem %pathExecution%cctk.exe --UsbEmuNoUsbBoot >> %pathLog%

rem echo MESSAGE - Current active boot list >> %pathLog%
rem %pathExecution%cctk.exe bootorder --activebootlist >> %pathLog%

echo ACTION - Enable UEFI >> %pathLog%
%pathExecution%cctk.exe bootorder --activebootlist=uefi >> %pathLog%

echo ACTION - Disable USB Boot >> %pathLog%
%pathExecution%cctk.exe bootorder --UsbPorts=EnableBackOnly >> %pathLog%

echo MESSAGE - Legacy ROM setting >> %pathLog%
%pathExecution%cctk.exe --legacyorom >> %pathLog%

echo ACTION - Disable Legacy ROMs >> %pathLog%
%pathExecution%cctk.exe --legacyorom=disable >> %pathLog%

echo MESSAGE - Secure boot setting >> %pathLog%
%pathExecution%cctk.exe --secureboot >> %pathLog%

echo ACTION - enable Secure boot >> %pathLog%
%pathExecution%cctk.exe --secureboot=enable >> %pathLog%

echo ACTION - Enable UEFI network stack >> %pathLog%
%pathExecution%cctk.exe --uefinwstack=enable >> %pathLog%

rem echo ACTION - Set PXE on next boot >> %pathLog%
rem %pathExecution%cctk.exe --forcepxeonnextboot=enable >> %pathLog%

echo ACTION - Set BIOS Password >> %pathLog%
%pathExecution%cctk.exe --setuppwd=%passwordNew%

echo ACTION - Disable UEFI Boot Path Security >> %pathLog%
%pathExecution%cctk.exe --uefibootpathsecurity=never --ValSetupPwd=%passwordNew%

echo ACTION - Brightness Settings >> %pathLog%
%pathExecution%cctk.exe --BrightnessBattery=14 --ValSetupPwd=%passwordNew%
%pathExecution%cctk.exe --BrightnessAC=14 --ValSetupPwd=%passwordNew%


rem TPM routine for bitlocker arming
rem echo ACTION - Set TPM on >> %pathLog%
rem %pathExecution%cctk.exe --tpm=on --ValSetupPwd=%passwordNew%
rem echo ACTION - Set TPM activated >> %pathLog%
rem %pathExecution%cctk.exe --tpmactivation=activate --ValSetupPwd=%passwordNew%
rem Error level 0 indicates success
If  %ERRORLEVEL% == 0 GOTO endSuccess

rem end routines
:endFailure
echo Failure - %ERRORLEVEL% >> %pathLog%
Exit

:endSuccess
echo Success - %ERRORLEVEL% >> %pathLog%
Exit