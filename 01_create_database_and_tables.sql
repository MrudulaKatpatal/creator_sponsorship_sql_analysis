/*
Creator Sponsorship Analytics
SQL Server / SSMS
Run this file first.
*/

IF DB_ID('CreatorSponsorshipDB') IS NULL
BEGIN
    CREATE DATABASE CreatorSponsorshipDB;
END;
GO

USE CreatorSponsorshipDB;
GO

DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS content_posts;
DROP TABLE IF EXISTS campaign_creators;
DROP TABLE IF EXISTS campaigns;
DROP TABLE IF EXISTS creator_accounts;
DROP TABLE IF EXISTS brands;
DROP TABLE IF EXISTS creators;
DROP TABLE IF EXISTS platforms;
GO

CREATE TABLE platforms (
    platform_id INT PRIMARY KEY,
    platform_name VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE creators (
    creator_id INT PRIMARY KEY,
    creator_name VARCHAR(100) NOT NULL,
    niche VARCHAR(50) NOT NULL,
    city VARCHAR(50),
    join_date DATE NOT NULL
);

CREATE TABLE brands (
    brand_id INT PRIMARY KEY,
    brand_name VARCHAR(100) NOT NULL,
    industry VARCHAR(50) NOT NULL,
    city VARCHAR(50)
);

CREATE TABLE creator_accounts (
    account_id INT PRIMARY KEY,
    creator_id INT NOT NULL,
    platform_id INT NOT NULL,
    followers INT NOT NULL CHECK (followers >= 0),
    engagement_rate DECIMAL(5,2) NOT NULL CHECK (engagement_rate >= 0),
    CONSTRAINT FK_creator_accounts_creator
        FOREIGN KEY (creator_id) REFERENCES creators(creator_id),
    CONSTRAINT FK_creator_accounts_platform
        FOREIGN KEY (platform_id) REFERENCES platforms(platform_id)
);

CREATE TABLE campaigns (
    campaign_id INT PRIMARY KEY,
    brand_id INT NOT NULL,
    campaign_name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget DECIMAL(12,2) NOT NULL CHECK (budget >= 0),
    objective VARCHAR(50) NOT NULL,
    CONSTRAINT FK_campaigns_brand
        FOREIGN KEY (brand_id) REFERENCES brands(brand_id)
);

CREATE TABLE campaign_creators (
    campaign_creator_id INT PRIMARY KEY,
    campaign_id INT NOT NULL,
    creator_id INT NOT NULL,
    agreed_fee DECIMAL(12,2) NOT NULL CHECK (agreed_fee >= 0),
    campaign_status VARCHAR(20) NOT NULL,
    CONSTRAINT FK_campaign_creators_campaign
        FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id),
    CONSTRAINT FK_campaign_creators_creator
        FOREIGN KEY (creator_id) REFERENCES creators(creator_id)
);

CREATE TABLE content_posts (
    post_id INT PRIMARY KEY,
    campaign_creator_id INT NOT NULL,
    account_id INT NOT NULL,
    post_date DATE NOT NULL,
    impressions INT NOT NULL CHECK (impressions >= 0),
    likes INT NOT NULL CHECK (likes >= 0),
    comments INT NOT NULL CHECK (comments >= 0),
    clicks INT NOT NULL CHECK (clicks >= 0),
    conversions INT NOT NULL CHECK (conversions >= 0),
    revenue_generated DECIMAL(14,2) NOT NULL CHECK (revenue_generated >= 0),
    CONSTRAINT FK_content_posts_campaign_creator
        FOREIGN KEY (campaign_creator_id) REFERENCES campaign_creators(campaign_creator_id),
    CONSTRAINT FK_content_posts_account
        FOREIGN KEY (account_id) REFERENCES creator_accounts(account_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    campaign_creator_id INT NOT NULL,
    amount_paid DECIMAL(12,2) NOT NULL CHECK (amount_paid >= 0),
    payment_date DATE NULL,
    payment_status VARCHAR(20) NOT NULL,
    CONSTRAINT FK_payments_campaign_creator
        FOREIGN KEY (campaign_creator_id) REFERENCES campaign_creators(campaign_creator_id)
);
GO
