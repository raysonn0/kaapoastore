# -----------------------------
# Use official PHP 8.2 CLI image
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
        unzip \
        && apt-get clean && rm -rf /var/lib/apt/lists/*
    
    # -----------------------------
    # Install PHP extensions required by Bagisto
    # -----------------------------
    RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
        && docker-php-ext-install \
            pdo_mysql \
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
    # Copy project files
    # -----------------------------
    COPY . .
    
    # -----------------------------
    # Set permissions for Laravel/Bagisto
    # -----------------------------
    RUN chown -R www-data:www-data /var/www/html \
        && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache
    
    # -----------------------------
    # Install PHP dependencies
    # -----------------------------
    RUN composer install --optimize-autoloader --no-interaction
    
    # -----------------------------
    # Install Node dependencies and build assets
    # -----------------------------
    RUN npm install && npm run build
    
    # -----------------------------
    # Railway dynamic port
    # -----------------------------
    ENV PORT $PORT
    
    # -----------------------------
    # Start PHP built-in server
    # Use sh -c to expand $PORT dynamically
    # Adjust 'public' if your index.php is elsewhere
    # -----------------------------
    CMD sh -c "php -S 0.0.0.0:$PORT -t public"
    