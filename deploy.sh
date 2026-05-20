#!/bin/bash

##############################################################################
# DigiProjects Complete VPS Deployment Script
# Domain: digiprojects.co.ke
# This script handles EVERYTHING: database, backend, frontend, nginx, ssl
##############################################################################

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
DOMAIN="digiprojects.co.ke"
PROJECT_PATH="/var/www/digiprojects"
DB_NAME="digiprojects"
DB_USER="digiprojects_user"
APP_ENV="production"
API_PATH="/api"
API_DOMAIN="$DOMAIN"

# Logging
LOG_FILE="/var/log/digiprojects-deploy.log"

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a $LOG_FILE
}

success() {
    echo -e "${GREEN}✓ $1${NC}" | tee -a $LOG_FILE
}

error() {
    echo -e "${RED}✗ $1${NC}" | tee -a $LOG_FILE
    exit 1
}

warning() {
    echo -e "${YELLOW}⚠ $1${NC}" | tee -a $LOG_FILE
}

header() {
    echo -e "\n${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}\n"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    error "This script must be run as root. Use: sudo bash deploy.sh"
fi

# Generate secure database password if not provided
if [ -z "$DB_PASSWORD" ]; then
    DB_PASSWORD=$(openssl rand -base64 32)
fi

header "DigiProjects Complete VPS Deployment"
log "Domain: $DOMAIN"
log "API Path: $DOMAIN$API_PATH"
log "Project Path: $PROJECT_PATH"
log "Database Name: $DB_NAME"
log "Database User: $DB_USER"

# Ask for confirmation
echo -e "${YELLOW}Database password (auto-generated): $DB_PASSWORD${NC}"
read -p "Continue with deployment? (yes/no) " -r
if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
    log "Deployment cancelled"
    exit 0
fi

# Save database password to secure file
echo "DB_PASSWORD=$DB_PASSWORD" > /root/.digiprojects-db-pass
chmod 600 /root/.digiprojects-db-pass
success "Database credentials saved"

##############################################################################
# STEP 1: System Updates
##############################################################################
header "Step 1: System Updates & Dependencies"

log "Updating system packages..."
apt-get update -qq
apt-get upgrade -y -qq
success "System packages updated"

log "Installing required packages..."
apt-get install -y -qq \
    curl \
    wget \
    git \
    build-essential \
    libssl-dev \
    libcurl4-openssl-dev \
    pkg-config \
    mysql-server \
    mysql-client \
    php-fpm \
    php-mysql \
    php-mbstring \
    php-xml \
    php-curl \
    php-zip \
    php-pdo \
    php-gd \
    php-cli \
    php-common \
    php-bcmath \
    php-json \
    composer \
    nodejs \
    npm \
    nginx \
    certbot \
    python3-certbot-nginx \
    supervisor \
    redis-server

success "All packages installed"

##############################################################################
# STEP 2: Create Project Directory
##############################################################################
header "Step 2: Project Directory Setup"

log "Creating project directory..."
mkdir -p $PROJECT_PATH
cd $PROJECT_PATH
success "Project directory created"

##############################################################################
# STEP 3: Database Setup
##############################################################################
header "Step 3: MySQL Database Setup"

log "Starting MySQL service..."
systemctl start mysql
systemctl enable mysql
success "MySQL service running"

log "Creating database and user..."
mysql -u root <<MYSQL_COMMANDS
CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_COMMANDS

success "Database and user created"

##############################################################################
# STEP 4: Backend Setup
##############################################################################
header "Step 4: Backend (Laravel API) Setup"

if [ ! -d "$PROJECT_PATH/digiprojects-backend" ]; then
    error "Backend directory not found at $PROJECT_PATH/digiprojects-backend"
fi

BACKEND_PATH="$PROJECT_PATH/digiprojects-backend"
cd $BACKEND_PATH

log "Installing PHP dependencies..."
composer install --no-dev --optimize-autoloader -q
success "PHP dependencies installed"

log "Updating .env file..."
cat > .env <<ENV_FILE
APP_NAME=DigiProjects
APP_ENV=$APP_ENV
APP_KEY=base64:CDqi4Lui0Vrlf1DtENOCMTftxEmWwqYx1yQ4EOJCgvI=
APP_DEBUG=false
APP_URL=https://$DOMAIN

APP_LOCALE=en
APP_FALLBACK_LOCALE=en
APP_FAKER_LOCALE=en_US

BCRYPT_ROUNDS=12

LOG_CHANNEL=stack
LOG_STACK=single
LOG_LEVEL=error

# Database Configuration
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=$DB_NAME
DB_USERNAME=$DB_USER
DB_PASSWORD=$DB_PASSWORD

# Session Configuration
SESSION_DRIVER=database
SESSION_LIFETIME=120
SESSION_ENCRYPT=false
SESSION_PATH=/
SESSION_DOMAIN=.$DOMAIN

# Cache & Queue
CACHE_STORE=database
QUEUE_CONNECTION=database

# Mail Configuration
MAIL_MAILER=log
MAIL_HOST=127.0.0.1
MAIL_PORT=2525
MAIL_FROM_ADDRESS="noreply@$DOMAIN"
MAIL_FROM_NAME="DigiProjects"

# Redis (optional, for caching/sessions)
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

BROADCAST_CONNECTION=log
FILESYSTEM_DISK=local

VITE_APP_NAME="DigiProjects"
ENV_FILE

success ".env configured"

log "Running database migrations..."
php artisan migrate --force 2>&1 | tee -a $LOG_FILE
success "Database migrations completed"

log "Caching configuration..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
success "Configuration cached"

log "Setting backend permissions..."
chmod -R 755 $BACKEND_PATH/public
chmod -R 775 $BACKEND_PATH/storage
chmod -R 775 $BACKEND_PATH/bootstrap/cache
chown -R www-data:www-data $BACKEND_PATH/storage
chown -R www-data:www-data $BACKEND_PATH/bootstrap/cache
success "Backend permissions set"

##############################################################################
# STEP 5: Frontend Setup
##############################################################################
header "Step 5: Frontend (Vue.js) Setup"

if [ ! -d "$PROJECT_PATH/digiprojects-frontend" ]; then
    error "Frontend directory not found at $PROJECT_PATH/digiprojects-frontend"
fi

FRONTEND_PATH="$PROJECT_PATH/digiprojects-frontend"
cd $FRONTEND_PATH

log "Creating frontend .env..."
cat > .env <<FRONTEND_ENV
VITE_API_BASE_URL=https://$DOMAIN$API_PATH
FRONTEND_ENV

success "Frontend .env created"

log "Installing Node dependencies..."
npm install --legacy-peer-deps -q
success "Node dependencies installed"

log "Building frontend..."
npm run build
success "Frontend built successfully"

log "Setting frontend permissions..."
chmod -R 755 $FRONTEND_PATH/dist
chown -R www-data:www-data $FRONTEND_PATH/dist
success "Frontend permissions set"

##############################################################################
# STEP 6: Nginx Configuration
##############################################################################
header "Step 6: Nginx Configuration"

log "Creating unified Nginx configuration..."
cat > /etc/nginx/sites-available/digiprojects <<'NGINX_CONFIG'
# DigiProjects Unified Configuration
# Frontend + Backend API on single domain
# File: /etc/nginx/sites-available/digiprojects

# HTTP to HTTPS redirect
server {
    listen 80;
    listen [::]:80;
    server_name digiprojects.co.ke www.digiprojects.co.ke;
    return 301 https://$server_name$request_uri;
}

# HTTPS Server Block
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name digiprojects.co.ke www.digiprojects.co.ke;

    # SSL Certificates
    ssl_certificate /etc/letsencrypt/live/digiprojects.co.ke/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/digiprojects.co.ke/privkey.pem;
    
    # SSL Configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css text/javascript application/javascript application/json;
    gzip_vary on;

    # Frontend root
    root /var/www/digiprojects/digiprojects-frontend/dist;
    index index.html;

    # Cache static assets (js, css, images, fonts)
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # API Location Block - Backend
    location /api {
        root /var/www/digiprojects/digiprojects-backend/public;
        try_files $uri $uri/ /index.php?$query_string;
    }

    # Sanctum Location Block - Backend (CSRF cookie auth)
    location /sanctum {
        root /var/www/digiprojects/digiprojects-backend/public;
        try_files $uri $uri/ /index.php?$query_string;
    }

    # PHP-FPM handler for all PHP requests (including Laravel front controller)
    location ~ \.php$ {
        root /var/www/digiprojects/digiprojects-backend/public;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_param HTTPS on;
        fastcgi_param HTTP_SCHEME https;
    }

    # Frontend SPA routing - serve index.html for all non-API / non-PHP routes
    location / {
        try_files $uri $uri/ /index.html;
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }

    # Deny access to hidden files and directories
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    # Deny access to .htaccess files
    location ~ /\.ht {
        deny all;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
NGINX_CONFIG

success "Unified Nginx config created"

log "Enabling Nginx sites..."
ln -sf /etc/nginx/sites-available/digiprojects /etc/nginx/sites-enabled/

# Remove old API subdomain config and default site if exist
rm -f /etc/nginx/sites-enabled/digiprojects-api
rm -f /etc/nginx/sites-enabled/default

success "Nginx sites enabled"

log "Testing Nginx configuration..."
if nginx -t 2>&1 | tee -a $LOG_FILE; then
    success "Nginx configuration is valid"
else
    error "Nginx configuration test failed"
fi

log "Starting Nginx..."
systemctl restart nginx
systemctl enable nginx
success "Nginx service running"

##############################################################################
# STEP 7: PHP-FPM Configuration
##############################################################################
header "Step 7: PHP-FPM Configuration"

log "Configuring PHP-FPM..."
php_version=$(php -v | grep -oP 'PHP \K[0-9]\.[0-9]' | head -1)
log "PHP version: $php_version"

systemctl restart php${php_version}-fpm
systemctl enable php${php_version}-fpm
success "PHP-FPM configured and running"

##############################################################################
# STEP 8: SSL Certificate Setup with Let's Encrypt
##############################################################################
header "Step 8: SSL Certificate Setup"

warning "Certbot needs to be run manually to generate SSL certificates"
log "Run this command on your VPS:"
echo -e "\n${YELLOW}sudo certbot certonly --nginx -d digiprojects.co.ke -d www.digiprojects.co.ke${NC}\n"
log "After SSL is set up, restart Nginx:"
echo -e "${YELLOW}sudo systemctl restart nginx${NC}\n"

##############################################################################
# STEP 9: Create Systemd Service Files
##############################################################################
header "Step 9: Setting up Queue Worker Service"

log "Creating Laravel queue worker service..."
cat > /etc/systemd/system/digiprojects-queue.service <<'QUEUE_SERVICE'
[Unit]
Description=DigiProjects Laravel Queue Worker
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/digiprojects/digiprojects-backend
ExecStart=/usr/bin/php artisan queue:work database --sleep=3 --tries=3
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
QUEUE_SERVICE

systemctl daemon-reload
systemctl enable digiprojects-queue.service
log "Queue worker service created"
success "Service files created"

##############################################################################
# STEP 10: Backup Configuration
##############################################################################
header "Step 10: Backup Configuration"

log "Creating backup directory..."
mkdir -p /var/backups/digiprojects
chmod 700 /var/backups/digiprojects

log "Creating backup script..."
cat > /usr/local/bin/backup-digiprojects.sh <<'BACKUP_SCRIPT'
#!/bin/bash
BACKUP_DIR="/var/backups/digiprojects"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

# Backup database
mysqldump -u digiprojects_user -p$DB_PASSWORD digiprojects | gzip > $BACKUP_DIR/db_$DATE.sql.gz

# Backup storage files
tar -czf $BACKUP_DIR/storage_$DATE.tar.gz /var/www/digiprojects/digiprojects-backend/storage/

# Keep only last 30 days of backups
find $BACKUP_DIR -name "*.gz" -mtime +30 -delete

echo "Backup completed at $DATE"
BACKUP_SCRIPT

chmod +x /usr/local/bin/backup-digiprojects.sh
success "Backup script created"

##############################################################################
# STEP 11: Firewall Configuration
##############################################################################
header "Step 11: Firewall Configuration (UFW)"

if command -v ufw &> /dev/null; then
    log "Configuring UFW firewall..."
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp      # SSH
    ufw allow 80/tcp      # HTTP
    ufw allow 443/tcp     # HTTPS
    ufw allow 3306/tcp    # MySQL (if accessing remotely, restrict to specific IP)
    ufw enable
    success "Firewall configured"
else
    warning "UFW not installed. Configure your firewall manually."
fi

##############################################################################
# STEP 12: Monitoring & Logging
##############################################################################
header "Step 12: Setup Monitoring & Logging"

log "Configuring Laravel logging..."
mkdir -p $PROJECT_PATH/digiprojects-backend/storage/logs
chown -R www-data:www-data $PROJECT_PATH/digiprojects-backend/storage/logs
success "Logging configured"

##############################################################################
# FINAL SUMMARY
##############################################################################
header "Deployment Complete!"

echo -e "${GREEN}✓ All systems deployed successfully!${NC}\n"

echo "Database Credentials:"
echo "  User: $DB_USER"
echo "  Password: (saved in /root/.digiprojects-db-pass)"
echo ""

echo "Project Locations:"
echo "  Frontend: $FRONTEND_PATH/dist"
echo "  Backend: $BACKEND_PATH/public"
echo ""

echo "Websites:"
echo "  Frontend: https://$DOMAIN"
echo "  Backend API: https://$DOMAIN$API_PATH"
echo ""

echo "Next Steps:"
echo "  1. Set up SSL certificates:"
echo "     sudo certbot certonly --nginx -d $DOMAIN -d www.$DOMAIN"
echo ""
echo "  2. Restart Nginx:"
echo "     sudo systemctl restart nginx"
echo ""
echo "  3. Test the API:"
echo "     curl https://$DOMAIN$API_PATH/regions"
echo ""
echo "  4. View logs:"
echo "     tail -f /var/log/nginx/error.log"
echo "     tail -f $BACKEND_PATH/storage/logs/laravel.log"
echo ""

echo "Deployment log saved to: $LOG_FILE"
echo ""
