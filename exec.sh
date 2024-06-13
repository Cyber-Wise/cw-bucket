#!/bin/bash

# Navegar para o diretório do projeto
cd /home/ubuntu/cw-bucket/cyberwise

# Atualizar o repositório git
echo "Atualizando o repositório..."
git pull

# Executar o JAR em primeiro plano
java -jar jar_cyberwise.jar <<EOF
vision@cyberwise.com
vision@123
201
s
EOF
