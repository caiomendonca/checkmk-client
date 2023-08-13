@ECHO OFF

@setlocal enableextensions
@cd /d "%~dp0"

:: define ip do servidor do checkmk que será registrado
SET "CMK_SERVER=cmk-server"
SET "CMK_PORT=8000"
SET "CMK_SITE=central"
SET "CMK_USER=cmkadmin"
SET "CMK_PASS=changeme"

cd files
::move "%ProgramFiles(x86)%\checkmk\service\cmk-agent-ctl.exe" "%ProgramFiles(x86)%\checkmk\service\cmk-agent-ctl_bak.exe"
::copy cmk-agent-ctl_fix_register.exe "%ProgramFiles(x86)%\checkmk\service\cmk-agent-ctl.exe"

:: registra o agente no servidor
"C:\Program Files (x86)\checkmk\service\cmk-agent-ctl.exe" register --hostname %COMPUTERNAME% --server %CMK_SERVER%:%CMK_PORT% --site %CMK_SITE% --user %CMK_USER% --password "%CMK_PASS%" --trust-cert

:: volta versao do cmk-agent-ctl.exe original
::move "%ProgramFiles(x86)%\checkmk\service\cmk-agent-ctl.exe" "%ProgramFiles(x86)%\checkmk\service\cmk-agent-ctl_fix_register.exe"
::move "%ProgramFiles(x86)%\checkmk\service\cmk-agent-ctl_bak.exe" "%ProgramFiles(x86)%\checkmk\service\cmk-agent-ctl.exe"

pause
