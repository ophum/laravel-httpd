# Laravel依存パッケージなどのインストール
FROM composer as composer
WORKDIR /app

COPY ./src /app
RUN composer install --no-dev
RUN mv .env.example .env
RUN php artisan key:generate

# Laravelフロントエンドの実装のビルド
FROM node:14 as node
WORKDIR /app

COPY ./src/package.json ./src/package-lock.json /app/
RUN npm install
COPY ./src/ . 
RUN npm run prod

# デプロイ用
FROM php:7.4-apache

RUN docker-php-ext-install pdo_mysql
RUN a2enmod rewrite
COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf

COPY --from=composer --chown=www-data:www-data ./app /var/www/html
COPY --from=node --chown=www-data:www-data ./app/public ./public