#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BASE_URL="http://127.0.0.1:8003/api"

echo -e "${BLUE}=== DigiProjects API Test ===${NC}\n"

# 1. List all counties
echo -e "${BLUE}1. Get all counties:${NC}"
curl -s "$BASE_URL/counties" | jq . || echo "No data"
echo ""

# 2. List all county officers
echo -e "${BLUE}2. Get all county officers:${NC}"
curl -s "$BASE_URL/users" | jq . || echo "No data"
echo ""

# 3. Get submissions
echo -e "${BLUE}3. Get all submissions:${NC}"
curl -s "$BASE_URL/submissions" | jq . || echo "No data"
echo ""

# 4. Get national stats (requires admin)
echo -e "${BLUE}4. Get national stats (requires admin auth):${NC}"
curl -s "$BASE_URL/submissions/national-stats" | jq . || echo "No data"
echo ""

# 5. Get county reports (requires admin)
echo -e "${BLUE}5. Get county reports aggregated (requires admin auth):${NC}"
curl -s "$BASE_URL/submissions/county-reports" | jq . || echo "No data"
echo ""

echo -e "${GREEN}✓ API test complete${NC}"
