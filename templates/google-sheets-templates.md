# Google Sheets Templates for Social Media Automation

This document provides templates for the Google Sheets that will be used with the n8n social media automation workflows.

## 1. LinkedIn Content Sheet

Create a Google Sheet with the following columns:

| Column A | Column B | Column C | Column D | Column E |
|----------|----------|----------|----------|----------|
| content | scheduled_time | category | status | post_type |

### Example Data:
```
content | scheduled_time | category | status | post_type
"Excited to share insights about digital transformation in today's business landscape. Companies that embrace technology early gain significant competitive advantages. #DigitalTransformation #Business" | 2024-01-15T10:00:00Z | business | pending | post
"Just completed an amazing project using AI and machine learning. The possibilities are endless when technology meets creativity. #AI #Innovation" | 2024-01-15T14:00:00Z | tech | pending | post
```

## 2. Instagram Content Sheet

Create a Google Sheet with the following columns:

| Column A | Column B | Column C | Column D | Column E | Column F |
|----------|----------|----------|----------|----------|----------|
| caption | image_url | category | scheduled_time | status | post_type |

### Example Data:
```
caption | image_url | category | scheduled_time | status | post_type
"Starting the week with positive energy and clear goals! 💪✨" | https://example.com/image1.jpg | lifestyle | 2024-01-15T08:00:00Z | pending | post
"Behind the scenes of our latest project. Innovation happens when passion meets purpose." | https://example.com/image2.jpg | business | 2024-01-15T12:00:00Z | pending | post
```

## 3. Cross-Platform Content Sheet

Create a Google Sheet with the following columns:

| Column A | Column B | Column C | Column D | Column E | Column F |
|----------|----------|----------|----------|----------|----------|
| content | image_url | platforms | category | scheduled_time | post_type |

### Example Data:
```
content | image_url | platforms | category | scheduled_time | post_type
"Sharing valuable insights about entrepreneurship and business growth strategies that every startup should know." | https://example.com/image3.jpg | linkedin,instagram | business | 2024-01-15T16:00:00Z | post
"Technology is reshaping industries. Here's how AI is transforming customer experiences across sectors." | https://example.com/image4.jpg | linkedin,instagram | tech | 2024-01-15T20:00:00Z | post
```

## 4. LinkedIn Analytics Sheet

Create a Google Sheet with the following columns:

| Column A | Column B | Column C | Column D | Column E | Column F |
|----------|----------|----------|----------|----------|----------|
| Date | Post Content | Post ID | Visibility | Status | Timestamp |

## 5. Instagram Analytics Sheet

Create a Google Sheet with the following columns:

| Column A | Column B | Column C | Column D | Column E | Column F | Column G | Column H |
|----------|----------|----------|----------|----------|----------|----------|----------|
| Date | Time | Post Caption | Hashtags | Category | Post ID | Image URL | Status |

## 6. Cross-Platform Analytics Sheet

Create a Google Sheet with the following columns:

| Column A | Column B | Column C | Column D | Column E | Column F | Column G | Column H | Column I |
|----------|----------|----------|----------|----------|----------|----------|----------|----------|
| Date | Time | Platform | Content | Adapted Content | Category | Post ID | Status | Image URL |

## 7. Instagram Daily Insights Sheet

Create a Google Sheet with the following columns:

| Column A | Column B | Column C | Column D | Column E |
|----------|----------|----------|----------|----------|
| Date | Impressions | Reach | Profile Views | Followers |

## Setup Instructions:

1. **Create Google Sheets**: Create separate Google Sheets for each template above
2. **Get Sheet IDs**: Copy the Sheet ID from the URL (the long string between `/d/` and `/edit`)
3. **Update Workflow Configurations**: Replace the placeholder IDs in the workflow JSON files:
   - `your-google-sheet-id` → LinkedIn content sheet ID
   - `your-instagram-content-sheet-id` → Instagram content sheet ID
   - `your-cross-platform-content-sheet-id` → Cross-platform content sheet ID
   - `your-analytics-sheet-id` → LinkedIn analytics sheet ID
   - `your-instagram-analytics-sheet-id` → Instagram analytics sheet ID
   - `your-cross-platform-analytics-sheet-id` → Cross-platform analytics sheet ID
   - `your-instagram-insights-sheet-id` → Instagram insights sheet ID

4. **Share Sheets**: Make sure to share the sheets with the Google account used for n8n credentials
5. **Set Permissions**: Ensure the sheets have edit permissions for the n8n service account

## Content Guidelines:

### LinkedIn Content:
- Professional tone
- Industry insights
- Business-focused hashtags
- Length: Up to 3000 characters
- Include call-to-action when appropriate

### Instagram Content:
- Visual-first approach
- Engaging captions
- Relevant hashtags (10-30)
- Length: Up to 2200 characters
- Include emojis for engagement

### Cross-Platform Content:
- Adaptable for both platforms
- Core message that works professionally and visually
- Platform-specific optimizations handled automatically
- Include high-quality images