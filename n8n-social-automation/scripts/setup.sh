#!/bin/bash

# n8n Social Media Automation Setup Script
# This script sets up the environment for running n8n workflows

set -e

echo "🚀 n8n Social Media Automation Setup"
echo "===================================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
   echo "❌ Please do not run this script as root"
   exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install dependencies
install_dependencies() {
    echo "📦 Installing dependencies..."
    
    # Check for Node.js
    if ! command_exists node; then
        echo "❌ Node.js is not installed. Please install Node.js 16+ first."
        echo "Visit: https://nodejs.org/"
        exit 1
    fi
    
    # Check Node.js version
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 16 ]; then
        echo "❌ Node.js version 16+ is required. Current version: $(node -v)"
        exit 1
    fi
    
    echo "✅ Node.js $(node -v) detected"
    
    # Check for npm
    if ! command_exists npm; then
        echo "❌ npm is not installed"
        exit 1
    fi
    
    echo "✅ npm $(npm -v) detected"
}

# Function to setup n8n
setup_n8n() {
    echo "🔧 Setting up n8n..."
    
    # Check if n8n is already installed
    if command_exists n8n; then
        echo "✅ n8n is already installed"
    else
        echo "📥 Installing n8n globally..."
        npm install n8n -g
    fi
    
    # Create n8n data directory
    mkdir -p ~/.n8n
    echo "✅ n8n data directory created"
}

# Function to setup database
setup_database() {
    echo "🗄️  Setting up database..."
    
    # Check if MySQL/MariaDB is installed
    if command_exists mysql; then
        echo "✅ MySQL detected"
        
        read -p "Enter MySQL root password: " -s MYSQL_ROOT_PASS
        echo
        
        # Create database and user
        mysql -u root -p"$MYSQL_ROOT_PASS" < ../database/schema.sql
        
        # Create application user
        mysql -u root -p"$MYSQL_ROOT_PASS" <<EOF
CREATE USER IF NOT EXISTS 'n8n_user'@'localhost' IDENTIFIED BY 'n8n_password';
GRANT ALL PRIVILEGES ON n8n_social_automation.* TO 'n8n_user'@'localhost';
FLUSH PRIVILEGES;
EOF
        
        echo "✅ Database setup complete"
    else
        echo "⚠️  MySQL not detected. Please install MySQL/MariaDB and run:"
        echo "   mysql -u root -p < database/schema.sql"
    fi
}

# Function to create environment file
create_env_file() {
    echo "📝 Creating environment file..."
    
    if [ -f "../.env" ]; then
        echo "⚠️  .env file already exists. Skipping..."
    else
        cat > ../.env <<EOF
# n8n Configuration
N8N_HOST=localhost
N8N_PORT=5678
N8N_PROTOCOL=http
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=changeme

# Database Configuration
DB_TYPE=mysqldb
DB_MYSQLDB_HOST=localhost
DB_MYSQLDB_PORT=3306
DB_MYSQLDB_USER=n8n_user
DB_MYSQLDB_PASSWORD=n8n_password
DB_MYSQLDB_DATABASE=n8n_social_automation

# Execution Configuration
EXECUTIONS_PROCESS=main
N8N_METRICS=true

# Timezone
GENERIC_TIMEZONE=America/New_York

# LinkedIn Configuration (Add your credentials)
LINKEDIN_CLIENT_ID=
LINKEDIN_CLIENT_SECRET=
LINKEDIN_REDIRECT_URI=http://localhost:5678/rest/oauth2-credential/callback

# Instagram Configuration (Add your credentials)
INSTAGRAM_APP_ID=
INSTAGRAM_APP_SECRET=
INSTAGRAM_ACCESS_TOKEN=
INSTAGRAM_BUSINESS_ACCOUNT_ID=
EOF
        
        echo "✅ .env file created"
        echo "⚠️  Please edit .env file and add your API credentials"
    fi
}

# Function to create systemd service
create_systemd_service() {
    echo "🔧 Creating systemd service..."
    
    read -p "Do you want to create a systemd service for n8n? (y/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo tee /etc/systemd/system/n8n.service > /dev/null <<EOF
[Unit]
Description=n8n - Workflow Automation Tool
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/.n8n
ExecStart=$(which n8n) start
Restart=on-failure
RestartSec=5
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=n8n
EnvironmentFile=$HOME/n8n-social-automation/.env

[Install]
WantedBy=multi-user.target
EOF
        
        sudo systemctl daemon-reload
        echo "✅ Systemd service created"
        echo "   To start: sudo systemctl start n8n"
        echo "   To enable on boot: sudo systemctl enable n8n"
    fi
}

# Function to import workflows
import_workflows() {
    echo "📥 Preparing workflows for import..."
    
    echo "✅ Workflows are ready in the workflows/ directory"
    echo "   1. Start n8n: n8n start"
    echo "   2. Open http://localhost:5678"
    echo "   3. Go to Workflows > Import"
    echo "   4. Import JSON files from workflows/ directory"
}

# Function to create Docker Compose file
create_docker_compose() {
    echo "🐳 Creating Docker Compose configuration..."
    
    cat > ../docker-compose.yml <<EOF
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=\${N8N_HOST}
      - N8N_PORT=5678
      - N8N_PROTOCOL=\${N8N_PROTOCOL}
      - NODE_ENV=production
      - DB_TYPE=mysqldb
      - DB_MYSQLDB_HOST=db
      - DB_MYSQLDB_PORT=3306
      - DB_MYSQLDB_USER=\${DB_MYSQLDB_USER}
      - DB_MYSQLDB_PASSWORD=\${DB_MYSQLDB_PASSWORD}
      - DB_MYSQLDB_DATABASE=\${DB_MYSQLDB_DATABASE}
      - N8N_BASIC_AUTH_ACTIVE=\${N8N_BASIC_AUTH_ACTIVE}
      - N8N_BASIC_AUTH_USER=\${N8N_BASIC_AUTH_USER}
      - N8N_BASIC_AUTH_PASSWORD=\${N8N_BASIC_AUTH_PASSWORD}
    volumes:
      - n8n_data:/home/node/.n8n
      - ./workflows:/workflows
    depends_on:
      - db
    networks:
      - n8n-network

  db:
    image: mysql:8.0
    container_name: n8n_mysql
    restart: unless-stopped
    environment:
      - MYSQL_ROOT_PASSWORD=rootpassword
      - MYSQL_DATABASE=\${DB_MYSQLDB_DATABASE}
      - MYSQL_USER=\${DB_MYSQLDB_USER}
      - MYSQL_PASSWORD=\${DB_MYSQLDB_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql
      - ./database/schema.sql:/docker-entrypoint-initdb.d/01-schema.sql
    ports:
      - "3306:3306"
    networks:
      - n8n-network

volumes:
  n8n_data:
  db_data:

networks:
  n8n-network:
    driver: bridge
EOF
    
    echo "✅ Docker Compose file created"
}

# Main setup flow
main() {
    echo "Starting setup process..."
    echo
    
    # Change to script directory
    cd "$(dirname "$0")"
    
    # Run setup steps
    install_dependencies
    setup_n8n
    create_env_file
    setup_database
    create_systemd_service
    import_workflows
    create_docker_compose
    
    echo
    echo "✅ Setup complete!"
    echo
    echo "📋 Next steps:"
    echo "1. Edit .env file with your API credentials"
    echo "2. Start n8n:"
    echo "   - Local: n8n start"
    echo "   - Docker: docker-compose up -d"
    echo "   - Systemd: sudo systemctl start n8n"
    echo "3. Access n8n at http://localhost:5678"
    echo "4. Import workflows from the workflows/ directory"
    echo "5. Configure credentials in n8n interface"
    echo
    echo "📚 Documentation available in docs/ directory"
    echo "🆘 For help, check the README.md file"
}

# Run main function
main