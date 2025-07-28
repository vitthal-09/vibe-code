#!/bin/bash

# N8N Backup Script
# This script creates backups of workflows, credentials, and configurations

set -e

BACKUP_DIR="backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="n8n_backup_${TIMESTAMP}"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

echo "📦 Creating N8N backup..."

# Create backup directory
mkdir -p "${BACKUP_PATH}"

# Backup workflows
if [ -d "workflows" ]; then
    echo "📁 Backing up workflows..."
    cp -r workflows "${BACKUP_PATH}/"
fi

# Backup credential templates (not actual credentials for security)
if [ -f "credentials/credentials-template.json" ]; then
    echo "🔐 Backing up credential templates..."
    mkdir -p "${BACKUP_PATH}/credentials"
    cp credentials/credentials-template.json "${BACKUP_PATH}/credentials/"
fi

# Backup docker-compose configuration
if [ -f "docker-compose.yml" ]; then
    echo "🐳 Backing up Docker configuration..."
    cp docker-compose.yml "${BACKUP_PATH}/"
fi

# Backup templates
if [ -d "templates" ]; then
    echo "📋 Backing up templates..."
    cp -r templates "${BACKUP_PATH}/"
fi

# Backup scripts
if [ -d "scripts" ]; then
    echo "📜 Backing up scripts..."
    cp -r scripts "${BACKUP_PATH}/"
fi

# Create backup info file
cat > "${BACKUP_PATH}/backup_info.txt" << EOF
N8N Social Media Automation Backup
Created: $(date)
Timestamp: ${TIMESTAMP}
Backup Name: ${BACKUP_NAME}

Contents:
- Workflows
- Credential templates
- Docker configuration
- Templates
- Scripts

Restore Instructions:
1. Stop N8N: docker-compose down
2. Copy workflows back: cp -r ${BACKUP_NAME}/workflows ./
3. Update configurations as needed
4. Restart N8N: docker-compose up -d
EOF

# Create compressed archive
echo "🗜️  Creating compressed archive..."
cd "${BACKUP_DIR}"
tar -czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}"
rm -rf "${BACKUP_NAME}"
cd ..

echo "✅ Backup completed successfully!"
echo "📁 Backup saved as: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
echo ""
echo "📊 Backup size: $(du -h ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz | cut -f1)"
echo "📅 Created: $(date)"

# Clean up old backups (keep last 10)
echo "🧹 Cleaning up old backups..."
cd "${BACKUP_DIR}"
ls -t n8n_backup_*.tar.gz | tail -n +11 | xargs rm -f 2>/dev/null || true
cd ..

echo "🎉 Backup process completed!"