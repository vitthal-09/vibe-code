# Social Media Automation Setup Guide

This guide will walk you through setting up the LinkedIn and Instagram automation workflows using n8n.

## Prerequisites

Before you begin, ensure you have the following:

- **Docker and Docker Compose** installed on your system
- **LinkedIn Developer Account** with API access
- **Instagram Business Account** with Graph API access
- **Slack Workspace** (optional, for notifications)

## Step 1: Install Dependencies

### Install Docker
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose

# CentOS/RHEL
sudo yum install docker docker-compose

# macOS
brew install docker docker-compose
```

### Verify Installation
```bash
docker --version
docker-compose --version
```

## Step 2: Clone and Setup

1. **Clone the repository:**
```bash
git clone <your-repo-url>
cd social-media-automation
```

2. **Make scripts executable:**
```bash
chmod +x scripts/setup.sh
chmod +x scripts/deploy.sh
```

3. **Run the setup script:**
```bash
./scripts/setup.sh
```

## Step 3: Configure API Credentials

### LinkedIn API Setup

1. **Create a LinkedIn App:**
   - Go to [LinkedIn Developers](https://www.linkedin.com/developers/)
   - Click "Create App"
   - Fill in the required information
   - Note your Client ID and Client Secret

2. **Configure OAuth 2.0:**
   - Add redirect URLs: `http://localhost:5678/callback`
   - Request necessary permissions:
     - `r_liteprofile`
     - `r_emailaddress`
     - `w_member_social`
     - `rw_organization_admin`

3. **Update environment variables:**
```bash
# Edit .env file
LINKEDIN_CLIENT_ID=your_linkedin_client_id
LINKEDIN_CLIENT_SECRET=your_linkedin_client_secret
```

### Instagram API Setup

1. **Create a Facebook App:**
   - Go to [Facebook Developers](https://developers.facebook.com/)
   - Create a new app
   - Add Instagram Basic Display product

2. **Configure Instagram Basic Display:**
   - Add Instagram Basic Display to your app
   - Configure OAuth redirect URIs
   - Generate access tokens

3. **Get Instagram Business Account ID:**
   - Connect your Instagram Business account
   - Note the Business Account ID

4. **Update environment variables:**
```bash
# Edit .env file
INSTAGRAM_ACCESS_TOKEN=your_instagram_access_token
INSTAGRAM_BUSINESS_ACCOUNT_ID=your_instagram_business_account_id
```

## Step 4: Import Workflows

1. **Access n8n:**
   - Open your browser and go to `http://localhost:5678`
   - Login with the credentials from the setup script

2. **Import Workflows:**
   - Go to Settings → Import/Export
   - Import each workflow file from the `workflows/` directory:
     - `linkedin-automation.json`
     - `instagram-automation.json`
     - `cross-platform-sync.json`

3. **Configure Credentials:**
   - Go to Settings → Credentials
   - Add your LinkedIn and Instagram API credentials
   - Test the connections

## Step 5: Configure Workflows

### LinkedIn Automation Workflow

1. **Open the LinkedIn workflow**
2. **Configure the scheduler:**
   - Set your preferred posting times
   - Adjust frequency (daily/weekly)

3. **Set up content sources:**
   - Configure content calendar integration
   - Set up content templates

4. **Configure notifications:**
   - Add your Slack webhook URL
   - Set up email notifications

### Instagram Automation Workflow

1. **Open the Instagram workflow**
2. **Configure posting schedule:**
   - Set optimal posting times
   - Configure story posting

3. **Set up hashtag strategy:**
   - Configure hashtag categories
   - Set hashtag limits

4. **Configure content sources:**
   - Set up image sources
   - Configure caption templates

### Cross-Platform Sync Workflow

1. **Open the cross-platform sync workflow**
2. **Configure sync settings:**
   - Set sync frequency
   - Configure content optimization rules

3. **Set up content filters:**
   - Define what content to sync
   - Configure platform-specific rules

## Step 6: Test the Workflows

### Test LinkedIn Workflow

1. **Manual Test:**
   - Trigger the workflow manually
   - Check if posts are created
   - Verify engagement tracking

2. **Scheduled Test:**
   - Wait for the scheduled time
   - Monitor automatic posting
   - Check notifications

### Test Instagram Workflow

1. **Manual Test:**
   - Trigger the workflow manually
   - Verify post creation
   - Check hashtag generation

2. **Scheduled Test:**
   - Monitor scheduled posts
   - Verify story creation
   - Check analytics

### Test Cross-Platform Sync

1. **Create test content:**
   - Post content on LinkedIn
   - Post content on Instagram

2. **Monitor sync:**
   - Check if content is cross-posted
   - Verify optimization rules
   - Monitor sync reports

## Step 7: Monitor and Optimize

### Set Up Monitoring

1. **Enable health checks:**
   - Monitor workflow execution
   - Set up alerts for failures

2. **Track performance:**
   - Monitor engagement rates
   - Track posting success rates
   - Analyze content performance

### Optimize Settings

1. **Adjust posting times:**
   - Analyze when your audience is most active
   - Update optimal posting times

2. **Optimize content:**
   - Review top-performing content
   - Adjust content templates
   - Update hashtag strategies

3. **Fine-tune automation:**
   - Adjust sync frequency
   - Optimize content filters
   - Update notification settings

## Troubleshooting

### Common Issues

1. **API Rate Limits:**
   - Check API usage limits
   - Implement rate limiting
   - Monitor API quotas

2. **Authentication Errors:**
   - Verify API credentials
   - Check token expiration
   - Re-authenticate if needed

3. **Content Failures:**
   - Check content format requirements
   - Verify image URLs
   - Test content manually

### Debug Workflows

1. **Enable debug mode:**
   - Set log level to debug
   - Monitor execution logs
   - Check node outputs

2. **Test individual nodes:**
   - Execute nodes manually
   - Verify data flow
   - Check error messages

3. **Review logs:**
   - Check n8n logs
   - Monitor system logs
   - Review error reports

## Security Considerations

### API Security

1. **Secure credentials:**
   - Use environment variables
   - Encrypt sensitive data
   - Rotate tokens regularly

2. **Access control:**
   - Limit API permissions
   - Monitor API usage
   - Implement rate limiting

### Data Protection

1. **GDPR compliance:**
   - Implement data retention policies
   - Provide data export capabilities
   - Handle user consent

2. **Data encryption:**
   - Encrypt stored data
   - Secure data transmission
   - Implement access controls

## Production Deployment

### Deploy to Production

1. **Run deployment script:**
```bash
./scripts/deploy.sh
```

2. **Configure production settings:**
   - Update environment variables
   - Set up SSL certificates
   - Configure monitoring

3. **Set up backups:**
   - Configure automated backups
   - Test backup restoration
   - Monitor backup health

### Monitor Production

1. **Set up monitoring:**
   - Configure health checks
   - Set up alerting
   - Monitor performance

2. **Regular maintenance:**
   - Update dependencies
   - Review logs
   - Optimize performance

## Support and Resources

### Documentation

- [n8n Documentation](https://docs.n8n.io/)
- [LinkedIn API Documentation](https://developer.linkedin.com/)
- [Instagram API Documentation](https://developers.facebook.com/docs/instagram-api/)

### Community

- [n8n Community](https://community.n8n.io/)
- [LinkedIn Developer Community](https://www.linkedin.com/developers/)
- [Facebook Developer Community](https://developers.facebook.com/community/)

### Getting Help

1. **Check logs:**
   - Review error messages
   - Check system logs
   - Monitor workflow execution

2. **Search documentation:**
   - Review API documentation
   - Check n8n guides
   - Search community forums

3. **Contact support:**
   - Open GitHub issues
   - Contact API providers
   - Reach out to community

## Next Steps

After setting up your automation workflows:

1. **Scale your automation:**
   - Add more content sources
   - Integrate additional platforms
   - Implement advanced analytics

2. **Optimize performance:**
   - Analyze engagement data
   - A/B test content strategies
   - Optimize posting schedules

3. **Expand functionality:**
   - Add AI-powered content generation
   - Implement advanced analytics
   - Create custom integrations

Remember to regularly review and update your automation settings based on performance data and platform changes.