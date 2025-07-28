#!/bin/bash

# Webhook Testing Script for N8N Social Media Automation
# This script tests the webhook endpoints for manual posting

set -e

N8N_BASE_URL="http://localhost:5678"

echo "🧪 Testing N8N Social Media Automation Webhooks..."

# Test LinkedIn webhook
echo ""
echo "📱 Testing LinkedIn webhook..."
LINKEDIN_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "${N8N_BASE_URL}/webhook/linkedin-webhook" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Test post from n8n automation system! This is a test to ensure our LinkedIn automation is working correctly. #automation #n8n #linkedin",
    "category": "tech",
    "scheduled_time": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
  }')

LINKEDIN_HTTP_CODE=$(echo "$LINKEDIN_RESPONSE" | tail -n1)
LINKEDIN_BODY=$(echo "$LINKEDIN_RESPONSE" | head -n -1)

if [ "$LINKEDIN_HTTP_CODE" = "200" ]; then
    echo "✅ LinkedIn webhook test successful"
    echo "📄 Response: $LINKEDIN_BODY"
else
    echo "❌ LinkedIn webhook test failed (HTTP $LINKEDIN_HTTP_CODE)"
    echo "📄 Response: $LINKEDIN_BODY"
fi

# Test Instagram webhook
echo ""
echo "📸 Testing Instagram webhook..."
INSTAGRAM_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "${N8N_BASE_URL}/webhook/instagram-webhook" \
  -H "Content-Type: application/json" \
  -d '{
    "caption": "Test post from our automation system! 🚀✨ #automation #n8n #instagram #test",
    "image_url": "https://via.placeholder.com/1080x1080.png?text=Test+Image",
    "category": "tech",
    "scheduled_time": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
  }')

INSTAGRAM_HTTP_CODE=$(echo "$INSTAGRAM_RESPONSE" | tail -n1)
INSTAGRAM_BODY=$(echo "$INSTAGRAM_RESPONSE" | head -n -1)

if [ "$INSTAGRAM_HTTP_CODE" = "200" ]; then
    echo "✅ Instagram webhook test successful"
    echo "📄 Response: $INSTAGRAM_BODY"
else
    echo "❌ Instagram webhook test failed (HTTP $INSTAGRAM_HTTP_CODE)"
    echo "📄 Response: $INSTAGRAM_BODY"
fi

# Test Cross-Platform webhook
echo ""
echo "🌐 Testing Cross-Platform webhook..."
CROSS_PLATFORM_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "${N8N_BASE_URL}/webhook/cross-platform-webhook" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Cross-platform test post! This message will be automatically adapted for both LinkedIn and Instagram with platform-specific optimizations.",
    "image_url": "https://via.placeholder.com/1080x1080.png?text=Cross+Platform+Test",
    "platforms": "linkedin,instagram",
    "category": "business",
    "post_type": "post"
  }')

CROSS_PLATFORM_HTTP_CODE=$(echo "$CROSS_PLATFORM_RESPONSE" | tail -n1)
CROSS_PLATFORM_BODY=$(echo "$CROSS_PLATFORM_RESPONSE" | head -n -1)

if [ "$CROSS_PLATFORM_HTTP_CODE" = "200" ]; then
    echo "✅ Cross-Platform webhook test successful"
    echo "📄 Response: $CROSS_PLATFORM_BODY"
else
    echo "❌ Cross-Platform webhook test failed (HTTP $CROSS_PLATFORM_HTTP_CODE)"
    echo "📄 Response: $CROSS_PLATFORM_BODY"
fi

echo ""
echo "🎯 Webhook Test Summary:"
echo "LinkedIn: $([ "$LINKEDIN_HTTP_CODE" = "200" ] && echo "✅ PASS" || echo "❌ FAIL")"
echo "Instagram: $([ "$INSTAGRAM_HTTP_CODE" = "200" ] && echo "✅ PASS" || echo "❌ FAIL")"
echo "Cross-Platform: $([ "$CROSS_PLATFORM_HTTP_CODE" = "200" ] && echo "✅ PASS" || echo "❌ FAIL")"
echo ""
echo "💡 Note: These tests only verify webhook connectivity."
echo "   Actual posting requires proper API credentials and configuration."
echo ""
echo "🔧 Troubleshooting:"
echo "- Ensure N8N is running: docker-compose ps"
echo "- Check N8N logs: docker-compose logs -f n8n"
echo "- Verify workflows are active in N8N interface"
echo "- Confirm webhook URLs in workflow configurations"