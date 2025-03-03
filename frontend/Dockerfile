# Use official PHP with built-in PHP-FPM support
FROM php:8.2-fpm

# Install Nginx and ps
RUN apt update && apt install -y nginx procps

# Copy index.php to web root
COPY index.php /usr/share/nginx/html/index.php

# Copy corrected Nginx configuration files
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start PHP-FPM and Nginx correctly
CMD php-fpm -D && nginx -g "daemon off;"