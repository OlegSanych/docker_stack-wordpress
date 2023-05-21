#!/bin/bash
set -euo pipefail

# Запускает скрипт автоматической установки Wordpress последней версии
if [ ! -e wordpress ]; then
curl -o wordpress.tar.gz -fSL https://wordpress.org/latest.tar.gz \
&& tar -xvzf wordpress.tar.gz \
&& rm wordpress.tar.gz \
&& chown -R www-data:www-data wordpress \
&& chmod -R 777 wordpress/wp-content \
&& cd ..
fi

exec "$@"
