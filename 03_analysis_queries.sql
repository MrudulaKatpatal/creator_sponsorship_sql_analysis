/*
Creator Sponsorship Analytics - Portfolio Queries
Run after files 01 and 02.
*/

USE CreatorSponsorshipDB;
GO

-- 1. Check row counts
SELECT 'creators' AS table_name, COUNT(*) AS row_count FROM creators
UNION ALL SELECT 'brands', COUNT(*) FROM brands
UNION ALL SELECT 'campaigns', COUNT(*) FROM campaigns
UNION ALL SELECT 'campaign_creators', COUNT(*) FROM campaign_creators
UNION ALL SELECT 'content_posts', COUNT(*) FROM content_posts
UNION ALL SELECT 'payments', COUNT(*) FROM payments;
GO

-- 2. Top 10 creators by total campaign revenue
SELECT TOP 10
    c.creator_name,
    c.niche,
    SUM(cp.revenue_generated) AS total_revenue_generated
FROM creators c
JOIN campaign_creators cc ON c.creator_id = cc.creator_id
JOIN content_posts cp ON cc.campaign_creator_id = cp.campaign_creator_id
GROUP BY c.creator_name, c.niche
ORDER BY total_revenue_generated DESC;
GO

-- 3. Campaign ROI
SELECT
    ca.campaign_id,
    ca.campaign_name,
    b.brand_name,
    ca.budget,
    SUM(cp.revenue_generated) AS revenue_generated,
    CAST(
        (SUM(cp.revenue_generated) - ca.budget) * 100.0 / NULLIF(ca.budget, 0)
        AS DECIMAL(10,2)
    ) AS roi_percent
FROM campaigns ca
JOIN brands b ON ca.brand_id = b.brand_id
JOIN campaign_creators cc ON ca.campaign_id = cc.campaign_id
JOIN content_posts cp ON cc.campaign_creator_id = cp.campaign_creator_id
GROUP BY ca.campaign_id, ca.campaign_name, b.brand_name, ca.budget
ORDER BY roi_percent DESC;
GO

-- 4. Platform performance
SELECT
    p.platform_name,
    COUNT(DISTINCT cp.post_id) AS posts,
    SUM(cp.impressions) AS total_impressions,
    SUM(cp.clicks) AS total_clicks,
    SUM(cp.conversions) AS total_conversions,
    CAST(SUM(cp.clicks) * 100.0 / NULLIF(SUM(cp.impressions), 0) AS DECIMAL(10,2)) AS ctr_percent,
    CAST(SUM(cp.conversions) * 100.0 / NULLIF(SUM(cp.clicks), 0) AS DECIMAL(10,2)) AS conversion_rate_percent
FROM platforms p
JOIN creator_accounts ca ON p.platform_id = ca.platform_id
JOIN content_posts cp ON ca.account_id = cp.account_id
GROUP BY p.platform_name
ORDER BY total_conversions DESC;
GO

-- 5. Best niche by average revenue per post
SELECT
    c.niche,
    COUNT(cp.post_id) AS post_count,
    CAST(AVG(cp.revenue_generated) AS DECIMAL(12,2)) AS avg_revenue_per_post
FROM creators c
JOIN campaign_creators cc ON c.creator_id = cc.creator_id
JOIN content_posts cp ON cc.campaign_creator_id = cp.campaign_creator_id
GROUP BY c.niche
HAVING COUNT(cp.post_id) >= 5
ORDER BY avg_revenue_per_post DESC;
GO

-- 6. Brands with pending or unpaid creator fees
SELECT
    b.brand_name,
    COUNT(*) AS pending_payment_records,
    SUM(cc.agreed_fee - p.amount_paid) AS outstanding_amount
FROM brands b
JOIN campaigns ca ON b.brand_id = ca.brand_id
JOIN campaign_creators cc ON ca.campaign_id = cc.campaign_id
JOIN payments p ON cc.campaign_creator_id = p.campaign_creator_id
WHERE p.payment_status IN ('Pending', 'Partially Paid', 'Not Paid')
GROUP BY b.brand_name
ORDER BY outstanding_amount DESC;
GO

-- 7. Rank creators within each niche by generated revenue
WITH creator_revenue AS (
    SELECT
        c.creator_id,
        c.creator_name,
        c.niche,
        SUM(cp.revenue_generated) AS total_revenue
    FROM creators c
    JOIN campaign_creators cc ON c.creator_id = cc.creator_id
    JOIN content_posts cp ON cc.campaign_creator_id = cp.campaign_creator_id
    GROUP BY c.creator_id, c.creator_name, c.niche
)
SELECT
    creator_name,
    niche,
    total_revenue,
    DENSE_RANK() OVER (
        PARTITION BY niche
        ORDER BY total_revenue DESC
    ) AS niche_rank
FROM creator_revenue
ORDER BY niche, niche_rank;
GO

-- 8. Monthly campaign revenue trend
SELECT
    DATEFROMPARTS(YEAR(cp.post_date), MONTH(cp.post_date), 1) AS revenue_month,
    SUM(cp.revenue_generated) AS monthly_revenue
FROM content_posts cp
GROUP BY DATEFROMPARTS(YEAR(cp.post_date), MONTH(cp.post_date), 1)
ORDER BY revenue_month;
GO

-- 9. Creators performing above their niche average
WITH creator_perf AS (
    SELECT
        c.creator_name,
        c.niche,
        AVG(CAST(cp.revenue_generated AS DECIMAL(14,2))) AS creator_avg_revenue
    FROM creators c
    JOIN campaign_creators cc ON c.creator_id = cc.creator_id
    JOIN content_posts cp ON cc.campaign_creator_id = cp.campaign_creator_id
    GROUP BY c.creator_name, c.niche
),
niche_perf AS (
    SELECT
        niche,
        AVG(creator_avg_revenue) AS niche_avg_revenue
    FROM creator_perf
    GROUP BY niche
)
SELECT
    cp.creator_name,
    cp.niche,
    CAST(cp.creator_avg_revenue AS DECIMAL(12,2)) AS creator_avg_revenue,
    CAST(np.niche_avg_revenue AS DECIMAL(12,2)) AS niche_avg_revenue
FROM creator_perf cp
JOIN niche_perf np ON cp.niche = np.niche
WHERE cp.creator_avg_revenue > np.niche_avg_revenue
ORDER BY cp.niche, cp.creator_avg_revenue DESC;
GO

-- 10. Campaign profitability category using CASE
SELECT
    ca.campaign_name,
    ca.budget,
    SUM(cp.revenue_generated) AS revenue_generated,
    CASE
        WHEN SUM(cp.revenue_generated) >= ca.budget * 1.50 THEN 'High Return'
        WHEN SUM(cp.revenue_generated) >= ca.budget THEN 'Profitable'
        ELSE 'Loss Making'
    END AS performance_category
FROM campaigns ca
JOIN campaign_creators cc ON ca.campaign_id = cc.campaign_id
JOIN content_posts cp ON cc.campaign_creator_id = cp.campaign_creator_id
GROUP BY ca.campaign_name, ca.budget
ORDER BY revenue_generated DESC;
GO

-- 11. Top creator for each platform
WITH platform_creator AS (
    SELECT
        p.platform_name,
        c.creator_name,
        SUM(cp.revenue_generated) AS revenue_generated,
        ROW_NUMBER() OVER (
            PARTITION BY p.platform_name
            ORDER BY SUM(cp.revenue_generated) DESC
        ) AS rn
    FROM platforms p
    JOIN creator_accounts a ON p.platform_id = a.platform_id
    JOIN creators c ON a.creator_id = c.creator_id
    JOIN content_posts cp ON a.account_id = cp.account_id
    GROUP BY p.platform_name, c.creator_name
)
SELECT platform_name, creator_name, revenue_generated
FROM platform_creator
WHERE rn = 1;
GO

-- 12. Create a reusable campaign performance view
CREATE OR ALTER VIEW vw_campaign_performance AS
SELECT
    ca.campaign_id,
    ca.campaign_name,
    b.brand_name,
    ca.objective,
    ca.budget,
    COUNT(DISTINCT cp.post_id) AS total_posts,
    SUM(cp.impressions) AS total_impressions,
    SUM(cp.clicks) AS total_clicks,
    SUM(cp.conversions) AS total_conversions,
    SUM(cp.revenue_generated) AS total_revenue
FROM campaigns ca
JOIN brands b ON ca.brand_id = b.brand_id
LEFT JOIN campaign_creators cc ON ca.campaign_id = cc.campaign_id
LEFT JOIN content_posts cp ON cc.campaign_creator_id = cp.campaign_creator_id
GROUP BY ca.campaign_id, ca.campaign_name, b.brand_name, ca.objective, ca.budget;
GO

SELECT TOP 20 *
FROM vw_campaign_performance
ORDER BY total_revenue DESC;
GO
