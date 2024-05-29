#!/bin/bash

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
cd
git clone https://github.com/Cyber-Wise/cw-bucket.git
# Verifica se o clone foi bem-sucedido
if [ $? = 0 ]; then
    echo "Bibliotecas importadas com sucesso!"
else
    echo "Falha ao importar bibliotecas. Verifique os logs para mais informações."
    exit 1
fi

# Define o conteúdo da variável de ambiente cyberwise
alias cyberwise='java -jar "/home/$(whoami)/cw-bucket/jar_cyberwise_jar/jar_cyberwise.jar"'

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

    # Aguardar alguns segundos para o MySQL iniciar completamente
    sleep 5

    # Criar o usuário cyberwise e conceder todos os privilégios a ele
    echo "Criando o usuário 'cyberwise' e concedendo privilégios..."
    sudo docker exec -i ContainerBD mysql -u root -pcyber100 -e "CREATE USER 'cyberwise'@'%' IDENTIFIED BY 'cyber100'; ALTER USER 'cyberwise' IDENTIFIED WITH mysql_native_password BY 'cyber100'; GRANT ALL PRIVILEGES ON *.* TO 'cyberwise'@'%'; FLUSH PRIVILEGES;"

    echo "Usuário 'cyberwise' criado com sucesso e privilégios concedidos."

    # Executar o script SQL "BD_CyberwiseClient"
    echo "Executando o script SQL 'BD_CyberwiseClient'..."
    sudo docker exec -i ContainerBD sh -c 'mysql -u root -pcyber100 bancoLocal < /home/$(whoami)/cw-bucket/BD_CyberwiseClient.sql'

    echo "Script SQL 'BD_CyberwiseClient' executado com sucesso."
else
    echo "A criação do container falhou. Verificando os logs..."
    sudo docker logs ContainerBD
fi
