#!/bin/bash

# DigiProjects VPS Setup Script
# This script helps set up the backend and frontend on your VPS

set -e  # Exit on error

echo "======================================"
echo "DigiProjects VPS Setup"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}This script must be run as root${NC}"
    exit 1
fi

# Get configuration from user
read -p "Enter your VPS domain (e.g., digiprojects.co.ke): " DOMAIN
read -p "Enter your VPS domain for API (e.g., api.digiprojects.co.ke): " API_DOMAIN
read -p "Enter MySQL root password: " -s MYSQL_ROOT_PASS
echo ""
read -p "Enter database password for digiprojects_user: " -s DB_PASS
echo ""
read -p "Enter path to project folder (default: /var/www/digiprojects): " PROJECT_PATH
PROJECT_PATH=${PROJECT_PATH:-/var/www/digiprojects}

echo -e "${YELLOW}Starting setup with the following configuration:${NC}"
echo "Domain: $DOMAIN"
echo "API Domain: $API_DOMAIN"
echo "Project Path: $PROJECT_PATH"
echo ""

# Step 1: Create project directory
echo -e "${YELLOW}Step 1: Creating project directory...${NC}"
mkdir -p $PROJECT_PATH
cd $PROJECT_PATH

# Step 2: Create MySQL database
echo -e "${YELLOW}Step 2: Setting up MySQL database...${NC}"
mysql -u root -p"$MYSQL_ROOT_PASS" <<EOF
CREATE DATABASE IF NOT EXISTS digiprojects CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'digiprojects_user'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON digiprojects.* TO 'digiprojects_user'@'localhost';
FLUSH PRIVILEGES;
EOF
echo -e "${GREEN}✓ Database created${NC}"

# Step 3: Setup Backend
if [ -d "digiprojects-backend" ]; then
    echo -e "${YELLOW}Step 3: Setting up backend...${NC}"
    cd digiprojects-backend
    
    # Update .env
    cp .env .env.backup
    sed -i "s|APP_ENV=.*|APP_ENV=production|" .env
    sed -i "s|APP_DEBUG=.*|APP_DEBUG=false|" .env
    sed -i "s|APP_URL=.*|APP_URL=https://$API_DOMAIN|" .env
    sed -i "s|DB_CONNECTION=.*|DB_CONNECTION=mysql|" .env
    sed -i "s|DB_HOST=.*|DB_HOST=127.0.0.1|" .env
    sed -i "s|DB_PORT=.*|DB_PORT=3306|" .env
    sed -i "s|DB_DATABASE=.*|DB_DATABASE=digiprojects|" .env
    sed -i "s|DB_USERNAME=.*|DB_USERNAME=digiprojects_user|" .env
    sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=$DB_PASS|" .env
    sed -i "s|SESSION_DOMAIN=.*|SESSION_DOMAIN=.${DOMAIN#www.}|" .env
    
    # Install composer dependencies
    composer install --no-dev --optimize-autoloader
    
    # Run migrations
    php artisan migrate --force
    
    # Cache configuration
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    
    # Set permissions
    chmod -R 775 storage bootstrap/cache
    chown -R www-data:www-data storage bootstrap/cache
    
    echo -e "${GREEN}✓ Backend setup complete${NC}"
    cd ..
else
    echo -e "${RED}Backend directory not found${NC}"
fi

# Step 4: Setup Frontend
if [ -d "digiprojects-frontend" ]; then
    echo -e "${YELLOW}Step 4: Setting up frontend...${NC}"
    cd digiprojects-frontend
    
    # Create .env file
    cat > .env <<EOF
VITE_API_BASE_URL=https://$API_DOMAIN/api
EOF
    
    # Build frontend
    npm install
    npm run build
    
    # Set permissions on dist folder
    chmod -R 755 dist
    chown -R www-data:www-data dist
    
    echo -e "${GREEN}✓ Frontend built successfully${NC}"
    cd ..
else
    echo -e "${RED}Frontend directory not found${NC}"
fi

echo ""
echo -e "${GREEN}======================================"
echo "Setup Complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Configure Nginx for frontend and backend"
echo "2. Set up SSL certificates with Let's Encrypt"
echo "3. Restart web server: systemctl restart nginx"
echo "4. Test API: curl https://$API_DOMAIN/api/regions"
echo "5. Visit https://$DOMAIN in your browser"
echo ""
