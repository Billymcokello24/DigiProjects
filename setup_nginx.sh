#!/bin/bash

# DigiProjects Nginx Setup Script for digiprojects.co.ke
# This script sets up Nginx configurations for both frontend and backend

set -e

echo "======================================"
echo "DigiProjects Nginx Setup"
echo "======================================"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}This script must be run as root${NC}"
    exit 1
fi

PROJECT_PATH="/var/www/digiprojects"
BACKEND_PATH="$PROJECT_PATH/digiprojects-backend"
FRONTEND_PATH="$PROJECT_PATH/digiprojects-frontend"

echo -e "${YELLOW}Setting up Nginx configurations...${NC}"

# Copy frontend config
echo -e "${YELLOW}1. Configuring frontend (digiprojects.co.ke)...${NC}"
cp $PROJECT_PATH/nginx-frontend.conf /etc/nginx/sites-available/digiprojects
ln -sf /etc/nginx/sites-available/digiprojects /etc/nginx/sites-enabled/digiprojects
echo -e "${GREEN}✓ Frontend config installed${NC}"

# Copy backend config
echo -e "${YELLOW}2. Configuring backend API (api.digiprojects.co.ke)...${NC}"
cp $PROJECT_PATH/nginx-backend-api.conf /etc/nginx/sites-available/digiprojects-api
ln -sf /etc/nginx/sites-available/digiprojects-api /etc/nginx/sites-enabled/digiprojects-api
echo -e "${GREEN}✓ Backend API config installed${NC}"

# Test Nginx configuration
echo -e "${YELLOW}3. Testing Nginx configuration...${NC}"
if nginx -t; then
    echo -e "${GREEN}✓ Nginx configuration is valid${NC}"
else
    echo -e "${RED}✗ Nginx configuration test failed${NC}"
    exit 1
fi

# Set proper permissions
echo -e "${YELLOW}4. Setting permissions...${NC}"
chmod -R 755 $FRONTEND_PATH/dist
chmod -R 755 $BACKEND_PATH/public
chown -R www-data:www-data $FRONTEND_PATH/dist
chown -R www-data:www-data $BACKEND_PATH/storage
chown -R www-data:www-data $BACKEND_PATH/bootstrap/cache
echo -e "${GREEN}✓ Permissions set${NC}"

# Reload Nginx
echo -e "${YELLOW}5. Reloading Nginx...${NC}"
systemctl reload nginx
echo -e "${GREEN}✓ Nginx reloaded${NC}"

echo ""
echo -e "${YELLOW}Next step: Set up SSL certificates with Let's Encrypt${NC}"
echo ""
echo "Run this command:"
echo "sudo certbot certonly --nginx -d digiprojects.co.ke -d www.digiprojects.co.ke -d api.digiprojects.co.ke"
echo ""
echo "After SSL setup is complete, restart Nginx:"
echo "sudo systemctl restart nginx"
echo ""
