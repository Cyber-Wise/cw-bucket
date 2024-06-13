#!/bin/bash

# Navegar para o diretório do projeto
cd /home/ubuntu/cw-bucket/cyberwise

# Atualizar o repositório git
echo "Atualizando o repositório..."
git restore .
git pull

sudo docker ps -a -q | xargs sudo docker start
sleep 5


# Executar o JAR em primeiro plano
java -jar jar_cyberwise.jar <<EOF
vision@cyberwise.com
vision@123
201
s
EOF
