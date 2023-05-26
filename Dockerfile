# FROM php:8.2-apache
# WORKDIR /var/www/html
# RUN apt-get update && apt-get install -y git unzip libpng-dev libonig-dev libxml2-dev
# RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd intl
# RUN git clone https://github.com/firefly-iii/firefly-iii .
# COPY . /var/www/html/
# COPY .env.example .
# ENV $(cat .env.example | grep -v ^# | xargs)
# #RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
# #RUN composer install --no-dev 
# #--no-interaction --prefer-dist --optimize-autoloader
# RUN chown -R www-data:www-data /var/www/html
# RUN chmod -R 775 /var/www/html/storage
# EXPOSE 80
# CMD ["apache2-foreground"]



FROM php:8.2-apache

# Set environment variables
#ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Update and install dependencies
RUN apt-get update \
    && apt-get install -y \
        libzip-dev \
        zip \
        unzip \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libonig-dev \
        mariadb-client \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo_mysql zip exif opcache

# Enable Apache rewrite module
RUN a2enmod rewrite

# Set up the working directory
WORKDIR /var/www/html

# Copy the Firefly III project files to the container
COPY . .

# Install composer dependencies
# RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
#     && composer install --no-dev 
#     #--optimize-autoloader
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    cd /var/www/html && \
    composer install --no-interaction --prefer-dist --optimize-autoloader

# Set correct permissions
RUN chown -R www-data:www-data /var/www/html/storage

# Expose port 80 for Apache
EXPOSE 80

# Set up the entrypoint command
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]