# API Documentation

This document provides detailed information about the APIs used in the LinkedIn and Instagram automation workflows.

## Table of Contents

1. [LinkedIn API](#linkedin-api)
2. [Instagram API](#instagram-api)
3. [n8n Webhooks](#n8n-webhooks)
4. [Error Handling](#error-handling)
5. [Rate Limiting](#rate-limiting)
6. [Authentication](#authentication)

## LinkedIn API

### Overview

The LinkedIn API is used for posting content, tracking engagement, and managing connections. The automation workflows use the LinkedIn Marketing API v2.

### Authentication

#### OAuth 2.0 Flow

```javascript
// OAuth 2.0 Configuration
{
  "clientId": "your_linkedin_client_id",
  "clientSecret": "your_linkedin_client_secret",
  "redirectUri": "http://localhost:5678/callback",
  "scope": [
    "r_liteprofile",
    "r_emailaddress",
    "w_member_social",
    "rw_organization_admin"
  ]
}
```

#### Required Permissions

| Permission | Description | Required For |
|------------|-------------|--------------|
| `r_liteprofile` | Read basic profile information | Profile data |
| `r_emailaddress` | Read email address | User identification |
| `w_member_social` | Post content to LinkedIn | Content posting |
| `rw_organization_admin` | Manage organization content | Company pages |

### Endpoints

#### 1. Create Post

**Endpoint:** `POST /v2/ugcPosts`

**Headers:**
```http
X-Restli-Protocol-Version: 2.0.0
Content-Type: application/json
Authorization: Bearer {access_token}
```

**Request Body:**
```json
{
  "author": "urn:li:person:{authorId}",
  "lifecycleState": "PUBLISHED",
  "specificContent": {
    "com.linkedin.ugc.ShareContent": {
      "shareCommentary": {
        "text": "Your post content here"
      },
      "shareMediaCategory": "NONE"
    }
  },
  "visibility": {
    "com.linkedin.ugc.MemberNetworkVisibility": "PUBLIC"
  }
}
```

**Response:**
```json
{
  "id": "urn:li:activity:123456789",
  "status": 201
}
```

#### 2. Get Engagement Metrics

**Endpoint:** `GET /v2/socialMetrics/{postId}`

**Headers:**
```http
X-Restli-Protocol-Version: 2.0.0
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "totalShareStatistics": {
    "likeCount": 45,
    "commentCount": 12,
    "shareCount": 8,
    "impressionCount": 1250
  }
}
```

#### 3. Get Connections

**Endpoint:** `GET /v2/connections`

**Headers:**
```http
X-Restli-Protocol-Version: 2.0.0
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "elements": [
    {
      "profileId": "urn:li:person:123456",
      "createdTime": 1640995200000,
      "firstName": "John",
      "lastName": "Doe"
    }
  ]
}
```

#### 4. Send Connection Request

**Endpoint:** `POST /v2/invitations`

**Headers:**
```http
X-Restli-Protocol-Version: 2.0.0
Content-Type: application/json
Authorization: Bearer {access_token}
```

**Request Body:**
```json
{
  "invitee": {
    "com.linkedin.voyager.growth.invitation.Invitee": {
      "profile": "urn:li:person:{profileId}"
    }
  },
  "message": "Hi! I'd love to connect with you on LinkedIn."
}
```

### Error Codes

| Code | Description | Solution |
|------|-------------|----------|
| 400 | Bad Request | Check request format |
| 401 | Unauthorized | Refresh access token |
| 403 | Forbidden | Check permissions |
| 429 | Rate Limited | Implement backoff |
| 500 | Server Error | Retry later |

## Instagram API

### Overview

The Instagram API is used for posting content, managing stories, and tracking engagement. The automation workflows use the Instagram Graph API.

### Authentication

#### Access Token

```javascript
// Instagram API Configuration
{
  "accessToken": "your_instagram_access_token",
  "businessAccountId": "your_instagram_business_account_id",
  "apiVersion": "v18.0"
}
```

#### Required Permissions

| Permission | Description | Required For |
|------------|-------------|--------------|
| `instagram_basic` | Read profile and posts | Profile data |
| `instagram_content_publish` | Publish content | Content posting |
| `instagram_manage_comments` | Manage comments | Engagement |
| `instagram_manage_insights` | Read insights | Analytics |

### Endpoints

#### 1. Create Media Object

**Endpoint:** `POST /v18.0/{business-account-id}/media`

**Headers:**
```http
Content-Type: application/json
```

**Request Body:**
```json
{
  "image_url": "https://example.com/image.jpg",
  "caption": "Your post caption with hashtags",
  "access_token": "your_access_token"
}
```

**Response:**
```json
{
  "id": "17841405793087218"
}
```

#### 2. Publish Media

**Endpoint:** `POST /v18.0/{media-id}/publish`

**Headers:**
```http
Content-Type: application/json
```

**Request Body:**
```json
{
  "access_token": "your_access_token"
}
```

**Response:**
```json
{
  "id": "17841405793087218"
}
```

#### 3. Get Insights

**Endpoint:** `GET /v18.0/{business-account-id}/insights`

**Query Parameters:**
```
metric=impressions,reach,profile_views,follower_count
period=day
access_token=your_access_token
```

**Response:**
```json
{
  "data": [
    {
      "name": "impressions",
      "values": [
        {
          "value": 1250,
          "end_time": "2024-01-01T00:00:00+0000"
        }
      ]
    }
  ]
}
```

#### 4. Get Media

**Endpoint:** `GET /v18.0/{business-account-id}/media`

**Query Parameters:**
```
fields=id,media_type,media_url,thumbnail_url,permalink,timestamp,like_count,comments_count
access_token=your_access_token
```

**Response:**
```json
{
  "data": [
    {
      "id": "17841405793087218",
      "media_type": "IMAGE",
      "media_url": "https://example.com/image.jpg",
      "permalink": "https://www.instagram.com/p/ABC123/",
      "timestamp": "2024-01-01T12:00:00+0000",
      "like_count": 45,
      "comments_count": 12
    }
  ]
}
```

#### 5. Create Story

**Endpoint:** `POST /v18.0/{business-account-id}/media`

**Headers:**
```http
Content-Type: application/json
```

**Request Body:**
```json
{
  "media_type": "STORY",
  "image_url": "https://example.com/story.jpg",
  "access_token": "your_access_token"
}
```

### Error Codes

| Code | Description | Solution |
|------|-------------|----------|
| 400 | Bad Request | Check request format |
| 401 | Unauthorized | Check access token |
| 403 | Forbidden | Check permissions |
| 429 | Rate Limited | Implement backoff |
| 500 | Server Error | Retry later |

## n8n Webhooks

### Overview

n8n webhooks are used to trigger workflows and receive data from external services.

### Webhook Configuration

#### LinkedIn Webhook

**URL:** `https://your-n8n-instance.com/webhook/linkedin`

**Headers:**
```http
Content-Type: application/json
X-LinkedIn-Signature: {signature}
```

**Payload:**
```json
{
  "event": "post_created",
  "post_id": "urn:li:activity:123456789",
  "author_id": "urn:li:person:123456",
  "content": "Post content",
  "timestamp": "2024-01-01T12:00:00Z"
}
```

#### Instagram Webhook

**URL:** `https://your-n8n-instance.com/webhook/instagram`

**Headers:**
```http
Content-Type: application/json
X-Hub-Signature: {signature}
```

**Payload:**
```json
{
  "object": "instagram",
  "entry": [
    {
      "id": "17841405793087218",
      "time": 1640995200,
      "messaging": [
        {
          "sender": {
            "id": "123456789"
          },
          "recipient": {
            "id": "987654321"
          },
          "timestamp": 1640995200000,
          "message": {
            "mid": "mid.123456789",
            "text": "Hello!"
          }
        }
      ]
    }
  ]
}
```

### Webhook Verification

#### LinkedIn Webhook Verification

```javascript
// Verify LinkedIn webhook signature
function verifyLinkedInWebhook(payload, signature, secret) {
  const expectedSignature = crypto
    .createHmac('sha256', secret)
    .update(JSON.stringify(payload))
    .digest('hex');
  
  return signature === expectedSignature;
}
```

#### Instagram Webhook Verification

```javascript
// Verify Instagram webhook signature
function verifyInstagramWebhook(payload, signature, appSecret) {
  const expectedSignature = crypto
    .createHmac('sha256', appSecret)
    .update(JSON.stringify(payload))
    .digest('hex');
  
  return signature === expectedSignature;
}
```

## Error Handling

### Common Error Patterns

#### 1. Authentication Errors

```javascript
// Handle authentication errors
if (response.status === 401) {
  // Refresh access token
  await refreshAccessToken();
  // Retry request
  return await makeRequest();
}
```

#### 2. Rate Limiting

```javascript
// Handle rate limiting
if (response.status === 429) {
  const retryAfter = response.headers.get('Retry-After');
  await delay(parseInt(retryAfter) * 1000);
  return await makeRequest();
}
```

#### 3. Content Validation

```javascript
// Validate content before posting
function validateContent(content, platform) {
  const errors = [];
  
  if (platform === 'linkedin') {
    if (content.length > 3000) {
      errors.push('Content exceeds LinkedIn limit');
    }
  }
  
  if (platform === 'instagram') {
    if (content.length > 2200) {
      errors.push('Content exceeds Instagram limit');
    }
  }
  
  return errors;
}
```

### Retry Logic

```javascript
// Implement retry logic
async function makeRequestWithRetry(requestFn, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await requestFn();
    } catch (error) {
      if (i === maxRetries - 1) {
        throw error;
      }
      
      // Exponential backoff
      await delay(Math.pow(2, i) * 1000);
    }
  }
}
```

## Rate Limiting

### LinkedIn Rate Limits

| Endpoint | Rate Limit | Window |
|----------|------------|--------|
| Posts | 25 requests | 1 hour |
| Connections | 100 requests | 1 hour |
| Insights | 100 requests | 1 hour |

### Instagram Rate Limits

| Endpoint | Rate Limit | Window |
|----------|------------|--------|
| Posts | 25 requests | 1 hour |
| Stories | 50 requests | 1 hour |
| Insights | 200 requests | 1 hour |

### Rate Limiting Implementation

```javascript
// Rate limiting implementation
class RateLimiter {
  constructor(limit, window) {
    this.limit = limit;
    this.window = window;
    this.requests = [];
  }
  
  async waitForSlot() {
    const now = Date.now();
    
    // Remove old requests
    this.requests = this.requests.filter(
      time => now - time < this.window
    );
    
    // Check if we can make a request
    if (this.requests.length >= this.limit) {
      const oldestRequest = this.requests[0];
      const waitTime = this.window - (now - oldestRequest);
      await delay(waitTime);
    }
    
    // Add current request
    this.requests.push(now);
  }
}
```

## Authentication

### Token Management

#### Access Token Storage

```javascript
// Secure token storage
class TokenManager {
  constructor() {
    this.tokens = new Map();
  }
  
  setToken(platform, token) {
    // Encrypt token before storage
    const encryptedToken = this.encrypt(token);
    this.tokens.set(platform, encryptedToken);
  }
  
  getToken(platform) {
    const encryptedToken = this.tokens.get(platform);
    if (!encryptedToken) {
      throw new Error('Token not found');
    }
    return this.decrypt(encryptedToken);
  }
  
  encrypt(token) {
    // Implement encryption
    return Buffer.from(token).toString('base64');
  }
  
  decrypt(encryptedToken) {
    // Implement decryption
    return Buffer.from(encryptedToken, 'base64').toString();
  }
}
```

#### Token Refresh

```javascript
// Token refresh implementation
async function refreshToken(platform) {
  const refreshToken = await getRefreshToken(platform);
  
  const response = await fetch(`${platform}/oauth/token`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams({
      grant_type: 'refresh_token',
      refresh_token: refreshToken,
      client_id: process.env[`${platform.toUpperCase()}_CLIENT_ID`],
      client_secret: process.env[`${platform.toUpperCase()}_CLIENT_SECRET`],
    }),
  });
  
  const data = await response.json();
  
  // Store new tokens
  await storeTokens(platform, data.access_token, data.refresh_token);
  
  return data.access_token;
}
```

### Security Best Practices

1. **Use Environment Variables:**
   ```bash
   export LINKEDIN_CLIENT_ID="your_client_id"
   export LINKEDIN_CLIENT_SECRET="your_client_secret"
   ```

2. **Implement Token Rotation:**
   ```javascript
   // Rotate tokens regularly
   setInterval(async () => {
     await refreshToken('linkedin');
     await refreshToken('instagram');
   }, 24 * 60 * 60 * 1000); // 24 hours
   ```

3. **Validate Webhook Signatures:**
   ```javascript
   // Always validate webhook signatures
   if (!verifyWebhookSignature(payload, signature)) {
     throw new Error('Invalid webhook signature');
   }
   ```

4. **Use HTTPS:**
   ```javascript
   // Always use HTTPS in production
   const webhookUrl = process.env.NODE_ENV === 'production' 
     ? 'https://your-domain.com/webhook'
     : 'http://localhost:5678/webhook';
   ```

## Testing

### API Testing

#### LinkedIn API Test

```javascript
// Test LinkedIn API connection
async function testLinkedInAPI() {
  try {
    const response = await fetch('https://api.linkedin.com/v2/me', {
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'X-Restli-Protocol-Version': '2.0.0',
      },
    });
    
    if (response.ok) {
      const data = await response.json();
      console.log('LinkedIn API connection successful');
      return data;
    } else {
      throw new Error(`LinkedIn API error: ${response.status}`);
    }
  } catch (error) {
    console.error('LinkedIn API test failed:', error);
    throw error;
  }
}
```

#### Instagram API Test

```javascript
// Test Instagram API connection
async function testInstagramAPI() {
  try {
    const response = await fetch(
      `https://graph.facebook.com/v18.0/${businessAccountId}?fields=id,name&access_token=${accessToken}`
    );
    
    if (response.ok) {
      const data = await response.json();
      console.log('Instagram API connection successful');
      return data;
    } else {
      throw new Error(`Instagram API error: ${response.status}`);
    }
  } catch (error) {
    console.error('Instagram API test failed:', error);
    throw error;
  }
}
```

### Webhook Testing

```javascript
// Test webhook endpoints
async function testWebhooks() {
  const webhooks = [
    'https://your-n8n-instance.com/webhook/linkedin',
    'https://your-n8n-instance.com/webhook/instagram',
  ];
  
  for (const webhook of webhooks) {
    try {
      const response = await fetch(webhook, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          test: true,
          timestamp: new Date().toISOString(),
        }),
      });
      
      if (response.ok) {
        console.log(`Webhook ${webhook} is working`);
      } else {
        console.error(`Webhook ${webhook} failed: ${response.status}`);
      }
    } catch (error) {
      console.error(`Webhook ${webhook} error:`, error);
    }
  }
}
```

## Monitoring

### API Health Checks

```javascript
// Monitor API health
async function checkAPIHealth() {
  const checks = [
    { name: 'LinkedIn API', test: testLinkedInAPI },
    { name: 'Instagram API', test: testInstagramAPI },
  ];
  
  for (const check of checks) {
    try {
      await check.test();
      console.log(`${check.name} is healthy`);
    } catch (error) {
      console.error(`${check.name} is unhealthy:`, error);
      // Send alert
      await sendAlert(`${check.name} is down`);
    }
  }
}
```

### Performance Monitoring

```javascript
// Monitor API performance
async function monitorAPIPerformance() {
  const startTime = Date.now();
  
  try {
    await makeAPIRequest();
    const duration = Date.now() - startTime;
    
    // Log performance metrics
    console.log(`API request took ${duration}ms`);
    
    if (duration > 5000) {
      console.warn('API request is slow');
    }
  } catch (error) {
    console.error('API request failed:', error);
  }
}
```

This documentation provides comprehensive information about the APIs used in the automation workflows. For more specific implementation details, refer to the individual workflow files and configuration settings.