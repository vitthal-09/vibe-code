#!/bin/bash

# Production Deployment Script for Social Media Automation
# This script deploys n8n workflows to production environment

set -e

echo "🚀 Deploying Social Media Automation to Production..."

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

# Check if running as root
check_permissions() {
    if [ "$EUID" -eq 0 ]; then
        print_error "Please do not run this script as root"
        exit 1
    fi
}

# Check if Docker and Docker Compose are installed
check_dependencies() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed"
        exit 1
    fi
    
    print_success "Dependencies checked"
}

# Create production environment file
create_production_env() {
    print_status "Creating production environment configuration..."
    
    if [ ! -f .env.production ]; then
        cat > .env.production << EOF
# Production n8n Configuration
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=${N8N_PASSWORD:-$(openssl rand -base64 32)}

# Database Configuration
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=postgres
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=n8n
DB_POSTGRESDB_PASSWORD=${DB_PASSWORD:-$(openssl rand -base64 32)}

# Redis Configuration
REDIS_HOST=redis
REDIS_PORT=6379

# Webhook Configuration
N8N_HOST=${N8N_HOST:-localhost}
N8N_PORT=5678
N8N_PROTOCOL=${N8N_PROTOCOL:-https}
WEBHOOK_URL=${WEBHOOK_URL:-https://your-domain.com/}

# Security
N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY:-$(openssl rand -base64 32)}
N8N_JWT_SECRET=${N8N_JWT_SECRET:-$(openssl rand -base64 32)}

# External APIs
LINKEDIN_CLIENT_ID=${LINKEDIN_CLIENT_ID}
LINKEDIN_CLIENT_SECRET=${LINKEDIN_CLIENT_SECRET}
INSTAGRAM_ACCESS_TOKEN=${INSTAGRAM_ACCESS_TOKEN}
INSTAGRAM_BUSINESS_ACCOUNT_ID=${INSTAGRAM_BUSINESS_ACCOUNT_ID}

# Notifications
SLACK_WEBHOOK_URL=${SLACK_WEBHOOK_URL}

# Production Settings
NODE_ENV=production
N8N_LOG_LEVEL=info
N8N_DIAGNOSTICS_ENABLED=false
EOF
        print_success "Production environment file created"
    else
        print_warning "Production environment file already exists"
    fi
}

# Create production Docker Compose file
create_production_docker_compose() {
    print_status "Creating production Docker Compose configuration..."
    
    cat > docker-compose.prod.yml << EOF
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n-production
    restart: unless-stopped
    ports:
      - "5678:5678"
    env_file:
      - .env.production
    volumes:
      - n8n_data:/home/node/.n8n
      - ./workflows:/home/node/.n8n/workflows:ro
      - ./config:/home/node/.n8n/config:ro
    depends_on:
      - postgres
      - redis
    networks:
      - n8n-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.n8n.rule=Host(\`${N8N_HOST:-localhost}\`)"
      - "traefik.http.routers.n8n.tls=true"
      - "traefik.http.services.n8n.loadbalancer.server.port=5678"

  postgres:
    image: postgres:13
    container_name: n8n-postgres-production
    restart: unless-stopped
    env_file:
      - .env.production
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - n8n-network
    labels:
      - "traefik.enable=false"

  redis:
    image: redis:6-alpine
    container_name: n8n-redis-production
    restart: unless-stopped
    networks:
      - n8n-network
    labels:
      - "traefik.enable=false"

  # Optional: Traefik for SSL termination
  traefik:
    image: traefik:v2.5
    container_name: traefik
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik.yml:/etc/traefik/traefik.yml:ro
      - ./certs:/etc/certs:ro
    networks:
      - n8n-network
    profiles:
      - ssl

volumes:
  n8n_data:
  postgres_data:

networks:
  n8n-network:
    driver: bridge
EOF

    print_success "Production Docker Compose file created"
}

# Create Traefik configuration
create_traefik_config() {
    print_status "Creating Traefik configuration..."
    
    cat > traefik.yml << EOF
api:
  dashboard: true
  insecure: false

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entrypoint:
          to: websecure
          scheme: https
  websecure:
    address: ":443"

certificatesResolvers:
  letsencrypt:
    acme:
      email: ${ACME_EMAIL:-admin@example.com}
      storage: acme.json
      httpChallenge:
        entryPoint: web

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
EOF

    print_success "Traefik configuration created"
}

# Create systemd service file
create_systemd_service() {
    print_status "Creating systemd service..."
    
    sudo tee /etc/systemd/system/n8n.service > /dev/null << EOF
[Unit]
Description=n8n Social Media Automation
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$(pwd)
ExecStart=/usr/local/bin/docker-compose -f docker-compose.prod.yml up -d
ExecStop=/usr/local/bin/docker-compose -f docker-compose.prod.yml down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

    print_success "Systemd service created"
}

# Setup monitoring
setup_monitoring() {
    print_status "Setting up monitoring..."
    
    # Create monitoring script
    cat > scripts/monitor.sh << 'EOF'
#!/bin/bash

# Monitoring script for n8n production deployment

LOG_FILE="/var/log/n8n-monitor.log"
ALERT_EMAIL="admin@example.com"

# Check if n8n is running
check_n8n() {
    if ! docker ps | grep -q n8n-production; then
        echo "$(date): n8n container is not running!" >> "$LOG_FILE"
        # Send alert email
        echo "n8n container is down at $(date)" | mail -s "n8n Alert" "$ALERT_EMAIL"
        return 1
    fi
    return 0
}

# Check n8n health
check_health() {
    if ! curl -s http://localhost:5678/healthz > /dev/null; then
        echo "$(date): n8n health check failed!" >> "$LOG_FILE"
        return 1
    fi
    return 0
}

# Check disk space
check_disk() {
    DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$DISK_USAGE" -gt 80 ]; then
        echo "$(date): Disk usage is high: ${DISK_USAGE}%" >> "$LOG_FILE"
        return 1
    fi
    return 0
}

# Main monitoring
main() {
    check_n8n || exit 1
    check_health || exit 1
    check_disk || exit 1
    
    echo "$(date): All checks passed" >> "$LOG_FILE"
}

main "$@"
EOF

    chmod +x scripts/monitor.sh
    
    # Create cron job for monitoring
    (crontab -l 2>/dev/null; echo "*/5 * * * * $(pwd)/scripts/monitor.sh") | crontab -
    
    print_success "Monitoring setup completed"
}

# Backup existing data
backup_data() {
    print_status "Creating backup of existing data..."
    
    BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    if docker ps | grep -q n8n; then
        docker exec n8n-production tar czf - /home/node/.n8n > "$BACKUP_DIR/n8n_data.tar.gz" 2>/dev/null || true
        print_success "Backup created in $BACKUP_DIR"
    else
        print_warning "No running n8n container found for backup"
    fi
}

# Deploy to production
deploy() {
    print_status "Deploying to production..."
    
    # Stop existing containers
    docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
    
    # Pull latest images
    docker-compose -f docker-compose.prod.yml pull
    
    # Start services
    docker-compose -f docker-compose.prod.yml up -d
    
    print_success "Deployment completed"
}

# Setup SSL (optional)
setup_ssl() {
    if [ "$ENABLE_SSL" = "true" ]; then
        print_status "Setting up SSL with Let's Encrypt..."
        
        mkdir -p certs
        docker-compose -f docker-compose.prod.yml --profile ssl up -d traefik
        
        print_success "SSL setup completed"
    fi
}

# Health check
health_check() {
    print_status "Performing health check..."
    
    timeout=120
    counter=0
    
    while [ $counter -lt $timeout ]; do
        if curl -s http://localhost:5678/healthz > /dev/null 2>&1; then
            print_success "n8n is healthy and running!"
            return 0
        fi
        sleep 5
        counter=$((counter + 5))
    done
    
    print_error "Health check failed after $timeout seconds"
    return 1
}

# Show deployment info
show_deployment_info() {
    echo ""
    echo "🎉 Production Deployment Complete!"
    echo ""
    echo "📊 Deployment Information:"
    echo "- n8n URL: ${N8N_PROTOCOL:-https}://${N8N_HOST:-localhost}:5678"
    echo "- Admin Username: admin"
    echo "- Admin Password: Check .env.production file"
    echo ""
    echo "🔧 Management Commands:"
    echo "- Start: sudo systemctl start n8n"
    echo "- Stop: sudo systemctl stop n8n"
    echo "- Status: sudo systemctl status n8n"
    echo "- Logs: docker-compose -f docker-compose.prod.yml logs -f"
    echo ""
    echo "📈 Monitoring:"
    echo "- Health check: scripts/monitor.sh"
    echo "- Logs: tail -f /var/log/n8n-monitor.log"
    echo ""
    echo "🔒 Security:"
    echo "- SSL: ${ENABLE_SSL:-false}"
    echo "- Firewall: Ensure ports 80, 443, and 5678 are open"
    echo ""
}

# Main execution
main() {
    print_status "Starting production deployment..."
    
    check_permissions
    check_dependencies
    backup_data
    create_production_env
    create_production_docker_compose
    create_traefik_config
    create_systemd_service
    setup_monitoring
    deploy
    setup_ssl
    health_check
    show_deployment_info
    
    print_success "Production deployment completed successfully!"
}

# Run main function
main "$@"