# -----------------------------
# Use PHP 8.2 CLI image
# -----------------------------
    FROM php:8.2-cli

    # -----------------------------
    # Set working directory
    # -----------------------------
    WORKDIR /var/www/html
    
    # -----------------------------
    # Install system dependencies
    # -----------------------------
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
    
    # -----------------------------
    # Install PHP extensions required by Bagisto
    # -----------------------------
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
    
    # -----------------------------
    # Install Composer
    # -----------------------------
    COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
    
    # -----------------------------
    # Copy only dependency files first (for caching)
    # -----------------------------
    COPY composer.json composer.lock ./
    RUN composer install --optimize-autoloader --no-interaction
    
    COPY package.json package-lock.json ./
    RUN npm install && npm run build
    
    # -----------------------------
    # Copy full project
    # -----------------------------
    COPY . .
    
    # -----------------------------
    # Set permissions
    # -----------------------------
    RUN chown -R www-data:www-data /var/www/html \
        && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache
    
    # -----------------------------
    # Railway dynamic port
    # -----------------------------
    ENV PORT=${PORT:-8000}
    EXPOSE ${PORT}
    
    # -----------------------------
    # Start Laravel server on Railway
    # -----------------------------
    CMD ["sh", "-c", "php artisan serve --host=0.0.0.0 --port=$PORT"]
    