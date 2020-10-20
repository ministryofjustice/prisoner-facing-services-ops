copy ".\Start Menu\*" "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
robocopy ".\Packages" "C:\Users\Default\AppData\Local\Packages" /mir
powershell.exe -ExecutionPolicy Bypass -File .\Provision.ps1
exit /b %errorlevel%