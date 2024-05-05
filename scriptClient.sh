#!/bin/bash

java -version # verifica versão atual do Java
if [ $? = 0 ]; then # se retorno for igual a 0
    echo "Java instalado." # print no terminal
else # se não
    echo "Java não instalado." # print no terminal
    echo "Instalando o Java..."
    sudo apt install openjdk-17-jre -y # executa instalação do Java sem pedir confirmação
    # Verifica se a instalação foi bem-sucedida
    if [ $? = 0 ]; then
        echo "Java instalado com sucesso!"
    else
        echo "Falha na instalação do Java. Verifique os logs para mais informações."
        exit 1 # Saia do script com código de erro
    fi
fi # fecha o 1º if

# Importa bibliotecas após a instalação do Java
echo "Importando bibliotecas..."
cd
git clone https://github.com/Cyber-Wise/cw-bucket.git
# Verifica se o clone foi bem-sucedido
if [ $? = 0 ]; then
    echo "Bibliotecas importadas com sucesso!"
else
    echo "Falha ao importar bibliotecas. Verifique os logs para mais informações."
    exit 1 # Saia do script com código de erro
fi

# Define o conteúdo da variável de ambiente cyberwise
cyberwise() {
    cd "/home/$(whoami)/cw-bucket/jar_cyberwise_jar" && java -jar jar-cyberwise.jar
}

export -f cyberwise

echo "Variável de ambiente 'cyberwise' adicionada com sucesso."
