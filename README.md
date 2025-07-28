# N8N Social Media Automation Platform

A comprehensive automation platform for LinkedIn and Instagram content management using n8n workflows. This system provides scheduled posting, cross-platform content adaptation, analytics tracking, and webhook-based manual posting capabilities.

## 🚀 Features

### LinkedIn Automation
- **Scheduled Posts**: Automated posting every 8 hours from Google Sheets
- **Content Processing**: Automatic content validation and optimization
- **Connection Management**: Track and manage LinkedIn connections
- **Analytics Logging**: Comprehensive post performance tracking
- **Manual Posting**: Webhook-based instant posting capability

### Instagram Automation
- **Smart Posting**: Automated posting every 12 hours with hashtag optimization
- **Story Creation**: Automatic Instagram story generation
- **Image Processing**: Automatic image download and posting
- **Hashtag Optimization**: Category-based hashtag selection
- **Daily Insights**: Automated analytics collection and reporting

### Cross-Platform Features
- **Unified Content Management**: Single source for multi-platform posting
- **Platform Adaptation**: Automatic content optimization for each platform
- **Performance Analytics**: Comprehensive cross-platform analytics
- **Telegram Notifications**: Real-time posting notifications
- **Webhook Integration**: Manual posting via API endpoints

## 📁 Project Structure

```
├── docker-compose.yml              # Docker services configuration
├── workflows/                      # N8N workflow definitions
│   ├── linkedin-automation.json    # LinkedIn-specific automation
│   ├── instagram-automation.json   # Instagram-specific automation
│   └── cross-platform-automation.json # Cross-platform workflows
├── credentials/                    # Credential templates and configs
│   └── credentials-template.json   # API credential templates
├── templates/                      # Setup templates and guides
│   └── google-sheets-templates.md  # Google Sheets setup guide
├── scripts/                       # Utility scripts
│   ├── setup.sh                   # Initial setup script
│   ├── backup.sh                  # Backup workflows and configs
│   └── webhook-test.sh             # Test webhook endpoints
└── README.md                       # This file
```

## 🛠️ Quick Setup

### Prerequisites
- Docker and Docker Compose installed
- Google account for Google Sheets integration
- LinkedIn Developer account
- Instagram/Facebook Developer account
- Telegram account (optional, for notifications)

### 1. Clone and Setup
```bash
# Clone the repository
git clone <repository-url>
cd n8n-social-automation

# Run the setup script
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### 2. Access N8N Interface
- Open browser and go to `http://localhost:5678`
- Login with default credentials:
  - Username: `admin`
  - Password: `admin123`

### 3. Configure Credentials
1. In N8N interface, go to Settings → Credentials
2. Use the templates in `credentials/credentials-template.json` to set up:
   - LinkedIn OAuth2 API
   - Instagram Basic Display API
   - Google Sheets OAuth2 API
   - Telegram API (optional)

### 4. Set Up Google Sheets
Follow the guide in `templates/google-sheets-templates.md` to create:
- Content source sheets
- Analytics tracking sheets
- Daily insights sheets

### 5. Import Workflows
1. In N8N interface, go to Workflows
2. Import the workflow files from the `workflows/` directory:
   - `linkedin-automation.json`
   - `instagram-automation.json`
   - `cross-platform-automation.json`

### 6. Update Configuration
Replace placeholder values in workflows:
- Google Sheet IDs
- Telegram chat IDs
- Any other platform-specific configurations

## 📊 Workflow Details

### LinkedIn Automation Workflow
**Trigger**: Every 8 hours
**Features**:
- Reads content from Google Sheets
- Validates and processes content (max 3000 characters)
- Posts to LinkedIn with professional hashtags
- Logs analytics data
- Tracks connections and profile data

**Webhook URL**: `http://localhost:5678/webhook/linkedin-webhook`

### Instagram Automation Workflow
**Trigger**: Every 12 hours
**Features**:
- Reads content and image URLs from Google Sheets
- Optimizes hashtags by category
- Downloads and processes images
- Posts to Instagram feed and stories
- Collects daily insights and analytics

**Webhook URL**: `http://localhost:5678/webhook/instagram-webhook`

### Cross-Platform Automation Workflow
**Trigger**: Every 6 hours
**Features**:
- Unified content source for multiple platforms
- Platform-specific content adaptation
- Simultaneous posting to LinkedIn and Instagram
- Performance analytics aggregation
- Telegram notifications

**Webhook URL**: `http://localhost:5678/webhook/cross-platform-webhook`

## 🔧 Manual Posting via Webhooks

### LinkedIn Manual Post
```bash
curl -X POST http://localhost:5678/webhook/linkedin-webhook \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Your LinkedIn post content here",
    "category": "business",
    "scheduled_time": "2024-01-15T10:00:00Z"
  }'
```

### Instagram Manual Post
```bash
curl -X POST http://localhost:5678/webhook/instagram-webhook \
  -H "Content-Type: application/json" \
  -d '{
    "caption": "Your Instagram caption with emojis 🚀",
    "image_url": "https://example.com/your-image.jpg",
    "category": "lifestyle"
  }'
```

### Cross-Platform Manual Post
```bash
curl -X POST http://localhost:5678/webhook/cross-platform-webhook \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Content that works for both platforms",
    "image_url": "https://example.com/image.jpg",
    "platforms": "linkedin,instagram",
    "category": "business"
  }'
```

## 📈 Analytics and Monitoring

### Google Sheets Analytics
- **LinkedIn Analytics**: Post content, engagement, timing
- **Instagram Analytics**: Hashtags, categories, performance
- **Cross-Platform Analytics**: Unified performance tracking
- **Daily Insights**: Follower growth, reach, impressions

### Telegram Notifications
Real-time notifications for:
- Successful posts
- Error alerts
- Performance summaries
- Daily insights reports

## 🛡️ Security Best Practices

1. **Change Default Credentials**: Update the default n8n admin password
2. **Secure API Keys**: Store credentials securely in n8n credential store
3. **Network Security**: Use HTTPS in production environments
4. **Backup Regularly**: Use the backup script to save configurations
5. **Monitor Access**: Review n8n access logs regularly

## 🔄 Maintenance Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Create backup
./scripts/backup.sh

# Test webhooks
./scripts/webhook-test.sh

# Update workflows
docker-compose restart n8n
```

## 🐛 Troubleshooting

### Common Issues

1. **Workflows not executing**
   - Check if workflows are active in n8n interface
   - Verify credentials are properly configured
   - Check Google Sheets permissions

2. **API Rate Limits**
   - LinkedIn: 100 posts per day
   - Instagram: Varies by account type
   - Adjust posting frequency if needed

3. **Image Upload Failures**
   - Verify image URLs are accessible
   - Check image format and size requirements
   - Ensure proper permissions

4. **Database Connection Issues**
   - Check PostgreSQL container status
   - Verify database credentials in docker-compose.yml
   - Restart PostgreSQL container if needed

### Log Analysis
```bash
# View n8n application logs
docker-compose logs -f n8n

# View PostgreSQL logs
docker-compose logs -f postgres

# View Redis logs
docker-compose logs -f redis
```

## 📚 Additional Resources

- [N8N Documentation](https://docs.n8n.io/)
- [LinkedIn API Documentation](https://docs.microsoft.com/en-us/linkedin/)
- [Instagram Basic Display API](https://developers.facebook.com/docs/instagram-basic-display-api)
- [Google Sheets API](https://developers.google.com/sheets/api)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is open source and available under the MIT License.

## 🆘 Support

For support and questions:
1. Check the troubleshooting section
2. Review n8n community forums
3. Create an issue in this repository
4. Consult the official documentation links

---

**Note**: This automation platform is designed for legitimate business use. Ensure compliance with each platform's terms of service and posting guidelines.