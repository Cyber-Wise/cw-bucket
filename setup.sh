#!/bin/bash

# Atualizar a lista de pacotes disponíveis
echo "Atualizando a lista de pacotes..."
sudo apt update

# Atualizar os pacotes instalados
echo "Atualizando os pacotes instalados..."
sudo apt upgrade -y

# Trocar a senha do root
echo "Trocando a senha do usuário root..."
echo "root:cyber100" | sudo chpasswd

# Trocar a senha do usuário ubuntu
echo "Trocando a senha do usuário ubuntu..."
if id "ubuntu" &>/dev/null; then
    echo "ubuntu:cyber100" | sudo chpasswd
    echo "Senha do usuário ubuntu trocada com sucesso."
else
    echo "Usuário ubuntu não encontrado."
fi

echo "Atualização e troca de senhas concluídas com sucesso."
