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

# Verifica se o Java está instalado
java -version
if [ $? = 0 ]; then
    echo "Java instalado."
else
    echo "Java não instalado."
    echo "Instalando o Java..."
    sudo apt install openjdk-17-jre -y
    # Verifica se a instalação foi bem-sucedida
    if [ $? = 0 ]; then
        echo "Java instalado com sucesso!"
    else
        echo "Falha na instalação do Java. Verifique os logs para mais informações."
        exit 1
    fi
fi

# Importa bibliotecas após a instalação do Java
echo "Importando bibliotecas..."
cd ~

# Verifica se o diretório cw-bucket já existe
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


# Define o alias cyberwise
echo "Adicionando alias 'cyberwise' ao ~/.bashrc..."
echo "alias cyberwise='java -jar \"/home/$(whoami)/cw-bucket/jar_cyberwise_jar/jar_cyberwise.jar\"'" >> ~/.bashrc

# Recarregar o arquivo ~/.bashrc para que o alias seja imediatamente disponível
source ~/.bashrc

echo "Alias 'cyberwise' adicionado com sucesso."

# Instalação do Docker e configuração do MySQL
# Atualizar a lista de pacotes disponíveis
echo "Atualizando a lista de pacotes..."
sudo apt update

# Instalar o Docker
echo "Instalando o Docker..."
sudo apt install docker.io -y

# Iniciar o serviço Docker
echo "Iniciando o serviço Docker..."
sudo systemctl start docker

# Habilitar o Docker para iniciar com o sistema operacional
echo "Habilitando o Docker para iniciar com o sistema operacional..."
sudo systemctl enable docker

# Fazer pull da imagem do MySQL 5.7 do Docker Hub
echo "Baixando a imagem do MySQL 5.7..."
sudo docker pull mysql:5.7

# Criar e iniciar o container MySQL
echo "Criando e iniciando o container MySQL..."
sudo docker run -d -p 3306:3306 --name ContainerBD -e MYSQL_DATABASE=bancoLocal -e MYSQL_ROOT_PASSWORD=cyber100 mysql:5.7

# Verificar se o container foi criado com sucesso
echo "Verificando o status do container..."
sudo docker ps -a

# Verificar o status do container
container_status=$(sudo docker ps -a --filter "name=ContainerBD" --format "{{.Status}}")

if [[ $container_status == Up* ]]; then
    echo "O container foi criado com sucesso e está em execução."

    # Avisar o usuário sobre a espera
    echo "Aguardando 30 segundos para o MySQL iniciar completamente..."
    sleep 30

    # Criar o usuário cyberwise e conceder todos os privilégios a ele
    echo "Criando o usuário 'cyberwise' e concedendo privilégios..."
    sudo docker exec -i ContainerBD mysql -u root -pcyber100 -e "CREATE USER 'cyberwise'@'%' IDENTIFIED BY 'cyber100'; ALTER USER 'cyberwise' IDENTIFIED WITH mysql_native_password BY 'cyber100'; GRANT ALL PRIVILEGES ON *.* TO 'cyberwise'@'%'; FLUSH PRIVILEGES;"

    echo "Usuário 'cyberwise' criado com sucesso e privilégios concedidos."

   # Copiar o script SQL para o container
    echo "Copiando o script SQL 'BD_CyberwiseClient.sql' para o container..."
    sudo docker cp ~/cw-bucket/BD_CyberwiseClient.sql ContainerBD:/BD_CyberwiseClient.sql

    # Executar o script SQL "BD_CyberwiseClient"
    echo "Executando o script SQL 'BD_CyberwiseClient'..."
    sudo docker exec -i ContainerBD sh -c 'mysql -u root -pcyber100 bancoLocal < /BD_CyberwiseClient.sql'

    echo "Script SQL 'BD_CyberwiseClient' executado com sucesso."
else
    echo "A criação do container falhou. Verificando os logs..."
    sudo docker logs ContainerBD
fi
