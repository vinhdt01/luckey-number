#!/bin/bash

# EC2 Deployment Script
set -e

# Configuration
EC2_HOST="your-ec2-host.amazonaws.com"
EC2_USER="ubuntu"
KEY_PATH="~/.ssh/your-key.pem"
APP_NAME="lucky-numbers-api"
GITHUB_REPO="your-username/lucky-numbers-be"

echo "🚀 Starting deployment to EC2..."

# SSH into EC2 and deploy
ssh -i $KEY_PATH $EC2_USER@$EC2_HOST << 'ENDSSH'
    set -e
    
    # Update system
    sudo apt-get update
    
    # Install Docker if not exists
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
    fi
    
    # Install Docker Compose if not exists
    if ! command -v docker-compose &> /dev/null; then
        echo "Installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi
    
    # Clone/Update repository
    if [ -d "lucky-numbers-be" ]; then
        echo "Updating repository..."
        cd lucky-numbers-be
        git pull origin main
    else
        echo "Cloning repository..."
        git clone https://github.com/your-username/lucky-numbers-be.git
        cd lucky-numbers-be
    fi
    
    # Stop existing containers
    echo "Stopping existing containers..."
    docker-compose -f docker-compose.prod.yml down || true
    
    # Remove old images
    docker image prune -f
    
    # Build and start new containers
    echo "Building and starting containers..."
    docker-compose -f docker-compose.prod.yml up -d --build
    
    # Show running containers
    docker ps
    
    echo "✅ Deployment completed!"
    echo "App should be available at http://$(curl -s ifconfig.me)"
ENDSSH

echo "🎉 Deployment script finished!"