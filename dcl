#!/usr/bin/env bash

if [ "$1" == "start" ]; then
    sudo docker-compose start
fi

if [ "$1" == "stop" ]; then
    sudo docker-compose stop
fi

if [ "$1" == "update" ]; then    
    sudo docker pull woosungchoi/fpm-alpine && sudo docker-compose pull && sudo docker-compose up --build -d && sudo docker image prune -f
fi

if [ "$1" == "setup" ]; then
  echo 'Исходные данные...' \
  && read -p "[1/8] Укажите доменное имя (прим : mydomain.com or localhost) : " DOMAIN
  read -p "[2/8] Укажите root пароль для настройки СУБД (прим : rootdbpassword) : " ROOTDBPASSWORD
  read -p "[3/8] Укажите имя базы данных для wordpress (прим : dbuser) : " DATABASEUSER
  read -p "[4/8] Укажите пароль к базе данных для wordpress (прим : dbpassword) : " DATABASEPASSWORD
  read -p "[5/8] Укажите имя базы данных для wordpress (прим : wordpress) : " DATABASE
  read -p "[6/8] Какой порт настраиваем для Web сервера? (прим : 80) " WEB_PORT
  read -p "[7/8] Какой порт настраиваем для Portainer? (прим : 9000) " PORTAINER_PORT
  read -p "[8/8] Какой порт настраиваем для Phpmyadmin? (прим : 8080) " PMA_PORT \
  && rm -rf wordpress; git clone https://github.com/woosungchoi/docker-wordpress wordpress \
  && cd wordpress \
  && mv docker-compose.yml docker-compose.ssl.yml \
  && mv docker-compose.local.yml docker-compose.yml \
  && mv nginx/conf.d nginx/conf.d-ssl \
  && mv nginx/conf.d-local nginx/conf.d \
  && sed -i "s/<rootdbpassword>/$ROOTDBPASSWORD/g" .env \
  && sed -i "s/<databaseuser>/$DATABASEUSER/g" .env \
  && sed -i "s/<databasepassword>/$DATABASEPASSWORD/g" .env \
  && sed -i "s/<database>/$DATABASE/g" .env \
  && sed -i "s/<domain>/$DOMAIN/g" docker-compose.yml \
  && sed -i "s/<domain>/$DOMAIN/g" nginx/conf.d/wordpress.conf \
  && sed -i "s/<domain>/$DOMAIN/g" nginx/conf.d/phpmyadmin.conf \
  && sed -i "s/<web_port>/$WEB_PORT/g" nginx/conf.d/wordpress.conf \
  && sed -i "s/<pma_port>/$PMA_PORT/g" docker-compose.yml \
  && sed -i "s/<portainer_port>/$PORTAINER_PORT/g" docker-compose.yml \
  && sed -i "s/<pma_port>/$PMA_PORT/g" nginx/conf.d/phpmyadmin.conf \
  && echo 'Установка часового пояса на Europa/Moscow...' \
  && sudo timedatectl set-timezone Europa/Moscow \
  && echo 'Установка Docker...' \
  && sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
  && sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y \
  && sudo apt update -y \
  && sudo apt install docker-ce docker-ce-cli containerd.io -y \
  && if [ ! -f /usr/local/bin/docker-compose ] ; then
        echo 'Установка Docker Compose...' \
        && COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4) \
        && sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
        && sudo chmod +x /usr/local/bin/docker-compose
        else echo 'Установка Docker Compose пропущенна'
     fi
  sudo chmod a+x build/docker-entrypoint.sh \
  && sudo chmod a+x dc \
  && echo 'Запуск Docker ...' \
  && sudo docker-compose up -d  \
  && echo 'Готово!' \
  && sudo docker-compose ps \
  && echo 'Ссылка на wordpress: http://'$DOMAIN':'$WEB_PORT;
  echo 'Ссылка на phpmyadmin: http://'$DOMAIN':'$PMA_PORT;
  echo 'Ссылка на portainer: http://'$DOMAIN':'$PORTAINER_PORT;
fi
