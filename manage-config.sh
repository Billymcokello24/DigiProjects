#!/bin/bash

##############################################################################
# DigiProjects Configuration Management Script
# Manage environment variables and deployment settings
##############################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BACKEND_PATH="/var/www/digiprojects/digiprojects-backend"
FRONTEND_PATH="/var/www/digiprojects/digiprojects-frontend"

show_menu() {
    clear
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════╗"
    echo "║   DigiProjects Configuration Manager   ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo "1. View Backend Environment Variables"
    echo "2. View Frontend Environment Variables"
    echo "3. Update Backend Database Password"
    echo "4. Update API URL"
    echo "5. Toggle Debug Mode"
    echo "6. Rebuild Frontend"
    echo "7. Clear Laravel Cache"
    echo "8. Backup Configuration"
    echo "9. Restore Configuration"
    echo "0. Exit"
    echo ""
}

view_backend_env() {
    echo -e "${BLUE}Backend Environment Variables:${NC}\n"
    grep -v '^#' $BACKEND_PATH/.env | grep -v '^$' | head -20
    echo ""
}

view_frontend_env() {
    echo -e "${BLUE}Frontend Environment Variables:${NC}\n"
    cat $FRONTEND_PATH/.env
    echo ""
}

update_db_password() {
    echo -e "${YELLOW}Updating Database Password${NC}\n"
    
    read -sp "Enter new database password: " NEW_PASS
    echo ""
    read -sp "Confirm password: " CONFIRM_PASS
    echo ""
    
    if [ "$NEW_PASS" != "$CONFIRM_PASS" ]; then
        echo -e "${RED}Passwords do not match${NC}"
        return 1
    fi
    
    # Update .env
    sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$NEW_PASS/" $BACKEND_PATH/.env
    
    # Update MySQL
    mysql -u root <<MYSQL_CMD
ALTER USER 'digiprojects_user'@'localhost' IDENTIFIED BY '$NEW_PASS';
FLUSH PRIVILEGES;
MYSQL_CMD
    
    # Restart PHP
    systemctl restart php8.2-fpm
    
    echo -e "${GREEN}✓ Database password updated${NC}"
}

update_api_url() {
    echo -e "${YELLOW}Update API URL${NC}\n"
    
    echo "Current API URL:"
    grep "VITE_API_BASE_URL" $FRONTEND_PATH/.env
    echo ""
    
    read -p "Enter new API URL (e.g., https://api.newdomain.com/api): " NEW_URL
    
    sed -i "s|VITE_API_BASE_URL=.*|VITE_API_BASE_URL=$NEW_URL|" $FRONTEND_PATH/.env
    
    echo -e "${YELLOW}Rebuilding frontend...${NC}"
    cd $FRONTEND_PATH
    npm run build > /dev/null 2>&1
    
    echo -e "${GREEN}✓ API URL updated and frontend rebuilt${NC}"
}

toggle_debug_mode() {
    CURRENT=$(grep "^APP_DEBUG=" $BACKEND_PATH/.env | cut -d= -f2)
    
    if [ "$CURRENT" = "true" ]; then
        NEW_VALUE="false"
        MODE="OFF"
    else
        NEW_VALUE="true"
        MODE="ON"
    fi
    
    sed -i "s/APP_DEBUG=.*/APP_DEBUG=$NEW_VALUE/" $BACKEND_PATH/.env
    systemctl restart php8.2-fpm
    
    echo -e "${GREEN}✓ Debug mode turned $MODE${NC}"
}

rebuild_frontend() {
    echo -e "${YELLOW}Rebuilding Frontend...${NC}\n"
    
    cd $FRONTEND_PATH
    
    echo "Installing dependencies..."
    npm install --legacy-peer-deps -q
    
    echo "Building application..."
    npm run build
    
    echo -e "${GREEN}✓ Frontend rebuilt successfully${NC}"
}

clear_laravel_cache() {
    echo -e "${YELLOW}Clearing Laravel Cache...${NC}\n"
    
    cd $BACKEND_PATH
    
    php artisan cache:clear
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    
    systemctl restart php8.2-fpm
    
    echo -e "${GREEN}✓ Cache cleared${NC}"
}

backup_config() {
    BACKUP_DIR="/var/backups/digiprojects/config"
    mkdir -p $BACKUP_DIR
    
    DATE=$(date +%Y%m%d_%H%M%S)
    
    cp $BACKEND_PATH/.env $BACKUP_DIR/backend-env_$DATE
    cp $FRONTEND_PATH/.env $BACKUP_DIR/frontend-env_$DATE
    cp /etc/nginx/sites-available/digiprojects $BACKUP_DIR/nginx-frontend_$DATE 2>/dev/null || true
    cp /etc/nginx/sites-available/digiprojects-api $BACKUP_DIR/nginx-backend_$DATE 2>/dev/null || true
    
    echo -e "${GREEN}✓ Configuration backed up to $BACKUP_DIR${NC}"
    echo -e "Backup files: config_*_$DATE"
}

restore_config() {
    BACKUP_DIR="/var/backups/digiprojects/config"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}No backup directory found${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Available backups:${NC}\n"
    ls -1 $BACKUP_DIR | tail -20
    echo ""
    
    read -p "Enter backup file prefix (e.g., backend-env_20260116): " PREFIX
    
    if [ -f "$BACKUP_DIR/${PREFIX}" ]; then
        if [[ $PREFIX == *"backend"* ]]; then
            cp "$BACKUP_DIR/$PREFIX" $BACKEND_PATH/.env
            systemctl restart php8.2-fpm
            echo -e "${GREEN}✓ Backend configuration restored${NC}"
        elif [[ $PREFIX == *"frontend"* ]]; then
            cp "$BACKUP_DIR/$PREFIX" $FRONTEND_PATH/.env
            echo -e "${GREEN}✓ Frontend configuration restored${NC}"
        fi
    else
        echo -e "${RED}File not found${NC}"
    fi
}

# Main loop
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}This script must be run as root${NC}"
    exit 1
fi

while true; do
    show_menu
    read -p "Choose option: " choice
    
    case $choice in
        1) view_backend_env; read -p "Press Enter to continue..." ;;
        2) view_frontend_env; read -p "Press Enter to continue..." ;;
        3) update_db_password; read -p "Press Enter to continue..." ;;
        4) update_api_url; read -p "Press Enter to continue..." ;;
        5) toggle_debug_mode; read -p "Press Enter to continue..." ;;
        6) rebuild_frontend; read -p "Press Enter to continue..." ;;
        7) clear_laravel_cache; read -p "Press Enter to continue..." ;;
        8) backup_config; read -p "Press Enter to continue..." ;;
        9) restore_config; read -p "Press Enter to continue..." ;;
        0) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 1 ;;
    esac
done
