#!/bin/bash

# EatSafe Web Deployment Script
# This script helps deploy the EatSafe web app to various platforms

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}   EatSafe Web Deployment Tool   ${NC}"
echo -e "${BLUE}================================${NC}"

# Build the web version
echo -e "\n${YELLOW}Building web release...${NC}"
flutter build web --release

if [ $? -ne 0 ]; then
    echo -e "${RED}Build failed! Please fix errors and try again.${NC}"
    exit 1
fi

echo -e "${GREEN}Build successful!${NC}"

# Choose deployment target
echo -e "\n${YELLOW}Choose deployment target:${NC}"
echo "1) Firebase Hosting"
echo "2) GitHub Pages"
echo "3) Local web server (for testing)"
echo "4) Exit"

read -p "Enter choice (1-4): " choice

case $choice in
    1)
        # Firebase deployment
        echo -e "\n${YELLOW}Deploying to Firebase Hosting...${NC}"
        command -v firebase >/dev/null 2>&1 || { 
            echo -e "${RED}Firebase CLI not found. Please install it with: npm install -g firebase-tools${NC}"; 
            exit 1; 
        }
        
        echo -e "${YELLOW}Logging in to Firebase...${NC}"
        firebase login
        
        echo -e "${YELLOW}Deploying to Firebase...${NC}"
        firebase deploy
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Successfully deployed to Firebase!${NC}"
            echo -e "Your app is live at: ${BLUE}https://eatsafe-app.web.app${NC}"
        else
            echo -e "${RED}Firebase deployment failed!${NC}"
        fi
        ;;
        
    2)
        # GitHub Pages deployment
        echo -e "\n${YELLOW}Preparing for GitHub Pages deployment...${NC}"
        
        # Check if gh-pages branch exists
        if git show-ref --verify --quiet refs/heads/gh-pages; then
            echo -e "${YELLOW}gh-pages branch exists. Updating it...${NC}"
            git branch -D gh-pages
        fi
        
        # Create and switch to gh-pages branch
        git checkout -b gh-pages
        
        # Remove existing files except build/web and .git
        find . -type f -not -path "./build/web/*" -not -path "./.git/*" -not -name ".gitignore" -delete
        find . -type d -empty -not -path "./build/web*" -not -path "./.git*" -delete 2>/dev/null || true
        
        # Copy web build files to root
        cp -R build/web/* .
        
        # Add all files
        git add .
        git commit -m "Deploy to GitHub Pages"
        
        echo -e "${YELLOW}Ready to push to GitHub.${NC}"
        echo -e "${YELLOW}To complete deployment, push this branch to GitHub with:${NC}"
        echo -e "${BLUE}git push origin gh-pages --force${NC}"
        echo -e "${YELLOW}Then enable GitHub Pages in your repository settings.${NC}"
        ;;
        
    3)
        # Local testing
        echo -e "\n${YELLOW}Starting local web server...${NC}"
        echo -e "${YELLOW}Press Ctrl+C to stop the server${NC}"
        echo -e "${GREEN}Your app is available at: ${BLUE}http://localhost:8000${NC}"
        cd build/web && python3 -m http.server 8000
        ;;
        
    4)
        echo -e "\n${YELLOW}Exiting without deployment.${NC}"
        exit 0
        ;;
        
    *)
        echo -e "\n${RED}Invalid choice. Exiting.${NC}"
        exit 1
        ;;
esac 