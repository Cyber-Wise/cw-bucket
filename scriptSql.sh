#!/bin/bash

# Verifica se o usuário é root
if [ "$(id -u)" -ne 0 ]; then
  echo "Este script precisa ser executado como root" 1>&2
  exit 1
fi

# Atualiza os repositórios
apt update

#Ajustar hora do sitema
timedatectl set-timezone America/Sao_Paulo

# Instala o MySQL Server
apt install -y mysql-server

# Inicia o serviço do MySQL
systemctl start mysql

# Habilita o MySQL para iniciar na inicialização do sistema
systemctl enable mysql

# Instala o pacote expect se necessário
if ! command -v expect &>/dev/null; then
  echo "Instalando o pacote expect..."
  apt-get update
  apt-get install -y expect
fi

# Configurações automáticas para o mysql_secure_installation
SECURE_MYSQL=$(expect -c "
spawn mysql_secure_installation
set timeout 100
expect \"Press y|Y for Yes, any other key for No:\"
send \"y\r\"
set timeout 100
expect \"Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG:\"
send \"0\r\"
set timeout 100
expect \"Remove anonymous users? (Press y|Y for Yes, any other key for No) :\"
send \"n\r\"
set timeout 100
expect \"Disallow root login remotely? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
set timeout 100
expect \"Remove test database and access to it? (Press y|Y for Yes, any other key for No) :\"
send \"n\r\"
set timeout 100
expect \"Reload privilege tables now? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect eof
")

# Executa as configurações automáticas
echo "$SECURE_MYSQL"

# Define uma senha para o usuário root e cria o usuário cyberwise com todas as permissões
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'cyber100'; \
          CREATE USER 'cyberwise'@'%' IDENTIFIED BY 'cyber100'; \
          GRANT ALL PRIVILEGES ON *.* TO 'cyberwise'; \
          ALTER USER 'cyberwise' IDENTIFIED WITH mysql_native_password BY 'cyber100'; \
          FLUSH PRIVILEGES;"

mysql -u cyberwise -p cyber100 < executavelBD.sql


echo "Configurações concluídas."
