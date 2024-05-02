#!/bin/bash

# Verifica se o usuário é root
if [ "$(id -u)" -ne 0 ]; then
  echo "Este script precisa ser executado como root" 1>&2
  exit 1
fi

# Atualiza os repositórios
apt update

# Instala o MySQL Server
apt install -y mysql-server

# Inicia o serviço do MySQL
systemctl start mysql

# Habilita o MySQL para iniciar na inicialização do sistema
systemctl enable mysql

# Configurações automáticas para o mysql_secure_installation
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Press y|Y for Yes, any other key for No:\"
send \"y\r\"
expect \"Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG:\"
send \"0\r\"
expect \"Remove anonymous users? (Press y|Y for Yes, any other key for No) :\"
send \"n\r\"
expect \"Disallow root login remotely? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect \"Remove test database and access to it? (Press y|Y for Yes, any other key for No) :\"
send \"n\r\"
expect \"Reload privilege tables now? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect eof
")

# Executa as configurações automáticas
echo "$SECURE_MYSQL"

echo "MySQL Server foi instalado, configurado e está em execução."
