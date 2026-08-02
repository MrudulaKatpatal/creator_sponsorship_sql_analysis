# Creator Sponsorship Analytics : SQL Server Project

## Project overview
This project analyzes creator-brand sponsorship campaigns across Instagram, YouTube, LinkedIn, and TikTok.

The database contains:
- 30 creators
- 20 brands
- 80 campaigns
- 201 creator-campaign assignments
- 346 sponsored content posts
- 201 payment records

## Business problem
Brands spend money on creator campaigns but often struggle to compare campaign ROI, platform performance, creator effectiveness, conversion rates, and outstanding payments.

This project uses SQL Server to turn campaign-level data into business insights.

## Tools
- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- SQL

## SQL concepts demonstrated
- CREATE DATABASE and CREATE TABLE
- Primary keys and foreign keys
- INNER JOIN and LEFT JOIN
- GROUP BY and HAVING
- Aggregate functions
- CASE expressions
- Common Table Expressions (CTEs)
- Window functions: ROW_NUMBER and DENSE_RANK
- Views
- Date-based analysis
- ROI and conversion-rate calculations

## How to run
1. Open SQL Server Management Studio.
2. Open and execute `01_create_database_and_tables.sql`.
3. Open and execute `02_insert_sample_data.sql`.
4. Open and execute `03_analysis_queries.sql`.
5. Refresh the Databases folder and open `CreatorSponsorshipDB`.

No CSV import is required. The CSV files are included only for transparency and portfolio presentation.

## Repository structure
```text
creator-sponsorship-sql-project/
├── 01_create_database_and_tables.sql
├── 02_insert_sample_data.sql
├── 03_analysis_queries.sql
├── Business_Questions.md
├── README.md
└── data/
    ├── brands.csv
    ├── campaigns.csv
    ├── campaign_creators.csv
    ├── content_posts.csv
    ├── creator_accounts.csv
    ├── creators.csv
    ├── payments.csv
    └── platforms.csv
```

## Suggested resume entry
**Creator Sponsorship Analytics | SQL Server**

- Designed a relational SQL Server database to analyze creator-brand sponsorship campaigns across four social platforms.
- Wrote analytical queries using JOINs, CTEs, CASE expressions, aggregate functions, and window functions to evaluate campaign ROI, platform conversion rates, creator rankings, and payment status.
- Created a reusable campaign performance view and generated business insights from hundreds of campaign, content, and payment records.

## Interview preparation
Be ready to explain:
- Why each table exists
- How primary and foreign keys connect the database
- Why LEFT JOIN was used in the campaign performance view
- How ROI and conversion rates were calculated
- How ROW_NUMBER differs from DENSE_RANK
- What you would change if the dataset contained millions of rows
