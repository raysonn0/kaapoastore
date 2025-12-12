# Stage 1: Build frontend
FROM node:20-alpine AS frontend-builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY composer.json composer.lock ./

# Install Node.js dependencies
RUN npm install

# Copy all files
COPY . .

# Build Vite frontend
RUN npm run build

# Stage 2: Build backend
FROM php:8.2-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    bash \
    git \
    zip \
    unzip \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    libxpm-dev \
    libxml2-dev \
    oniguruma-dev \
    nodejs \
    npm \
    mysql-client \
    icu-dev \
    autoconf \
    g++ \
    make \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd intl soap sockets

# Set working directory
WORKDIR /var/www/html

# Copy PHP backend + frontend build
COPY --from=frontend-builder /app ./

# Install composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Install PHP dependencies
RUN composer install --optimize-autoloader --no-dev

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port
EXPOSE 8000

# Run migrations & serve
CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8000
