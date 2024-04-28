#!/bin/bash

# Função para verificar se o pacote está instalado
check_package() {
    dpkg -l "$1" &> /dev/null
}

# Verifica se o Java está instalado
java -version &> /dev/null
if [ $? = 0 ]; then
    echo "Java instalado"
else
    echo "Java não instalado"
    echo "Gostaria de instalar o Java? [s/n]"
    read get
    if [ "$get" == "s" ]; then
        sudo apt install openjdk-17-jre -y
    fi
fi

# Verifica se o MySQL está instalado
check_package mysql-server
if [ $? = 0 ]; then
    echo "MySQL instalado"
else
    echo "MySQL não instalado"
    echo "Gostaria de instalar o MySQL? [s/n]"
    read get
    if [ "$get" == "s" ]; then
        sudo apt install mysql-server -y
    fi
fi
