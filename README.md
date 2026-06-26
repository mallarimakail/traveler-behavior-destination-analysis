# traveler-behavior-destination-analysis

# Traveler Behavior & Destination Trend Analysis

## Overview
Business intelligence analysis of Airbnb short-term rental markets across 
NYC, Mexico City, and New Orleans to identify partnership and content 
opportunities for a travel media company with 500,000 newsletter subscribers.

## Business Questions
- Q1: Where is demand growing faster than supply?
- Q2: When should we publish and promote content?
- Q3: What do high-performing listings tell us about what travelers want?
- Q4: Are there markets where a new entrant could compete on price?

## Tools Used
- **SQL (PostgreSQL)** — data cleaning, CTEs, window functions, aggregations
- **Excel** — pivot tables, calculated columns, conditional formatting
- **Tableau** — interactive 4-page dashboard with slicers and filters

## Data Source
Inside Airbnb (insideairbnb.com) — open source Airbnb listing data

## Key Findings
1. Gramercy (NYC) has 68% occupancy vs 41% city average with $110 pricing lag
2. All 3 cities peak March–April — content should publish 6–8 weeks prior
3. Cleanliness score drop from 5.0 to 4.0 costs up to 52% occupancy (New Orleans)
4. New Orleans entire short-term market is underpriced — strongest GO signal

## File Structure
01_create_tables.sql

02_inspect_nyc.sql

03_inspect_mexico_city.sql

04_inspect_new_orleans.sql

05_data_cleaning.sql

06_q1_demand_vs_supply.sql

07_q2_seasonality.sql

08_q3_listing_attributes.sql

09_q4_market_entry.sql

10_exports.sql

## Dashboard Preview
[Insert Tableau screenshot here]
