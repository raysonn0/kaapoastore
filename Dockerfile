# -----------------------------
# Stage 0: PHP + Composer
# -----------------------------
    FROM php:8.2-fpm AS base

    # Install system dependencies
    RUN apt-get update && apt-get install -y \
        git \
        unzip \
        libzip-dev \
        libonig-dev \
        libxml2-dev \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libicu-dev \
        libxslt-dev \
        curl \
        npm \
        nodejs \
        redis-tools \
        zip \
        && apt-get clean && rm -rf /var/lib/apt/lists/*
    
    # Install PHP extensions
    RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
        && docker-php-ext-install \
            pdo_mysql \
            mysqli \
            mbstring \
            exif \
            pcntl \
            bcmath \
            gd \
            intl \
            zip \
            opcache \
            calendar \
            xml \
            soap \
            sockets
    
    # Install Composer
    COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
    
    # Set working directory
    WORKDIR /var/www/html
    
    # -----------------------------
    # Stage 1: Copy PHP dependencies
    # -----------------------------
    COPY composer.json composer.lock ./
    RUN composer install --optimize-autoloader --no-interaction || true
    
    # -----------------------------
    # Stage 2: Copy Node dependencies & build
    # -----------------------------
    COPY package.json package-lock.json ./
    RUN npm install && npm run build || true
    
    # -----------------------------
    # Stage 3: Copy application code
    # -----------------------------
    COPY . .
    
    # Clear caches (optional)
    RUN php artisan config:clear
    RUN php artisan route:clear
    RUN php artisan view:clear
    RUN php artisan cache:clear
    
    # Set the port for Railway
    ENV PORT 8000
    
    # -----------------------------
    # Serve the app
    # -----------------------------
    CMD php artisan serve --host=0.0.0.0 --port=${PORT:-8000}
    