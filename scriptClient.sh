#!/bin/bash

# Função para atualizar a lista de pacotes e os pacotes instalados
atualizar_sistema() {
    echo "Atualizando a lista de pacotes..."
    sudo apt update
    
    echo "Atualizando os pacotes instalados..."
    sudo apt upgrade -y
}

# Função para trocar senhas de usuários
trocar_senha() {
    local usuario=$1
    local senha=$2
    
    if id "$usuario" &>/dev/null; then
        echo "$usuario:$senha" | sudo chpasswd
        echo "Senha do usuário $usuario trocada com sucesso."
    else
        echo "Usuário $usuario não encontrado."
    fi
}

# Função para verificar e instalar o Java
verificar_instalar_java() {
    java -version
    if [ $? = 0 ]; then
        echo "Java instalado."
    else
        echo "Java não instalado. Instalando o Java..."
        sudo apt install openjdk-17-jre -y
        if [ $? = 0 ]; then
            echo "Java instalado com sucesso!"
        else
            echo "Falha na instalação do Java. Verifique os logs para mais informações."
            exit 1
        fi
    fi
}

# Função para importar bibliotecas do GitHub
importar_bibliotecas() {
    echo "Importando bibliotecas..."
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

# Função para definir o alias cyberwise
definir_alias_cyberwise() {
    local user_bashrc_file="$HOME/.bashrc"
    local alias_command="alias cyberwise='java -jar \"/home/$(whoami)/cw-bucket/cyberwise/jar_cyberwise.jar\"'"

    # Adiciona o alias ao ~/.bashrc do usuário atual se ainda não estiver presente
    if ! grep -q "$alias_command" "$user_bashrc_file"; then
        echo "Adicionando alias 'cyberwise' ao $user_bashrc_file..."
        echo "$alias_command" >> "$user_bashrc_file"
        echo "Alias 'cyberwise' adicionado com sucesso ao $user_bashrc_file."
    else
        echo "Alias 'cyberwise' já está presente no $user_bashrc_file."
    fi

    # Recarregar o arquivo ~/.bashrc para que o alias seja imediatamente disponível na sessão atual
    source "$user_bashrc_file"
}

# Função para instalar e configurar Docker e MySQL
instalar_configurar_docker_mysql() {
    echo "Atualizando a lista de pacotes..."
    sudo apt update
    
    echo "Instalando o Docker..."
    sudo apt install docker.io -y
    
    echo "Iniciando o serviço Docker..."
    sudo systemctl start docker
    
    echo "Habilitando o Docker para iniciar com o sistema operacional..."
    sudo systemctl enable docker
    
    echo "Baixando a imagem do MySQL 5.7..."
    sudo docker pull mysql:5.7
    
    echo "Criando e iniciando o container MySQL..."
    sudo docker run -d -p 3306:3306 --name ContainerBD -e MYSQL_DATABASE=bancoLocal -e MYSQL_ROOT_PASSWORD=cyber100 mysql:5.7
    
    echo "Verificando o status do container..."
    local container_status=$(sudo docker ps -a --filter "name=ContainerBD" --format "{{.Status}}")
    
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
}

# Executar funções
atualizar_sistema
trocar_senha "root" "cyber100"
trocar_senha "ubuntu" "cyber100"
verificar_instalar_java
importar_bibliotecas
definir_alias_cyberwise
instalar_configurar_docker_mysql

echo "Todas as operações foram concluídas com sucesso."
