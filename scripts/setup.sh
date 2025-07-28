#!/bin/bash

# Social Media Automation Setup Script
# This script sets up n8n workflows for LinkedIn and Instagram automation

set -e

echo "🚀 Setting up Social Media Automation with n8n..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    print_success "Docker is installed"
}

# Check if n8n is already running
check_n8n() {
    if docker ps | grep -q n8n; then
        print_warning "n8n is already running. Stopping existing container..."
        docker stop n8n || true
        docker rm n8n || true
    fi
}

# Create necessary directories
create_directories() {
    print_status "Creating necessary directories..."
    
    mkdir -p ~/.n8n
    mkdir -p ~/.n8n/workflows
    mkdir -p ~/.n8n/credentials
    mkdir -p ~/.n8n/data
    
    print_success "Directories created"
}

# Copy workflow files
copy_workflows() {
    print_status "Copying workflow files..."
    
    cp workflows/*.json ~/.n8n/workflows/ 2>/dev/null || {
        print_warning "No workflow files found in workflows/ directory"
    }
    
    print_success "Workflow files copied"
}

# Create environment file
create_env_file() {
    print_status "Creating environment configuration..."
    
    cat > .env << EOF
# n8n Configuration
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_secure_password

# Database Configuration
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=postgres
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=n8n
DB_POSTGRESDB_PASSWORD=n8n_password

# Redis Configuration
REDIS_HOST=redis
REDIS_PORT=6379

# Webhook Configuration
N8N_HOST=localhost
N8N_PORT=5678
N8N_PROTOCOL=http
WEBHOOK_URL=http://localhost:5678/

# Security
N8N_ENCRYPTION_KEY=your_encryption_key_here
N8N_JWT_SECRET=your_jwt_secret_here

# External APIs
LINKEDIN_CLIENT_ID=your_linkedin_client_id
LINKEDIN_CLIENT_SECRET=your_linkedin_client_secret
INSTAGRAM_ACCESS_TOKEN=your_instagram_access_token
INSTAGRAM_BUSINESS_ACCOUNT_ID=your_instagram_business_account_id

# Notifications
SLACK_WEBHOOK_URL=your_slack_webhook_url
EOF

    print_success "Environment file created"
    print_warning "Please update the .env file with your actual credentials"
}

# Create Docker Compose file
create_docker_compose() {
    print_status "Creating Docker Compose configuration..."
    
    cat > docker-compose.yml << EOF
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=your_secure_password
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=n8n
      - DB_POSTGRESDB_PASSWORD=n8n_password
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - WEBHOOK_URL=http://localhost:5678/
      - N8N_ENCRYPTION_KEY=your_encryption_key_here
      - N8N_JWT_SECRET=your_jwt_secret_here
      - LINKEDIN_CLIENT_ID=\${LINKEDIN_CLIENT_ID}
      - LINKEDIN_CLIENT_SECRET=\${LINKEDIN_CLIENT_SECRET}
      - INSTAGRAM_ACCESS_TOKEN=\${INSTAGRAM_ACCESS_TOKEN}
      - INSTAGRAM_BUSINESS_ACCOUNT_ID=\${INSTAGRAM_BUSINESS_ACCOUNT_ID}
      - SLACK_WEBHOOK_URL=\${SLACK_WEBHOOK_URL}
    volumes:
      - ~/.n8n:/home/node/.n8n
    depends_on:
      - postgres
      - redis
    networks:
      - n8n-network

  postgres:
    image: postgres:13
    container_name: n8n-postgres
    restart: unless-stopped
    environment:
      - POSTGRES_DB=n8n
      - POSTGRES_USER=n8n
      - POSTGRES_PASSWORD=n8n_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - n8n-network

  redis:
    image: redis:6-alpine
    container_name: n8n-redis
    restart: unless-stopped
    networks:
      - n8n-network

volumes:
  postgres_data:

networks:
  n8n-network:
    driver: bridge
EOF

    print_success "Docker Compose file created"
}

# Start n8n
start_n8n() {
    print_status "Starting n8n..."
    
    docker-compose up -d
    
    print_success "n8n is starting up..."
    print_status "You can access n8n at: http://localhost:5678"
    print_status "Username: admin"
    print_status "Password: your_secure_password"
}

# Import workflows
import_workflows() {
    print_status "Waiting for n8n to be ready..."
    
    # Wait for n8n to be ready
    timeout=60
    counter=0
    
    while [ $counter -lt $timeout ]; do
        if curl -s http://localhost:5678/healthz > /dev/null 2>&1; then
            print_success "n8n is ready!"
            break
        fi
        sleep 2
        counter=$((counter + 2))
    done
    
    if [ $counter -eq $timeout ]; then
        print_error "n8n failed to start within $timeout seconds"
        exit 1
    fi
    
    print_status "Importing workflows..."
    
    # Import workflows using n8n API
    for workflow in workflows/*.json; do
        if [ -f "$workflow" ]; then
            workflow_name=$(basename "$workflow" .json)
            print_status "Importing $workflow_name..."
            
            # Note: This would require authentication and proper API calls
            # For now, we'll just copy the files
            cp "$workflow" ~/.n8n/workflows/
        fi
    done
    
    print_success "Workflows copied to n8n directory"
}

# Setup instructions
show_instructions() {
    echo ""
    echo "🎉 Setup Complete!"
    echo ""
    echo "Next steps:"
    echo "1. Update the .env file with your actual API credentials"
    echo "2. Access n8n at http://localhost:5678"
    echo "3. Import the workflow files from the workflows/ directory"
    echo "4. Configure your LinkedIn and Instagram credentials in n8n"
    echo "5. Test the workflows with sample data"
    echo ""
    echo "📚 Documentation:"
    echo "- Workflow files are in the workflows/ directory"
    echo "- Configuration is in config/automation-settings.json"
    echo "- Setup guide is in docs/setup-guide.md"
    echo ""
    echo "🔧 Useful commands:"
    echo "- Start n8n: docker-compose up -d"
    echo "- Stop n8n: docker-compose down"
    echo "- View logs: docker-compose logs -f n8n"
    echo "- Restart n8n: docker-compose restart n8n"
    echo ""
}

# Main execution
main() {
    print_status "Starting Social Media Automation Setup..."
    
    check_docker
    check_n8n
    create_directories
    copy_workflows
    create_env_file
    create_docker_compose
    start_n8n
    import_workflows
    show_instructions
    
    print_success "Setup completed successfully!"
}

# Run main function
main "$@"