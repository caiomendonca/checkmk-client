@ECHO OFF

@setlocal enableextensions
@cd /d "%~dp0"

:: define ip do servidor do checkmk que será registrado
SET "CMK_SERVER=cmk-server"
SET "CMK_PORT=8000"
SET "CMK_SITE=central"
SET "CMK_USER=cmkadmin"
SET "CMK_PASS=changeme"

:: registra o agente no servidor
"C:\Program Files (x86)\checkmk\service\cmk-agent-ctl.exe" register --hostname %COMPUTERNAME% --server %CMK_SERVER%:%CMK_PORT% --site %CMK_SITE% --user %CMK_USER% --password "%CMK_PASS%" --trust-cert

pause
