#!/bin/bash

# Verifica se o usuário é root
if [ "$(id -u)" -ne 0 ]; then
  echo "Este script precisa ser executado como root" 1>&2
  exit 1
fi

# Atualiza os repositórios
apt update

# Instala o MySQL Server
apt install mysql-server

# Inicia o serviço do MySQL
systemctl start mysql

# Habilita o MySQL para iniciar na inicialização do sistema
systemctl enable mysql

echo "MySQL Server foi instalado, configurado e está em execução."
