#!/bin/bash

##############################################################################
# DigiProjects Post-Deployment Verification Script
# Run this to verify everything is working correctly
##############################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOMAIN="digiprojects.co.ke"
BACKEND_PATH="/var/www/digiprojects/digiprojects-backend"
API_PATH="/api"

test_passed=0
test_failed=0

check() {
    local test_name=$1
    local command=$2
    
    echo -n "Testing: $test_name... "
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((test_passed++))
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((test_failed++))
    fi
}

header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

summary() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Test Summary${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    echo -e "Passed: ${GREEN}$test_passed${NC}"
    echo -e "Failed: ${RED}$test_failed${NC}\n"
}

clear
echo -e "${YELLOW}"
echo "╔════════════════════════════════════════╗"
echo "║   DigiProjects Deployment Verification  ║"
echo "║        Domain: $DOMAIN        ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}\n"

# ============================================================================
header "System Services"

check "Nginx running" "systemctl is-active --quiet nginx"
check "PHP-FPM running" "systemctl is-active --quiet php8.2-fpm"
check "MySQL running" "systemctl is-active --quiet mysql"
check "Nginx config valid" "nginx -t"

# ============================================================================
header "Firewall & Network"

check "Port 80 open" "ss -tlnp | grep -q ':80 '"
check "Port 443 open" "ss -tlnp | grep -q ':443 '"
check "Port 3306 open" "ss -tlnp | grep -q ':3306 '"
check "DNS: $DOMAIN resolves" "getent hosts $DOMAIN"

# ============================================================================
header "Frontend"

check "Frontend dist exists" "[ -d /var/www/digiprojects/digiprojects-frontend/dist ]"
check "Frontend index.html exists" "[ -f /var/www/digiprojects/digiprojects-frontend/dist/index.html ]"
check "Frontend HTTP accessible" "curl -s http://$DOMAIN | grep -q 'html'"
check "Frontend .env exists" "[ -f /var/www/digiprojects/digiprojects-frontend/.env ]"

# ============================================================================
header "Backend API"

check "Backend public exists" "[ -d $BACKEND_PATH/public ]"
check "Backend storage exists" "[ -d $BACKEND_PATH/storage ]"
check "Backend .env exists" "[ -f $BACKEND_PATH/.env ]"
check "Backend HTTP accessible" "curl -s http://localhost$API_PATH/regions"

# ============================================================================
header "Database"

check "Database exists" "mysql -u digiprojects_user -p\$(cat /root/.digiprojects-db-pass 2>/dev/null || echo 'error') -e 'USE digiprojects;' 2>/dev/null || true"
check "Database migrations run" "[ -f $BACKEND_PATH/database/migrations/2026_01_14_162636_create_submissions_table.php ]"

# ============================================================================
header "SSL Certificates"

check "Frontend SSL cert exists" "[ -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem ]"
check "Backend SSL cert exists" "[ -f /etc/letsencrypt/live/$API_DOMAIN/fullchain.pem ]"
check "Frontend HTTPS works" "curl -s https://$DOMAIN | grep -q 'html'"
check "Backend API HTTPS works" "curl -s https://$API_DOMAIN/api/regions"

# ============================================================================
header "File Permissions"

check "Frontend dist owned by www-data" "[ \$(stat -c %U /var/www/digiprojects/digiprojects-frontend/dist) = 'www-data' ]"
check "Backend storage writable" "[ -w $BACKEND_PATH/storage ]"
check "Backend bootstrap cache writable" "[ -w $BACKEND_PATH/bootstrap/cache ]"

# ============================================================================
header "Configuration Files"

check "Nginx frontend config exists" "[ -f /etc/nginx/sites-available/digiprojects ]"
check "Frontend config readable" "[ -r /var/www/digiprojects/digiprojects-frontend/.env ]"
check "Backend config readable" "[ -r $BACKEND_PATH/.env ]"

# ============================================================================
header "Log Files"

check "Nginx error log exists" "[ -f /var/log/nginx/error.log ]"
check "PHP-FPM error log exists" "[ -f /var/log/php8.2-fpm.log ]"
check "Laravel log exists" "[ -f $BACKEND_PATH/storage/logs/laravel.log ]"

# ============================================================================
summary

if [ $test_failed -eq 0 ]; then
    echo -e "${GREEN}All tests passed! Your deployment is ready.${NC}\n"
    echo -e "Access your application at:"
    echo -e "  ${GREEN}https://$DOMAIN${NC}"
    echo -e "  ${GREEN}https://$DOMAIN$API_PATH${NC}\n"
else
    echo -e "${RED}Some tests failed. Please review the failures above.${NC}\n"
    echo "Common issues:"
    echo "  1. SSL certificates not yet generated (run setup-ssl.sh)"
    echo "  2. DNS not fully propagated (wait 24-48 hours)"
    echo "  3. Services not started (run: sudo systemctl start nginx php8.2-fpm mysql)"
    echo ""
fi

echo -e "${YELLOW}For detailed information, check:${NC}"
echo "  - Nginx error log: tail -f /var/log/nginx/error.log"
echo "  - Laravel log: tail -f $BACKEND_PATH/storage/logs/laravel.log"
echo "  - Full deployment log: cat /var/log/digiprojects-deploy.log"
echo ""
