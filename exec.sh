#!/bin/bash

# Navegar para o diretório do projeto
cd /home/ubuntu/cw-bucket/cyberwise

# Atualizar o repositório git
echo "Atualizando o repositório..."
git pull

# Executar o JAR com expect
expect << EOF
spawn java -jar jar_cyberwise.jar
expect "Jar iniciando..."
send "vision@cyberwise.com\r"
expect "Insira sua senha:"
send "vision@123\r"
expect "Logado com sucesso"
expect "Bem Vindo(a) Vision"
expect "Insira o código de acesso da máquina:"
send "201\r"
expect "Deseja começar o monitoramento? (s/n)"
send "s\r"
EOF
