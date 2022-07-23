# задаю базовый образ
FROM php:7.3-fpm

# копирую в контейнер файлы composer.lock и composer.json в папку образа /var/www/
COPY composer.lock composer.json /var/www/

# устанавливаю рабочую директорию образа для следующих команд
WORKDIR /var/www

# устанавливаю зависимости
RUN apt update && apt install -y \
    build-essential \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libwebp-dev libjpeg62-turbo-dev libpng-dev libxpm-dev \
    libfreetype6 \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl

# очищаю кэш apt
RUN apt clean && rm -rf /var/lib/apt/lists/*

# устанавливаю расширения
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl

# устанавливаю Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# добавляю пользователя www для приложения
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# копирую файлы из локального контекста сборки в директорию образа /var/www
COPY . /var/www

# копирую права текущей папки на директорию /var/www в образе
COPY --chown=www:www . /var/www

# переключаюсь на пользователя www
USER www

# открываю 9000 порт
EXPOSE 9000
# запускаю сервер php-fpm
CMD ["php-fpm"]
