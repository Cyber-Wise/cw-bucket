#!/bin/bash

# Função para exibir mensagem de boas-vindas e perguntar se deseja iniciar a instalação
iniciar_instalacao() {
    echo "Bem-vindo ao assistente de instalação da Cyberwise"
    read -p "Deseja iniciar a instalação? (s/n): " iniciar
    if [[ $iniciar != "s" && $iniciar != "S" ]]; then
        echo "Instalação cancelada pelo usuário."
        exit 0
    fi
}

# Função para atualizar e fazer upgrade dos pacotes
atualizar_pacotes() {
    read -p "Deseja atualizar a lista de pacotes e fazer upgrade dos pacotes instalados? (s/n): " escolha
    if [[ $escolha == "s" || $escolha == "S" ]]; then
        echo "Atualizando a lista de pacotes..."
        sudo apt update
        echo "Atualizando os pacotes instalados..."
        sudo apt upgrade -y
    else
        echo "Atualização de pacotes cancelada."
    fi
}

# Função para trocar a senha do root
trocar_senha_root() {
    echo "Trocando a senha do usuário root..."
    echo "root:cyber100" | sudo chpasswd
}

# Função para trocar a senha do usuário ubuntu
trocar_senha_ubuntu() {
    echo "Trocando a senha do usuário ubuntu..."
    if id "ubuntu" &>/dev/null; then
        echo "ubuntu:cyber100" | sudo chpasswd
        echo "Senha do usuário ubuntu trocada com sucesso."
    else
        echo "Usuário ubuntu não encontrado."
    fi
}

# Função para verificar e instalar Java
instalar_java() {
    read -p "Deseja instalar o Java? (s/n): " escolha
    if [[ $escolha == "s" || $escolha == "S" ]]; then
        java -version
        if [ $? = 0 ]; then
            echo "Java já está instalado."
        else
            echo "Java não está instalado."
            echo "Instalando o Java..."
            sudo apt install openjdk-17-jre -y
            if [ $? = 0 ]; then
                echo "Java instalado com sucesso!"
            else
                echo "Falha na instalação do Java. Verifique os logs para mais informações."
                exit 1
            fi
        fi
    else
        echo "Instalação do Java cancelada."
    fi
}

# Função para clonar ou atualizar o repositório cw-bucket
importar_bibliotecas() {
    cd ~
    if [ -d "cw-bucket" ]; then
        echo "Diretório cw-bucket já existe. Realizando git pull..."
        cd cw-bucket
        git pull
        if [ $? = 0 ]; then
            echo "Bibliotecas atualizadas com sucesso!"
        else
            echo "Falha ao atualizar bibliotecas. Verifique os logs para mais informações."
            exit 1
        fi
    else
        echo "Clonando repositório cw-bucket..."
        git clone https://github.com/Cyber-Wise/cw-bucket.git
        if [ $? = 0 ]; then
            echo "Bibliotecas importadas com sucesso!"
        else
            echo "Falha ao importar bibliotecas. Verifique os logs para mais informações."
            exit 1
        fi
    fi
}

# Função para adicionar aliases ao ~/.bashrc
adicionar_aliases() {
    echo "Adicionando aliases ao ~/.bashrc..."
    aliases=("cyberwise" "pablo" "ana" "davi" "amanda" "robson" "igor")
    for alias in "${aliases[@]}"; do
        echo "alias $alias='java -jar \"/home/\$(whoami)/cw-bucket/$alias/jar_$alias.jar\"'" >> ~/.bashrc
    done
    source ~/.bashrc
    echo "Aliases adicionados com sucesso."
}

# Função para instalar Docker
instalar_docker() {
    read -p "Deseja instalar o Docker? (s/n): " escolha
    if [[ $escolha == "s" || $escolha == "S" ]]; then
        echo "Atualizando a lista de pacotes..."
        sudo apt update
        echo "Instalando o Docker..."
        sudo apt install docker.io -y
        echo "Iniciando o serviço Docker..."
        sudo systemctl start docker
        echo "Habilitando o Docker para iniciar com o sistema operacional..."
        sudo systemctl enable docker
    else
        echo "Instalação do Docker cancelada."
    fi
}

# Função para configurar MySQL no Docker
configurar_mysql_docker() {
    read -p "Deseja configurar o MySQL no Docker? (s/n): " escolha
    if [[ $escolha == "s" || $escolha == "S" ]]; then
        echo "Baixando a imagem do MySQL 5.7..."
        sudo docker pull mysql:5.7
        echo "Criando e iniciando o container MySQL..."
        sudo docker run -d -p 3306:3306 --name ContainerBD -e MYSQL_DATABASE=bancoLocal -e MYSQL_ROOT_PASSWORD=cyber100 mysql:5.7
        echo "Verificando o status do container..."
        sudo docker ps -a

        container_status=$(sudo docker ps -a --filter "name=ContainerBD" --format "{{.Status}}")
        if [[ $container_status == Up* ]]; then
            echo "O container foi criado com sucesso e está em execução."
            echo "Aguardando 30 segundos para o MySQL iniciar completamente..."
            sleep 30
            echo "Criando o usuário 'cyberwise' e concedendo privilégios..."
            sudo docker exec -i ContainerBD mysql -u root -pcyber100 -e "CREATE USER 'cyberwise'@'%' IDENTIFIED BY 'cyber100'; ALTER USER 'cyberwise' IDENTIFIED WITH mysql_native_password BY 'cyber100'; GRANT ALL PRIVILEGES ON *.* TO 'cyberwise'@'%'; FLUSH PRIVILEGES;"
            echo "Usuário 'cyberwise' criado com sucesso e privilégios concedidos."
            echo "Copiando o script SQL 'BD_CyberwiseClient.sql' para o container..."
            sudo docker cp ~/cw-bucket/BD_CyberwiseClient.sql ContainerBD:/BD_CyberwiseClient.sql
            echo "Executando o script SQL 'BD_CyberwiseClient'..."
            sudo docker exec -i ContainerBD sh -c 'mysql -u root -pcyber100 bancoLocal < /BD_CyberwiseClient.sql'
            echo "Script SQL 'BD_CyberwiseClient' executado com sucesso."
        else
            echo "A criação do container falhou. Verificando os logs..."
            sudo docker logs ContainerBD
        fi
    else
        echo "Configuração do MySQL no Docker cancelada."
    fi
}

# Função principal
main() {
    iniciar_instalacao
    atualizar_pacotes
    trocar_senha_root
    trocar_senha_ubuntu
    instalar_java
    importar_bibliotecas
    adicionar_aliases
    instalar_docker
    configurar_mysql_docker
}

# Executar a função principal
main
