# n8n Social Media Automation Workflows

This repository contains n8n workflows for automating LinkedIn and Instagram activities, including content posting, engagement tracking, and analytics.

## 🚀 Features

### LinkedIn Automation
- **Auto-posting**: Schedule and publish posts with images/videos
- **Connection Management**: Auto-accept connections with filtering
- **Engagement Tracking**: Monitor post likes, comments, and shares
- **Profile Analytics**: Track profile views and post performance
- **Lead Generation**: Extract and store potential leads from searches

### Instagram Automation
- **Content Publishing**: Schedule posts, stories, and reels
- **Hashtag Research**: Analyze trending hashtags in your niche
- **Engagement Bot**: Auto-like and comment on relevant posts
- **Follower Analytics**: Track follower growth and engagement rates
- **Story Automation**: Auto-post stories with scheduling

## 📋 Prerequisites

- n8n instance (self-hosted or cloud)
- LinkedIn account with API access
- Instagram Business/Creator account
- Facebook Graph API access (for Instagram)
- PostgreSQL or MySQL database (for data storage)

## 🛠️ Setup Instructions

### 1. n8n Installation

If you haven't installed n8n yet:

```bash
# Using npm
npm install n8n -g

# Using Docker
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n
```

### 2. Required Credentials

#### LinkedIn Credentials
1. Create a LinkedIn App at https://www.linkedin.com/developers/
2. Get your Client ID and Client Secret
3. Set up OAuth 2.0 redirect URI

#### Instagram Credentials
1. Create a Facebook App at https://developers.facebook.com/
2. Add Instagram Basic Display or Instagram Graph API
3. Get your Access Token

### 3. Database Setup

Create a database for storing automation data:

```sql
CREATE DATABASE n8n_social_automation;
```

### 4. Import Workflows

1. Open n8n interface (default: http://localhost:5678)
2. Go to Workflows > Import
3. Import the JSON files from the `workflows/` directory

## 📁 Project Structure

```
n8n-social-automation/
├── workflows/
│   ├── linkedin/
│   │   ├── linkedin-auto-poster.json
│   │   ├── linkedin-connection-manager.json
│   │   ├── linkedin-analytics.json
│   │   └── linkedin-lead-generator.json
│   └── instagram/
│       ├── instagram-content-publisher.json
│       ├── instagram-hashtag-research.json
│       ├── instagram-engagement-bot.json
│       └── instagram-analytics.json
├── config/
│   ├── credentials-template.json
│   └── webhook-endpoints.json
├── database/
│   ├── schema.sql
│   └── seed-data.sql
├── scripts/
│   ├── setup.sh
│   └── backup-workflows.sh
└── docs/
    ├── linkedin-guide.md
    └── instagram-guide.md
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file:

```env
N8N_HOST=localhost
N8N_PORT=5678
N8N_PROTOCOL=http
DB_TYPE=postgres
DB_HOST=localhost
DB_PORT=5432
DB_USER=n8n_user
DB_PASSWORD=your_password
DB_DATABASE=n8n_social_automation
```

### Webhook URLs

Configure webhook endpoints for real-time triggers:

- LinkedIn webhook: `http://your-domain.com/webhook/linkedin`
- Instagram webhook: `http://your-domain.com/webhook/instagram`

## 📊 Workflow Descriptions

### LinkedIn Workflows

1. **Auto-Poster**: Publishes scheduled content from a content calendar
2. **Connection Manager**: Manages connection requests with custom filters
3. **Analytics Tracker**: Collects and stores engagement metrics
4. **Lead Generator**: Searches and extracts potential leads

### Instagram Workflows

1. **Content Publisher**: Schedules and publishes various content types
2. **Hashtag Researcher**: Analyzes hashtag performance and trends
3. **Engagement Bot**: Interacts with target audience posts
4. **Analytics Dashboard**: Tracks growth and engagement metrics

## 🚦 Usage Examples

### Schedule a LinkedIn Post

```javascript
// Trigger: Schedule Trigger (Daily at 9 AM)
// Node 1: Get content from database
// Node 2: LinkedIn API - Create post
// Node 3: Store post ID for analytics
```

### Auto-engage on Instagram

```javascript
// Trigger: Interval (Every 30 minutes)
// Node 1: Search posts by hashtag
// Node 2: Filter by engagement criteria
// Node 3: Like and comment
// Node 4: Log activity
```

## ⚠️ Important Notes

- **Rate Limits**: Both platforms have API rate limits. Workflows include rate limiting logic.
- **Compliance**: Ensure your automation complies with platform terms of service.
- **Security**: Never commit credentials to version control.
- **Testing**: Test workflows in a sandbox environment first.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

- n8n Documentation: https://docs.n8n.io/
- LinkedIn API Docs: https://docs.microsoft.com/en-us/linkedin/
- Instagram API Docs: https://developers.facebook.com/docs/instagram-api/

## 🔄 Updates

- **v1.0.0** - Initial release with basic automation workflows
- **v1.1.0** - Added analytics and reporting features
- **v1.2.0** - Enhanced error handling and retry logic