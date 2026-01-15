#!/bin/bash

# DigiProjects API Integration Test Suite
# This script tests all CRUD operations to ensure frontend and backend integration

BASE_URL="http://127.0.0.1:8003/api"
PASSED=0
FAILED=0

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================"
echo "DigiProjects API Test Suite"
echo "================================"
echo ""

# Test 1: Get Counties
echo -e "${YELLOW}[TEST 1] GET /api/counties${NC}"
RESULT=$(curl -s "$BASE_URL/counties")
COUNT=$(echo "$RESULT" | jq 'length' 2>/dev/null)
if [ "$COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ PASSED${NC} - Found $COUNT counties"
    ((PASSED++))
else
    echo -e "${RED}✗ FAILED${NC} - No counties found"
    ((FAILED++))
fi
echo ""

# Test 2: Get Officers
echo -e "${YELLOW}[TEST 2] GET /api/users${NC}"
RESULT=$(curl -s "$BASE_URL/users")
COUNT=$(echo "$RESULT" | jq 'length' 2>/dev/null)
if [ "$COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ PASSED${NC} - Found $COUNT officers"
    ((PASSED++))
else
    echo -e "${RED}✗ FAILED${NC} - No officers found"
    ((FAILED++))
fi
echo ""

# Test 3: Get Regions
echo -e "${YELLOW}[TEST 3] GET /api/regions${NC}"
RESULT=$(curl -s "$BASE_URL/regions")
COUNT=$(echo "$RESULT" | jq 'length' 2>/dev/null)
if [ "$COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ PASSED${NC} - Found $COUNT regions"
    ((PASSED++))
else
    echo -e "${RED}✗ FAILED${NC} - No regions found"
    ((FAILED++))
fi
echo ""

# Test 4: Create Officer
echo -e "${YELLOW}[TEST 4] POST /api/users (Create Officer)${NC}"
RESULT=$(curl -s -X POST "$BASE_URL/users" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "API Test Officer",
    "email": "apitest@test.go.ke",
    "password": "testpass123",
    "county_id": 1
  }')
ID=$(echo "$RESULT" | jq '.id' 2>/dev/null)
if [ ! -z "$ID" ] && [ "$ID" != "null" ]; then
    echo -e "${GREEN}✓ PASSED${NC} - Officer created with ID: $ID"
    TEST_OFFICER_ID=$ID
    ((PASSED++))
else
    echo -e "${RED}✗ FAILED${NC} - Could not create officer"
    ((FAILED++))
fi
echo ""

# Test 5: Create County
echo -e "${YELLOW}[TEST 5] POST /api/counties (Create County)${NC}"
RESULT=$(curl -s -X POST "$BASE_URL/counties" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "API Test County",
    "region_id": 1,
    "is_active": true
  }')
ID=$(echo "$RESULT" | jq '.id' 2>/dev/null)
if [ ! -z "$ID" ] && [ "$ID" != "null" ]; then
    echo -e "${GREEN}✓ PASSED${NC} - County created with ID: $ID"
    TEST_COUNTY_ID=$ID
    ((PASSED++))
else
    echo -e "${RED}✗ FAILED${NC} - Could not create county"
    ((FAILED++))
fi
echo ""

# Test 6: Update Officer
echo -e "${YELLOW}[TEST 6] PUT /api/users/{id} (Update Officer)${NC}"
if [ ! -z "$TEST_OFFICER_ID" ]; then
    RESULT=$(curl -s -X PUT "$BASE_URL/users/$TEST_OFFICER_ID" \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Updated API Test Officer",
        "county_id": 2
      }')
    NAME=$(echo "$RESULT" | jq '.name' 2>/dev/null | tr -d '"')
    if [ "$NAME" = "Updated API Test Officer" ]; then
        echo -e "${GREEN}✓ PASSED${NC} - Officer updated successfully"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC} - Could not update officer"
        ((FAILED++))
    fi
else
    echo -e "${YELLOW}⊘ SKIPPED${NC} - No officer ID to test update"
fi
echo ""

# Test 7: Update County
echo -e "${YELLOW}[TEST 7] PUT /api/counties/{id} (Update County)${NC}"
if [ ! -z "$TEST_COUNTY_ID" ]; then
    RESULT=$(curl -s -X PUT "$BASE_URL/counties/$TEST_COUNTY_ID" \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Updated API Test County",
        "region_id": 2,
        "is_active": false
      }')
    NAME=$(echo "$RESULT" | jq '.name' 2>/dev/null | tr -d '"')
    if [ "$NAME" = "Updated API Test County" ]; then
        echo -e "${GREEN}✓ PASSED${NC} - County updated successfully"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC} - Could not update county"
        ((FAILED++))
    fi
else
    echo -e "${YELLOW}⊘ SKIPPED${NC} - No county ID to test update"
fi
echo ""

# Test 8: Delete Officer
echo -e "${YELLOW}[TEST 8] DELETE /api/users/{id} (Delete Officer)${NC}"
if [ ! -z "$TEST_OFFICER_ID" ]; then
    RESULT=$(curl -s -X DELETE "$BASE_URL/users/$TEST_OFFICER_ID")
    MESSAGE=$(echo "$RESULT" | jq '.message' 2>/dev/null | tr -d '"')
    if [[ "$MESSAGE" == *"deleted"* ]] || [[ "$MESSAGE" == *"deleted successfully"* ]]; then
        echo -e "${GREEN}✓ PASSED${NC} - Officer deleted successfully"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC} - Could not delete officer"
        echo "Response: $MESSAGE"
        ((FAILED++))
    fi
else
    echo -e "${YELLOW}⊘ SKIPPED${NC} - No officer ID to test delete"
fi
echo ""

# Test 9: Delete County
echo -e "${YELLOW}[TEST 9] DELETE /api/counties/{id} (Delete County)${NC}"
if [ ! -z "$TEST_COUNTY_ID" ]; then
    RESULT=$(curl -s -X DELETE "$BASE_URL/counties/$TEST_COUNTY_ID")
    MESSAGE=$(echo "$RESULT" | jq '.message' 2>/dev/null | tr -d '"')
    if [[ "$MESSAGE" == *"deleted"* ]] || [[ "$MESSAGE" == *"deleted successfully"* ]]; then
        echo -e "${GREEN}✓ PASSED${NC} - County deleted successfully"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC} - Could not delete county"
        echo "Response: $MESSAGE"
        ((FAILED++))
    fi
else
    echo -e "${YELLOW}⊘ SKIPPED${NC} - No county ID to test delete"
fi
echo ""

# Summary
echo "================================"
echo "Test Summary"
echo "================================"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
TOTAL=$((PASSED + FAILED))
echo "Total: $TOTAL"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
