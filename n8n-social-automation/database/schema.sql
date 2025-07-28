-- Database schema for n8n Social Media Automation
-- Supports both LinkedIn and Instagram content management

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS n8n_social_automation;
USE n8n_social_automation;

-- Content Calendar table
CREATE TABLE IF NOT EXISTS content_calendar (
    id INT PRIMARY KEY AUTO_INCREMENT,
    platform ENUM('linkedin', 'instagram', 'both') NOT NULL,
    content_type ENUM('post', 'story', 'reel', 'article', 'poll') NOT NULL,
    content TEXT NOT NULL,
    caption TEXT,
    media_url VARCHAR(500),
    media_type ENUM('image', 'video', 'carousel', 'document'),
    hashtags JSON,
    mentions JSON,
    scheduled_time DATETIME NOT NULL,
    status ENUM('draft', 'pending', 'published', 'failed', 'cancelled') DEFAULT 'pending',
    published_at DATETIME,
    post_id VARCHAR(100),
    engagement_initial INT DEFAULT 0,
    retry_count INT DEFAULT 0,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_platform_status (platform, status),
    INDEX idx_scheduled_time (scheduled_time)
);

-- LinkedIn Connections table
CREATE TABLE IF NOT EXISTS linkedin_connections (
    id INT PRIMARY KEY AUTO_INCREMENT,
    profile_id VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    headline VARCHAR(500),
    company VARCHAR(255),
    location VARCHAR(255),
    connection_date DATETIME NOT NULL,
    connection_type ENUM('1st', '2nd', '3rd') DEFAULT '1st',
    tags JSON,
    notes TEXT,
    is_lead BOOLEAN DEFAULT FALSE,
    lead_score INT DEFAULT 0,
    last_interaction DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_is_lead (is_lead),
    INDEX idx_lead_score (lead_score)
);

-- Instagram Followers table
CREATE TABLE IF NOT EXISTS instagram_followers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) UNIQUE NOT NULL,
    user_id VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    profile_pic_url VARCHAR(500),
    is_verified BOOLEAN DEFAULT FALSE,
    follow_date DATETIME NOT NULL,
    follower_count INT,
    following_count INT,
    engagement_rate DECIMAL(5,2),
    is_business BOOLEAN DEFAULT FALSE,
    category VARCHAR(100),
    tags JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_engagement_rate (engagement_rate)
);

-- Engagement Analytics table
CREATE TABLE IF NOT EXISTS engagement_analytics (
    id INT PRIMARY KEY AUTO_INCREMENT,
    platform ENUM('linkedin', 'instagram') NOT NULL,
    post_id VARCHAR(100) NOT NULL,
    content_id INT,
    metric_type ENUM('likes', 'comments', 'shares', 'saves', 'impressions', 'reach', 'profile_visits') NOT NULL,
    metric_value INT NOT NULL,
    recorded_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (content_id) REFERENCES content_calendar(id),
    INDEX idx_platform_post (platform, post_id),
    INDEX idx_recorded_at (recorded_at)
);

-- Hashtag Performance table
CREATE TABLE IF NOT EXISTS hashtag_performance (
    id INT PRIMARY KEY AUTO_INCREMENT,
    platform ENUM('linkedin', 'instagram') NOT NULL,
    hashtag VARCHAR(100) NOT NULL,
    usage_count INT DEFAULT 1,
    total_reach INT DEFAULT 0,
    total_engagement INT DEFAULT 0,
    avg_engagement_rate DECIMAL(5,2) DEFAULT 0,
    last_used DATETIME,
    trending_score INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_platform_hashtag (platform, hashtag),
    INDEX idx_trending_score (trending_score)
);

-- Automation Logs table
CREATE TABLE IF NOT EXISTS automation_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    workflow_name VARCHAR(255) NOT NULL,
    execution_id VARCHAR(100),
    status ENUM('started', 'success', 'failed', 'warning') NOT NULL,
    message TEXT,
    error_details JSON,
    items_processed INT DEFAULT 0,
    execution_time_ms INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_workflow_status (workflow_name, status),
    INDEX idx_created_at (created_at)
);

-- Lead Scoring Rules table
CREATE TABLE IF NOT EXISTS lead_scoring_rules (
    id INT PRIMARY KEY AUTO_INCREMENT,
    platform ENUM('linkedin', 'instagram') NOT NULL,
    rule_name VARCHAR(255) NOT NULL,
    rule_type ENUM('engagement', 'profile', 'content', 'behavior') NOT NULL,
    condition_field VARCHAR(100) NOT NULL,
    condition_operator ENUM('equals', 'contains', 'greater_than', 'less_than', 'in_list') NOT NULL,
    condition_value TEXT NOT NULL,
    score_adjustment INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Content Templates table
CREATE TABLE IF NOT EXISTS content_templates (
    id INT PRIMARY KEY AUTO_INCREMENT,
    platform ENUM('linkedin', 'instagram', 'both') NOT NULL,
    template_name VARCHAR(255) NOT NULL,
    template_type ENUM('post', 'story', 'reel', 'article') NOT NULL,
    template_content TEXT NOT NULL,
    variables JSON,
    hashtag_sets JSON,
    is_active BOOLEAN DEFAULT TRUE,
    usage_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Webhook Events table
CREATE TABLE IF NOT EXISTS webhook_events (
    id INT PRIMARY KEY AUTO_INCREMENT,
    platform ENUM('linkedin', 'instagram') NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    event_data JSON NOT NULL,
    processed BOOLEAN DEFAULT FALSE,
    processed_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_platform_processed (platform, processed)
);

-- Create views for analytics

-- Content Performance View
CREATE OR REPLACE VIEW content_performance AS
SELECT 
    cc.id,
    cc.platform,
    cc.content_type,
    cc.published_at,
    cc.hashtags,
    COALESCE(SUM(CASE WHEN ea.metric_type = 'likes' THEN ea.metric_value END), 0) as total_likes,
    COALESCE(SUM(CASE WHEN ea.metric_type = 'comments' THEN ea.metric_value END), 0) as total_comments,
    COALESCE(SUM(CASE WHEN ea.metric_type = 'shares' THEN ea.metric_value END), 0) as total_shares,
    COALESCE(SUM(CASE WHEN ea.metric_type = 'impressions' THEN ea.metric_value END), 0) as total_impressions,
    COALESCE(SUM(CASE WHEN ea.metric_type = 'reach' THEN ea.metric_value END), 0) as total_reach
FROM content_calendar cc
LEFT JOIN engagement_analytics ea ON cc.id = ea.content_id
WHERE cc.status = 'published'
GROUP BY cc.id;

-- Daily Analytics Summary View
CREATE OR REPLACE VIEW daily_analytics_summary AS
SELECT 
    DATE(published_at) as publish_date,
    platform,
    COUNT(*) as posts_published,
    AVG(total_likes) as avg_likes,
    AVG(total_comments) as avg_comments,
    AVG(total_shares) as avg_shares,
    SUM(total_reach) as total_daily_reach
FROM content_performance
GROUP BY DATE(published_at), platform;

-- Create stored procedures

DELIMITER //

-- Procedure to calculate lead score
CREATE PROCEDURE calculate_lead_score(IN p_profile_id VARCHAR(100))
BEGIN
    DECLARE total_score INT DEFAULT 0;
    DECLARE engagement_score INT DEFAULT 0;
    
    -- Calculate engagement score based on interactions
    SELECT COUNT(*) * 10 INTO engagement_score
    FROM engagement_analytics ea
    JOIN content_calendar cc ON ea.content_id = cc.id
    WHERE cc.mentions LIKE CONCAT('%', p_profile_id, '%');
    
    -- Add profile-based scoring
    SELECT 
        CASE 
            WHEN headline LIKE '%CEO%' OR headline LIKE '%Founder%' THEN 50
            WHEN headline LIKE '%Director%' OR headline LIKE '%Manager%' THEN 30
            ELSE 10
        END INTO total_score
    FROM linkedin_connections
    WHERE profile_id = p_profile_id;
    
    -- Update lead score
    UPDATE linkedin_connections
    SET lead_score = total_score + engagement_score,
        updated_at = NOW()
    WHERE profile_id = p_profile_id;
END//

-- Procedure to update hashtag performance
CREATE PROCEDURE update_hashtag_performance(
    IN p_platform ENUM('linkedin', 'instagram'),
    IN p_hashtags JSON,
    IN p_reach INT,
    IN p_engagement INT
)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE hashtag_count INT;
    DECLARE current_hashtag VARCHAR(100);
    
    SET hashtag_count = JSON_LENGTH(p_hashtags);
    
    WHILE i < hashtag_count DO
        SET current_hashtag = JSON_UNQUOTE(JSON_EXTRACT(p_hashtags, CONCAT('$[', i, ']')));
        
        INSERT INTO hashtag_performance (platform, hashtag, usage_count, total_reach, total_engagement, last_used)
        VALUES (p_platform, current_hashtag, 1, p_reach, p_engagement, NOW())
        ON DUPLICATE KEY UPDATE
            usage_count = usage_count + 1,
            total_reach = total_reach + p_reach,
            total_engagement = total_engagement + p_engagement,
            avg_engagement_rate = (total_engagement + p_engagement) / (usage_count + 1),
            last_used = NOW();
        
        SET i = i + 1;
    END WHILE;
END//

DELIMITER ;

-- Create indexes for better performance
CREATE INDEX idx_content_calendar_composite ON content_calendar(platform, status, scheduled_time);
CREATE INDEX idx_engagement_analytics_composite ON engagement_analytics(platform, post_id, metric_type);
CREATE INDEX idx_automation_logs_date_range ON automation_logs(created_at, workflow_name);

-- Initial data for lead scoring rules
INSERT INTO lead_scoring_rules (platform, rule_name, rule_type, condition_field, condition_operator, condition_value, score_adjustment) VALUES
('linkedin', 'C-Level Executive', 'profile', 'headline', 'contains', 'CEO,CTO,CFO,CMO', 50),
('linkedin', 'Director Level', 'profile', 'headline', 'contains', 'Director,Head of', 30),
('linkedin', 'High Engagement', 'engagement', 'interaction_count', 'greater_than', '5', 20),
('instagram', 'Verified Account', 'profile', 'is_verified', 'equals', 'true', 40),
('instagram', 'High Follower Count', 'profile', 'follower_count', 'greater_than', '10000', 30),
('instagram', 'Business Account', 'profile', 'is_business', 'equals', 'true', 20);