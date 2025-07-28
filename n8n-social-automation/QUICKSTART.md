# Quick Start Guide - n8n Social Media Automation

Get your LinkedIn and Instagram automation up and running in 15 minutes!

## 🚀 Prerequisites Checklist

- [ ] Node.js 16+ installed
- [ ] MySQL or PostgreSQL installed
- [ ] LinkedIn Developer account
- [ ] Facebook Developer account (for Instagram)
- [ ] Instagram Business/Creator account

## 📋 Step 1: Clone and Setup

```bash
# Clone the repository (or download the files)
cd n8n-social-automation

# Run the setup script
cd scripts
./setup.sh
```

## 🔑 Step 2: Configure API Credentials

### LinkedIn Setup
1. Go to https://www.linkedin.com/developers/
2. Create a new app
3. Get your Client ID and Client Secret
4. Add redirect URL: `http://localhost:5678/rest/oauth2-credential/callback`

### Instagram Setup
1. Go to https://developers.facebook.com/
2. Create a new app
3. Add Instagram Basic Display or Instagram Graph API
4. Get your App ID, App Secret, and Access Token

## 🔧 Step 3: Environment Configuration

```bash
# Copy the example environment file
cp .env.example .env

# Edit with your credentials
nano .env
```

Update these values in `.env`:
- `LINKEDIN_CLIENT_ID`
- `LINKEDIN_CLIENT_SECRET`
- `INSTAGRAM_APP_ID`
- `INSTAGRAM_APP_SECRET`
- `INSTAGRAM_ACCESS_TOKEN`
- `INSTAGRAM_BUSINESS_ACCOUNT_ID`

## 🐳 Step 4: Start with Docker (Recommended)

```bash
# Start all services
docker-compose up -d

# Check logs
docker-compose logs -f n8n
```

## 💻 Step 5: Alternative - Start Locally

```bash
# Install n8n globally
npm install n8n -g

# Start n8n
n8n start
```

## 🌐 Step 6: Access n8n

1. Open your browser: http://localhost:5678
2. Login with credentials from `.env`:
   - Username: `admin` (default)
   - Password: `changeme` (change this!)

## 📥 Step 7: Import Workflows

1. In n8n, click "Workflows" → "Import"
2. Import these workflow files:
   - `workflows/linkedin/linkedin-auto-poster.json`
   - `workflows/linkedin/linkedin-analytics.json`
   - `workflows/instagram/instagram-content-publisher.json`

## 🔐 Step 8: Configure Credentials in n8n

### Add Database Credentials
1. Go to Credentials → New
2. Select "MySQL" or "PostgreSQL"
3. Enter your database details

### Add LinkedIn Credentials
1. Go to Credentials → New
2. Select "LinkedIn OAuth2 API"
3. Enter Client ID and Secret
4. Click "Connect My Account"

### Add Instagram Credentials
1. Go to Credentials → New
2. Select "HTTP Request" (for Graph API)
3. Configure with your access token

## 📅 Step 9: Add Your First Content

### Using SQL
```sql
-- Add a LinkedIn post
INSERT INTO content_calendar (
    platform, 
    content_type, 
    content, 
    scheduled_time, 
    status
) VALUES (
    'linkedin',
    'post',
    'Excited to share our automation journey! 🚀',
    NOW() + INTERVAL 1 HOUR,
    'pending'
);

-- Add an Instagram post
INSERT INTO content_calendar (
    platform,
    content_type,
    caption,
    media_url,
    hashtags,
    scheduled_time,
    status
) VALUES (
    'instagram',
    'post',
    'Check out our latest automation tools!',
    'https://example.com/image.jpg',
    '["automation", "n8n", "workflow"]',
    NOW() + INTERVAL 2 HOUR,
    'pending'
);
```

## ✅ Step 10: Activate Workflows

1. Open each imported workflow
2. Click the toggle to activate
3. Workflows will now run on schedule!

## 🎯 Quick Test

### Test LinkedIn Posting
```bash
# Trigger workflow manually
curl -X POST http://localhost:5678/webhook-test/linkedin-auto-poster
```

### Test Instagram Posting
```bash
# Trigger workflow manually
curl -X POST http://localhost:5678/webhook-test/instagram-content-publisher
```

## 📊 Monitor Performance

Check automation logs:
```sql
SELECT * FROM automation_logs ORDER BY created_at DESC LIMIT 10;
```

Check content performance:
```sql
SELECT * FROM content_performance WHERE platform = 'linkedin';
```

## 🆘 Troubleshooting

### Common Issues

1. **Database Connection Failed**
   ```bash
   # Check MySQL is running
   sudo systemctl status mysql
   
   # Test connection
   mysql -u n8n_user -p n8n_social_automation
   ```

2. **n8n Won't Start**
   ```bash
   # Check port availability
   lsof -i :5678
   
   # Check logs
   docker-compose logs n8n
   ```

3. **API Authentication Failed**
   - Verify credentials in `.env`
   - Check API permissions in developer consoles
   - Regenerate tokens if expired

## 🎉 Success Checklist

- [ ] n8n is running at http://localhost:5678
- [ ] Database is connected
- [ ] LinkedIn credentials configured
- [ ] Instagram credentials configured
- [ ] Workflows imported and activated
- [ ] First test post scheduled

## 📚 Next Steps

1. Read the full documentation:
   - `docs/linkedin-guide.md`
   - `docs/instagram-guide.md`

2. Customize workflows for your needs

3. Set up monitoring and alerts

4. Scale with additional workflows

## 💬 Need Help?

- Check logs: `docker-compose logs`
- Database issues: `mysql -u root -p`
- n8n community: https://community.n8n.io/

---

**Happy Automating! 🚀**