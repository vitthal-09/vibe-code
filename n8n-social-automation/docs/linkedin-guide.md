# LinkedIn Automation Guide

This guide covers the setup and usage of LinkedIn automation workflows in n8n.

## Table of Contents
- [Prerequisites](#prerequisites)
- [LinkedIn App Setup](#linkedin-app-setup)
- [Workflow Configuration](#workflow-configuration)
- [Available Workflows](#available-workflows)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Prerequisites

1. LinkedIn account with appropriate permissions
2. LinkedIn Developer account
3. Company page (for company-related posts)
4. n8n instance running with database configured

## LinkedIn App Setup

### 1. Create LinkedIn App

1. Go to [LinkedIn Developers](https://www.linkedin.com/developers/)
2. Click "Create App"
3. Fill in the required information:
   - App name: "n8n Social Automation"
   - LinkedIn Page: Select your company page
   - Privacy policy URL: Your privacy policy
   - App logo: Upload a logo
4. Click "Create app"

### 2. Configure OAuth Settings

1. In your app dashboard, go to "Auth" tab
2. Add Authorized redirect URLs:
   ```
   http://localhost:5678/rest/oauth2-credential/callback
   https://your-domain.com/rest/oauth2-credential/callback
   ```
3. Note down:
   - Client ID
   - Client Secret

### 3. Request API Access

1. Go to "Products" tab
2. Request access to:
   - Share on LinkedIn
   - Sign In with LinkedIn
   - Marketing Developer Platform (if needed)

### 4. Configure Scopes

Required OAuth 2.0 scopes:
- `r_liteprofile` - Read member's lite profile
- `w_member_social` - Post on behalf of member
- `r_organization_social` - Read organization posts
- `w_organization_social` - Post on behalf of organization

## Workflow Configuration

### Setting up LinkedIn Credentials in n8n

1. Open n8n interface
2. Go to Credentials > New
3. Select "LinkedIn OAuth2 API"
4. Enter:
   - Client ID
   - Client Secret
   - Callback URL
5. Click "Connect My Account"
6. Authorize the app

### Database Connection

Ensure your PostgreSQL/MySQL credentials are configured:
1. Go to Credentials > New
2. Select "Postgres" or "MySQL"
3. Enter database connection details

## Available Workflows

### 1. LinkedIn Auto-Poster

**Purpose**: Automatically publishes scheduled content from your content calendar.

**Features**:
- Scheduled posting every 2 hours
- Support for text posts and media (images/videos)
- Automatic status updates in database
- Error handling and retry logic

**Configuration**:
```json
{
  "schedule": "0 */2 * * *",
  "batch_size": 5,
  "platforms": ["linkedin"]
}
```

**Usage**:
1. Add content to `content_calendar` table
2. Set `platform` = 'linkedin'
3. Set `scheduled_time` to desired publish time
4. Workflow will automatically pick up and publish

### 2. LinkedIn Connection Manager

**Purpose**: Manages connection requests and tracks professional network.

**Workflow Structure**:
```
Webhook Trigger → Get New Connections → Filter by Criteria → Accept/Store → Update Database
```

**Features**:
- Auto-accept connections based on criteria
- Store connection details for CRM
- Tag connections for segmentation
- Lead scoring integration

### 3. LinkedIn Analytics Tracker

**Purpose**: Collects and stores post performance metrics.

**Metrics Tracked**:
- Impressions
- Clicks
- Likes
- Comments
- Shares
- Engagement rate

**Schedule**: Runs every 6 hours to update metrics

### 4. LinkedIn Lead Generator

**Purpose**: Searches for potential leads and extracts profile information.

**Search Criteria**:
- Job titles
- Industries
- Company size
- Location
- Keywords

**Output**: Stores leads in `linkedin_connections` table with lead scores

## Best Practices

### Content Strategy

1. **Posting Frequency**
   - Personal profiles: 1-2 posts per day
   - Company pages: 3-5 posts per week
   - Avoid posting on weekends

2. **Optimal Posting Times**
   - Tuesday-Thursday: 8-10 AM, 12 PM, 5-6 PM
   - Industry-specific adjustments recommended

3. **Content Mix**
   - 40% Industry insights
   - 30% Company updates
   - 20% Thought leadership
   - 10% Promotional content

### API Rate Limits

LinkedIn enforces strict rate limits:
- **Daily limits**: Vary by endpoint
- **Throttling**: 100 requests per day for some endpoints
- **Best practice**: Implement exponential backoff

### Compliance

1. **Terms of Service**
   - No spam or unsolicited messages
   - Authentic engagement only
   - Respect user privacy

2. **Content Guidelines**
   - Professional content only
   - No misleading information
   - Proper attribution for shared content

## Troubleshooting

### Common Issues

#### 1. Authentication Errors
```
Error: "Invalid authentication credentials"
```
**Solution**: 
- Refresh OAuth token
- Check if app permissions are still valid
- Verify redirect URLs match

#### 2. Rate Limit Exceeded
```
Error: "429 Too Many Requests"
```
**Solution**:
- Implement delay between requests
- Reduce batch size
- Check daily limits in LinkedIn dashboard

#### 3. Post Failed to Publish
```
Error: "Content validation failed"
```
**Solution**:
- Check content length (3000 chars for text, 1300 for companies)
- Verify media format (JPG, PNG, GIF for images)
- Ensure media URLs are accessible

### Debug Mode

Enable debug logging in n8n:
```javascript
// In Function node
console.log('LinkedIn API Request:', $input.all());
console.log('Response:', $json);
```

### Webhook Testing

Test webhooks using:
```bash
curl -X POST http://localhost:5678/webhook/linkedin-test \
  -H "Content-Type: application/json" \
  -d '{"event":"connection_request","data":{"profile_id":"123"}}'
```

## Advanced Features

### Dynamic Content Generation

```javascript
// Function node for dynamic content
const templates = [
  "🚀 {company} just announced {achievement}",
  "📊 Industry insight: {statistic} shows {trend}",
  "💡 Tip of the day: {advice}"
];

const selectedTemplate = templates[Math.floor(Math.random() * templates.length)];
const content = selectedTemplate
  .replace('{company}', $json.company_name)
  .replace('{achievement}', $json.achievement)
  .replace('{statistic}', $json.statistic)
  .replace('{trend}', $json.trend)
  .replace('{advice}', $json.advice);

return { content };
```

### A/B Testing Posts

Track performance of different content variations:
```sql
-- Add to content_calendar table
ALTER TABLE content_calendar ADD COLUMN variant CHAR(1) DEFAULT 'A';
ALTER TABLE content_calendar ADD COLUMN test_group VARCHAR(50);
```

### Integration with CRM

Sync LinkedIn connections with your CRM:
```javascript
// Function node
const connection = $json;
const crmPayload = {
  firstName: connection.firstName,
  lastName: connection.lastName,
  company: connection.company,
  title: connection.headline,
  linkedinUrl: connection.profileUrl,
  source: 'LinkedIn',
  leadScore: connection.leadScore
};

// Send to CRM webhook
$workflow.webhook.post('https://your-crm.com/api/leads', crmPayload);
```

## Monitoring and Reporting

### Key Metrics to Track

1. **Engagement Metrics**
   - Average engagement rate
   - Best performing content types
   - Optimal posting times

2. **Growth Metrics**
   - Follower growth rate
   - Connection acceptance rate
   - Lead conversion rate

3. **Content Performance**
   - Top performing posts
   - Hashtag effectiveness
   - Media vs text performance

### SQL Queries for Reports

```sql
-- Weekly performance summary
SELECT 
    DATE_FORMAT(published_at, '%Y-%u') as week,
    COUNT(*) as posts_published,
    AVG(total_likes) as avg_likes,
    AVG(total_comments) as avg_comments,
    AVG(total_shares) as avg_shares,
    SUM(total_impressions) as total_impressions
FROM content_performance
WHERE platform = 'linkedin'
GROUP BY week
ORDER BY week DESC;

-- Top performing hashtags
SELECT 
    hashtag,
    usage_count,
    avg_engagement_rate,
    total_reach
FROM hashtag_performance
WHERE platform = 'linkedin'
ORDER BY avg_engagement_rate DESC
LIMIT 20;
```

## Resources

- [LinkedIn API Documentation](https://docs.microsoft.com/en-us/linkedin/)
- [LinkedIn Best Practices](https://www.linkedin.com/help/linkedin/answer/34932)
- [n8n LinkedIn Node Documentation](https://docs.n8n.io/nodes/n8n-nodes-base.linkedin/)
- [OAuth 2.0 Guide](https://www.linkedin.com/developers/apps/auth)