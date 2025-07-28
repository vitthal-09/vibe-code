#!/bin/bash

# N8N Social Media Automation Setup Script
# This script sets up the complete automation environment

set -e

echo "🚀 Setting up N8N Social Media Automation Environment..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p workflows credentials templates scripts logs backups

# Set proper permissions
echo "🔒 Setting permissions..."
chmod +x scripts/*.sh 2>/dev/null || true

# Pull Docker images
echo "📦 Pulling Docker images..."
docker-compose pull

# Start services
echo "🔄 Starting N8N services..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 30

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Services are running successfully!"
    echo ""
    echo "🌐 N8N is now accessible at: http://localhost:5678"
    echo "👤 Default credentials:"
    echo "   Username: admin"
    echo "   Password: admin123"
    echo ""
    echo "📋 Next steps:"
    echo "1. Access N8N at http://localhost:5678"
    echo "2. Configure credentials using templates/credentials-template.json"
    echo "3. Import workflows from the workflows/ directory"
    echo "4. Set up Google Sheets using templates/google-sheets-templates.md"
    echo "5. Update workflow configurations with your sheet IDs and credentials"
    echo ""
    echo "📚 Documentation:"
    echo "- Credentials setup: ./credentials/credentials-template.json"
    echo "- Google Sheets templates: ./templates/google-sheets-templates.md"
    echo "- Workflow files: ./workflows/"
    echo ""
    echo "🛠️  Useful commands:"
    echo "- View logs: docker-compose logs -f"
    echo "- Stop services: docker-compose down"
    echo "- Restart services: docker-compose restart"
    echo "- Backup workflows: ./scripts/backup.sh"
else
    echo "❌ Services failed to start. Check logs with: docker-compose logs"
    exit 1
fi