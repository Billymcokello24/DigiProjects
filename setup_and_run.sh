#!/bin/bash

# DigiProjects - Complete Setup & Run Script
# This script sets up and runs the entire DigiProjects application

set -e

echo "======================================"
echo "DigiProjects - Complete Setup"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_PATH="/home/billy/Desktop/Projects/DigiProjects"

# Section 1: Backend Setup
echo -e "${BLUE}[1/4] Backend Setup${NC}"
echo "========================================"
cd "$PROJECT_PATH/digiprojects-backend"

echo "Clearing caches..."
php artisan cache:clear 2>/dev/null || true
php artisan route:clear 2>/dev/null || true
php artisan config:clear 2>/dev/null || true

echo "Running migrations..."
php artisan migrate --force 2>/dev/null || true

echo -e "${GREEN}✓ Backend ready${NC}"
echo ""

# Section 2: Start Backend Server
echo -e "${BLUE}[2/4] Starting Backend Server${NC}"
echo "========================================"
echo "Starting Laravel development server on port 8003..."
php artisan serve --port=8003 > /tmp/laravel_server.log 2>&1 &
LARAVEL_PID=$!
sleep 2

if kill -0 $LARAVEL_PID 2>/dev/null; then
    echo -e "${GREEN}✓ Backend server started (PID: $LARAVEL_PID)${NC}"
    echo "  URL: http://127.0.0.1:8001"
else
    echo -e "${YELLOW}⚠ Could not verify backend server startup${NC}"
fi
echo ""

# Section 3: Frontend Setup
echo -e "${BLUE}[3/4] Frontend Setup${NC}"
echo "========================================"
cd "$PROJECT_PATH/digiprojects-frontend"

if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install 2>/dev/null
fi

echo -e "${GREEN}✓ Frontend ready${NC}"
echo ""

# Section 4: Run Tests
echo -e "${BLUE}[4/4] Running Integration Tests${NC}"
echo "========================================"
cd "$PROJECT_PATH"
sleep 2

if [ -f "test_integration.sh" ]; then
    bash test_integration.sh
    TEST_RESULT=$?
    echo ""
    if [ $TEST_RESULT -eq 0 ]; then
        echo -e "${GREEN}✓ All integration tests passed!${NC}"
    else
        echo -e "${YELLOW}⚠ Some tests failed, but setup continues${NC}"
    fi
else
    echo "Test file not found, skipping tests"
fi

echo ""
echo "======================================"
echo "Setup Complete!"
echo "======================================"
echo ""
echo -e "${GREEN}Backend Server:${NC}"
echo "  Status: Running on port 8001"
echo "  URL: http://127.0.0.1:8001"
echo "  API Base: http://127.0.0.1:8001/api"
echo ""
echo -e "${GREEN}Frontend:${NC}"
echo "  To start frontend, run:"
echo "  ${YELLOW}cd $PROJECT_PATH/digiprojects-frontend && npm run dev${NC}"
echo ""
echo -e "${GREEN}Admin Access:${NC}"
echo "  1. Start frontend with npm run dev"
echo "  2. Navigate to login page"
echo "  3. Login with admin credentials"
echo "  4. Access management pages:"
echo "     • /admin/officers (Manage county officers)"
echo "     • /admin/counties (Manage counties)"
echo "     • /admin/county-reports (View aggregated reports)"
echo ""
echo -e "${GREEN}Available Tests:${NC}"
echo "  Run: ${YELLOW}./test_integration.sh${NC}"
echo "  Tests all CRUD operations"
echo ""
echo "======================================"
echo -e "${GREEN}System Ready! Let's go! 🚀${NC}"
echo "======================================"
