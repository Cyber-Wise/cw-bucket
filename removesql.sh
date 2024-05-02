#!/bin/bash

# Remover o pacote do servidor MySQL
sudo apt remove --purge mysql-server mysql-client mysql-common -y

# Remover os arquivos de configuração do MySQL
sudo rm -rf /etc/mysql /var/lib/mysql

# Remover qualquer biblioteca compartilhada do MySQL
sudo apt autoremove --purge mysql-server-core-* mysql-client-core-* -y

# Limpar quaisquer dependências não utilizadas
sudo apt autoclean

echo "MySQL e todos os seus pacotes foram removidos completamente."

