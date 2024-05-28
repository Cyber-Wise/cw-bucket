#!/bin/bash

# Verifica se o usuário é root
if [ "$(id -u)" -ne 0 ]; then
  echo "Este script precisa ser executado como root" 1>&2
  exit 1
fi

# Atualiza os repositórios
apt update

# Ajusta a hora do sistema
timedatectl set-timezone America/Sao_Paulo

# Verifica se o MySQL já está instalado
if ! command -v mysql &>/dev/null; then
  echo "Instalando o MySQL Server..."
  apt install -y mysql-server
else
  echo "MySQL Server já está instalado."
fi

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

# Define variáveis de senha
ROOT_PASSWORD="cyber100"
USER_PASSWORD="cyber100"

# Define uma senha para o usuário root e cria o usuário cyberwise com todas as permissões
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}'; \
          CREATE USER 'cyberwise'@'%' IDENTIFIED BY '${USER_PASSWORD}'; \
          GRANT ALL PRIVILEGES ON *.* TO 'cyberwise'; \
          ALTER USER 'cyberwise' IDENTIFIED WITH mysql_native_password BY '${USER_PASSWORD}'; \
          FLUSH PRIVILEGES;"

# Verifica e configura o bind-address
MYSQL_CONF_FILE="/etc/mysql/mysql.conf.d/mysqld.cnf"
if grep -q "^bind-address" $MYSQL_CONF_FILE; then
  sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" $MYSQL_CONF_FILE
else
  echo "bind-address = 0.0.0.0" >> $MYSQL_CONF_FILE
fi

# Reinicia o serviço MySQL para aplicar as mudanças
systemctl restart mysql

# Executa script SQL
mysql -u cyberwise -p${USER_PASSWORD} < executavelBD.sql

echo "Configurações concluídas."
