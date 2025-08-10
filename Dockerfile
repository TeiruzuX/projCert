FROM php:8.2-fpm

# Install Nginx
RUN apt-get update && apt-get install -y --no-install-recommends nginx \
    && rm -rf /var/lib/apt/lists/*

# Remove default site
RUN rm -f /etc/nginx/sites-enabled/default \
    && rm -f /var/www/html/index.nginx-debian.html

# Nginx configuration
RUN cat > /etc/nginx/conf.d/default.conf <<'NGINX'
server {
    listen 80;
    server_name _;
    root /var/www/html;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include /etc/nginx/fastcgi_params;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
NGINX

# Website files
WORKDIR /var/www/html
COPY website/ ./
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80

# Startup script
RUN printf '#!/bin/sh\nset -e\nphp-fpm -F &\nexec nginx -g "daemon off;"\n' > /start.sh \
 && chmod +x /start.sh
CMD ["/start.sh"]
