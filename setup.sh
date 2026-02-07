#!/bin/bash

# Setup script for My Project
# This script installs dependencies and runs tests for all projects

set -e  # Exit on error

echo "=========================================="
echo "My Project - Setup Script"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"

if ! command -v node &> /dev/null; then
    echo -e "${RED}Error: Node.js is not installed${NC}"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo -e "${RED}Error: npm is not installed${NC}"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo -e "${RED}Error: Node.js version must be 18 or higher (current: $(node -v))${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Node.js $(node -v)${NC}"
echo -e "${GREEN}✓ npm $(npm -v)${NC}"
echo ""

# Install infrastructure dependencies
echo -e "${BLUE}Installing infrastructure dependencies...${NC}"
cd my-project-infrastructure
npm install
echo -e "${GREEN}✓ Infrastructure dependencies installed${NC}"
echo ""

# Build and test infrastructure
echo -e "${BLUE}Building and testing infrastructure...${NC}"
npm run build
npm test
echo -e "${GREEN}✓ Infrastructure built and tested${NC}"
echo ""

# Install API dependencies
echo -e "${BLUE}Installing API dependencies...${NC}"
cd ../my-project-api
npm install
echo -e "${GREEN}✓ API dependencies installed${NC}"
echo ""

# Build and test API
echo -e "${BLUE}Building and testing API...${NC}"
npm run build
npm test
echo -e "${GREEN}✓ API built and tested${NC}"
echo ""

# Install web dependencies
echo -e "${BLUE}Installing web dependencies...${NC}"
cd ../my-project-web
npm install --legacy-peer-deps
echo -e "${GREEN}✓ Web dependencies installed${NC}"
echo ""

# Test web
echo -e "${BLUE}Testing web application...${NC}"
npm test
echo -e "${GREEN}✓ Web application tested${NC}"
echo ""

cd ..

echo "=========================================="
echo -e "${GREEN}Setup Complete!${NC}"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Deploy to AWS:"
echo "   cd my-project-infrastructure"
echo "   cdk bootstrap  # First time only"
echo "   npm run deploy:beta"
echo ""
echo "2. Get API credentials:"
echo "   aws cloudformation describe-stacks --stack-name betaMyServiceAPIStack --query 'Stacks[0].Outputs'"
echo ""
echo "3. Configure frontend:"
echo "   cd my-project-web"
echo "   cp .env.example .env.development"
echo "   # Edit .env.development with your API credentials"
echo ""
echo "4. Run frontend locally:"
echo "   npm run dev"
echo ""
echo "See QUICKSTART.md for detailed instructions."
echo ""
