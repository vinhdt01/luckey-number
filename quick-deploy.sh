#!/bin/bash

# Quick deployment script
set -e

echo "🚀 Lucky Numbers API Quick Deploy"
echo "================================="

# Function to deploy to EC2
deploy_ec2() {
    echo "📦 Deploying to EC2..."
    
    # Build and push to DockerHub
    echo "Building Docker image..."
    docker build -f Dockerfile.prod -t $DOCKERHUB_USERNAME/lucky-numbers-api:latest .
    docker push $DOCKERHUB_USERNAME/lucky-numbers-api:latest
    
    # Deploy to EC2
    ./deploy-ec2.sh
    
    echo "✅ EC2 deployment completed!"
}

# Function to deploy to K8s
deploy_k8s() {
    echo "☸️  Deploying to Kubernetes..."
    
    # Apply K8s manifests
    kubectl apply -f k8s/namespace.yaml
    kubectl apply -f k8s/configmap.yaml
    kubectl apply -f k8s/secret.yaml
    kubectl apply -f k8s/postgres.yaml
    kubectl apply -f k8s/app.yaml
    
    # Wait for deployment
    kubectl rollout status deployment/app-deployment -n lucky-numbers
    kubectl rollout status deployment/postgres-deployment -n lucky-numbers
    
    # Get service info
    echo "📝 Service Information:"
    kubectl get services -n lucky-numbers
    kubectl get ingress -n lucky-numbers
    
    echo "✅ K8s deployment completed!"
}

# Main menu
echo "Choose deployment target:"
echo "1) EC2 only"
echo "2) Kubernetes only"
echo "3) Both EC2 and K8s"
echo "4) Local development"

read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        deploy_ec2
        ;;
    2)
        deploy_k8s
        ;;
    3)
        deploy_ec2
        deploy_k8s
        ;;
    4)
        echo "🏠 Starting local development..."
        docker-compose up --build
        ;;
    *)
        echo "Invalid choice!"
        exit 1
        ;;
esac

echo ""
echo "🎉 Deployment process completed!"
echo "Check your application status and logs."