#!/bin/bash

##############################################################################
# Quick SSL Certificate Setup
# Run this AFTER the main deploy.sh script completes
##############################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}DigiProjects SSL Certificate Setup${NC}"
echo -e "${YELLOW}========================================${NC}\n"

DOMAIN="digiprojects.co.ke"

# Check if certbot is installed
if ! command -v certbot &> /dev/null; then
    echo -e "${RED}Certbot not found. Installing...${NC}"
    apt-get install -y certbot python3-certbot-nginx
fi

echo -e "${YELLOW}1. Checking domain resolution...${NC}"
if ping -c 1 $DOMAIN &> /dev/null; then
    echo -e "${GREEN}✓ Domain $DOMAIN resolves correctly${NC}"
else
    echo -e "${RED}✗ Domain $DOMAIN cannot be resolved${NC}"
    echo -e "${YELLOW}Make sure your DNS is pointing to this server's IP address${NC}"
    read -p "Continue anyway? (yes/no) " -r
    if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
        exit 1
    fi
fi

echo -e "\n${YELLOW}2. Generating SSL certificates...${NC}"
certbot certonly --nginx \
    -d $DOMAIN \
    -d www.$DOMAIN \
    --agree-tos \
    --no-eff-email \
    --register-unsafely-without-email

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ SSL certificates generated successfully${NC}"
else
    echo -e "${RED}✗ SSL certificate generation failed${NC}"
    exit 1
fi

echo -e "\n${YELLOW}3. Restarting Nginx...${NC}"
systemctl restart nginx
echo -e "${GREEN}✓ Nginx restarted${NC}"

echo -e "\n${YELLOW}4. Verifying SSL certificates...${NC}"
certbot certificates

echo -e "\n${YELLOW}5. Testing HTTPS connectivity...${NC}"
if curl -s https://$DOMAIN > /dev/null; then
    echo -e "${GREEN}✓ Frontend HTTPS working${NC}"
else
    echo -e "${RED}✗ Frontend HTTPS test failed${NC}"
fi

if curl -s https://$DOMAIN$API_PATH/regions > /dev/null; then
    echo -e "${GREEN}✓ Backend API HTTPS working${NC}"
else
    echo -e "${RED}✗ Backend API HTTPS test failed${NC}"
fi

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}SSL Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo "Your sites are now accessible via HTTPS:"
echo "  https://$DOMAIN"
echo "  https://$DOMAIN$API_PATH"
echo ""
echo "SSL certificates will auto-renew. Check renewal status with:"
echo "  sudo certbot renew --dry-run"
