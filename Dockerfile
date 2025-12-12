FROM php:8.2-apache

WORKDIR /var/www/html

# Install dependencies and PHP extensions (same as before)
# ...

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY . .

RUN composer install --optimize-autoloader --no-interaction \
 && npm install && npm run build \
 && chown -R www-data:www-data /var/www/html \
 && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80
CMD ["sh", "-c", "php artisan serve --host=0.0.0.0 --port=$PORT"]

