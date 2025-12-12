FROM php:8.2-apache

WORKDIR /var/www/html

# Enable Apache rewrite
RUN a2enmod rewrite

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libonig-dev libxml2-dev \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libicu-dev libxslt-dev curl redis-tools zip \
    nodejs npm \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        pdo_mysql mysqli mbstring exif pcntl bcmath \
        gd intl zip opcache calendar xml soap sockets

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy project
COPY . .

# Permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# Backend dependencies
RUN composer install --optimize-autoloader --no-interaction

# Frontend build
RUN npm install --legacy-peer-deps && npm run build

# Fix Apache DocumentRoot
RUN sed -i 's#/var/www/html#/var/www/html/public#g' /etc/apache2/sites-available/000-default.conf

EXPOSE 8080
ENV PORT=8080

CMD ["apache2-foreground"]
