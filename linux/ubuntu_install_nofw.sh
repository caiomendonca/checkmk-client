#!/bin/bash

helpFunction()
{
   echo ""
   echo "Forma de utilização: $0 -u cmkadmin -p senhacmkadmin -h cmk-server -s central"
   echo -e "\t-u Nome de usuário do servidor CheckMK"
   echo -e "\t-p Senha do usuário do CheckMK"
   echo -e "\t-h Hostname do servidor CheckMK"
   echo -e "\t-s Nome do site CheckMK"
   exit 1 # Exit script after printing help
}

while getopts "u:p:h:s:" opt
do
   case "$opt" in
      u ) parameterU="$OPTARG" ;;
      p ) parameterP="$OPTARG" ;;
      h ) parameterH="$OPTARG" ;;
      s ) parameterS="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$parameterU" ] || [ -z "$parameterP" ] || [ -z "$parameterH" ] || [ -z "$parameterS" ]
then
   echo "Preencha todos os parametros";
   helpFunction
fi

# Begin script in case all parameters are correct

CURRENT_DIR=$PWD
CMK_SITE=$parameterS
CMK_USER=$parameterU
CMK_PASS=$parameterP
CMK_SERVER=$parameterH

AGENT_VERSION="2.2.0p7-1"
CMK_PORT="5000"
CMK_PORT_REGISTER="8000"
CMKIP=$(nslookup cmk-server | grep -A1 Name | tail -n1 | sed 's/Address: //')
## OBS: linha acima com nslookup precisa alterar para variavel e testar
# instala pacotes necessarios basicos
apt update -y
apt install dnsutils -y
apt install curl -y
apt install wget -y
#apt install iptables-persistent -y

# configura o iptables para permitir conexao com o servidor
#iptables -A INPUT -p tcp -s $CMKIP --dport 6556 -j ACCEPT -m comment --comment "CheckMK Monitoring port"
#iptables -A INPUT -p icmp -s $CMKIP -j ACCEPT -m comment --comment "CheckMK Monitoring ping"

# torna as regras criadas em persistentes
#echo iptables -A INPUT -p tcp -s $CMKIP --dport 6556 -j ACCEPT >> /etc/iptables/rules.v4
#echo iptables -A INPUT -p icmp -s $CMKIP -j ACCEPT >> /etc/iptables/rules.v4

# baixa e instala o agente
cd /tmp
wget http://${CMK_SERVER}:${CMK_PORT}/${CMK_SITE}/check_mk/agents/check-mk-agent_${AGENT_VERSION}_all.deb

dpkg -i check-mk-agent_${AGENT_VERSION}_all.deb
rm check-mk-agent_${AGENT_VERSION}_all.deb

# cria host no servidor
curl -X 'POST' \
  'http://'$CMK_SERVER':'$CMK_PORT'/'$CMK_SITE'/check_mk/api/1.0/domain-types/host_config/collections/all?bake_agent=false' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer '$CMK_USER' '$CMK_PASS'' \
  -H 'Content-Type: application/json' \
  -d '{
  "folder": "/",
  "host_name": '\"$HOSTNAME\"'
}'

# Configurar aqui para habilitar todos os serviços do agente

# Configurar aqui para aplicar host pendente

cmk-agent-ctl register --hostname $HOSTNAME --server $CMK_SERVER:$CMK_PORT_REGISTER --site $CMK_SITE --user $CMK_USER --password ${CMK_PASS} --trust-cert

cd $CURRENT_DIR

echo "Instalação finalizada"
