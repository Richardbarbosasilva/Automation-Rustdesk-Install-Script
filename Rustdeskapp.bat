@echo off

if not DEFINED IS_MINIMIZED set IS_MINIMIZED=1 && start "" /min "%~dpnx0" %* && exit

::create some variables to tell the batch file where to find the powershell script.

set "caminhopastaatual=%~dp0Rustdeskappcredentials.ps1"

:: Verify if the file does exists

if exist "%caminhopastaatual%" (
    echo Rustdeskappcredentials.ps1 file found. Starting powershell.
    powershell -Command "Unblock-File -Path '\\arquivosdti.clickip.local\automacao_dados\pyinstall\Rustdeskappcredentials.ps1'"
    powershell.exe -WindowStyle minimized -NoProfile -ExecutionPolicy Bypass -File "%~dp0Rustdeskappcredentials.ps1" -verb runas
) else (
    goto :Filenotfound
)

:Filenotfound

echo Rustdeskappcredentials.ps1 script not found, verify its path and try once again.
exit

:: exit or pause

exit
