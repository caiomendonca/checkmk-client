@ECHO OFF

@setlocal enableextensions
@cd /d "%~dp0"

:: define ip do servidor do checkmk que será registrado
SET "CMK_SERVER=cmk-server"
SET "CMK_PORT=8000"
SET "CMK_SITE=central"
SET "CMK_USER=cmkadmin"
SET "CMK_PASS=changeme"

FOR /F "tokens=2 delims=[]" %%F IN ('PING -4 -n 1 %CMK_SERVER%') DO SET "CMKIP=%%F"

:: cria regra de firewall liberando acesso do servidor ao cliente na porta 28250
netsh advfirewall firewall add rule name="Checkmk Agent" dir=in action=allow protocol=TCP localport=28250 remoteip=%CMKIP%
netsh advfirewall firewall add rule name="Checkmk Agent ICMP" dir=in action=allow protocol=ICMP remoteip=%CMKIP%

:: instala o agente no modo "Clean Install" e copia ctl que consegue registrar no servidor
cd files
msiexec /i check_mk_agent_2.2.0p7.msi /qn /L*V install.log WIXUI_CLEANINSTALL= WIXUI_REMOVELEGACY="" WIXUI_MIGRATELEGACY=""

# Configurar aqui o casdastro do host no servidor

# Configurar aqui para habilitar todos os serviços do agente

# Configurar aqui para aplicar host pendente

:: registra o agente no servidor
"C:\Program Files (x86)\checkmk\service\cmk-agent-ctl.exe" register --hostname %COMPUTERNAME% --server %CMK_SERVER%:%CMK_PORT% --site %CMK_SITE% --user %CMK_USER% --password "%CMK_PASS%" --trust-cert



pause
