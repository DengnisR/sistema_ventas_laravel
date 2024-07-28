FROM php:7.2-fpm

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/html/

# Set working directory
WORKDIR /var/www/html

# Arguments defined in docker-compose.yml
ARG user=sammy
ARG uid=1000

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u ${uid} -d /home/${user} ${user}
RUN mkdir -p /home/${user}/.composer && chown -R ${user}:${user} /home/${user}

# Make the PHP directory available in the PATH
RUN echo "/usr/local/bin" >> /etc/paths

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www/html
COPY --chown=${user}:${user} . /var/www/html

USER ${user}
EXPOSE 9000

CMD ["php-fpm"]
