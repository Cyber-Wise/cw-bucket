#!/bin/bash

# Função para verificar se um comando existe
command_exists() {
    command -v "$1" &> /dev/null
}

# Remover Java
if command_exists java; then
    echo "Removendo Java..."
    sudo apt-get purge openjdk-\* -y
    sudo apt-get autoremove -y
    sudo apt-get autoclean -y
    echo "Java removido com sucesso."
else
    echo "Java não está instalado."
fi

# Remover Docker e container MySQL
if command_exists docker; then
    echo "Removendo Docker e containers..."

    # Parar e remover o container MySQL
    sudo docker stop ContainerBD
    sudo docker rm ContainerBD

    # Remover imagem do MySQL
    sudo docker rmi mysql:5.7

    # Remover Docker
    sudo apt-get purge docker.io -y
    sudo apt-get autoremove -y
    sudo apt-get autoclean -y

    # Remover diretórios e arquivos do Docker
    sudo rm -rf /var/lib/docker
    sudo rm -rf /etc/docker

    # Remover configurações do Docker
    sudo rm -rf ~/.docker

    echo "Docker e containers removidos com sucesso."
else
    echo "Docker não está instalado."
fi

# Remover bibliotecas clonadas do GitHub
if [ -d "$HOME/cw-bucket" ]; then
    echo "Removendo bibliotecas clonadas..."
    rm -rf "$HOME/cw-bucket"
    echo "Bibliotecas removidas com sucesso."
else
    echo "Bibliotecas não foram clonadas."
fi

# Remover alias 'cyberwise'
if alias | grep -q "cyberwise="; then
    echo "Removendo alias 'cyberwise'..."
    unalias cyberwise
    echo "Alias 'cyberwise' removido com sucesso."
else
    echo "Alias 'cyberwise' não encontrado."
fi

echo "Limpeza concluída com sucesso."
