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
git clone https://github.com/Cyber-Wise/cw-bucket.git
# Verifica se o clone foi bem-sucedido
if [ $? = 0 ]; then
    echo "Bibliotecas importadas com sucesso!"
else
    echo "Falha ao importar bibliotecas. Verifique os logs para mais informações."
    exit 1 # Saia do script com código de erro
fi

# Segundo script

# Define o conteúdo da variável de ambiente cyberwise
CYBERWISE_CONTENT='#!/bin/bash

# Obtém o nome de usuário atual
USERNAME=$(whoami)

# Define o diretório onde está o arquivo .jar
JAR_DIR="/home/$USERNAME/cw-bucket"

# Navega até o diretório do arquivo .jar
cd "$JAR_DIR"

# Executa o arquivo .jar
java -jar nome_do_arquivo.jar'

# Define o caminho do arquivo de perfil do shell
PROFILE_FILE=~/.bashrc

# Adiciona a variável de ambiente cyberwise ao arquivo de perfil do shell
echo -e "\n# Variável de ambiente para executar o script cyberwise\nexport cyberwise=\"$CYBERWISE_CONTENT\"" >> "$PROFILE_FILE"

# Atualiza o ambiente
source "$PROFILE_FILE"

echo "Variável de ambiente 'cyberwise' adicionada com sucesso."
