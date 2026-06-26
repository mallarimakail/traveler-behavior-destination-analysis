# Traveler Behavior & Destination Trend Analysis

## Overview
Business intelligence analysis of Airbnb short-term rental markets across 
NYC, Mexico City, and New Orleans to identify partnership and content 
opportunities for a travel media company with newsletter subscribers.

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

Download travel_project.xlsx to view pivot tables, calculated columns, and conditional formatting.

## Excel Workbook Preview
<img width="1052" height="597" alt="Screenshot 2026-06-26 at 3 19 03 PM" src="https://github.com/user-attachments/assets/45d13c10-2476-463e-9834-e9de3aae1a6c" />
<img width="669" height="661" alt="Screenshot 2026-06-26 at 3 19 47 PM" src="https://github.com/user-attachments/assets/5e13aa29-d17c-4705-a025-a87543eac770" />
<img width="849" height="488" alt="Screenshot 2026-06-26 at 3 20 03 PM" src="https://github.com/user-attachments/assets/7ed6c90a-6edf-40a7-bdec-2c1a13911c6a" />
<img width="869" height="451" alt="Screenshot 2026-06-26 at 3 20 29 PM" src="https://github.com/user-attachments/assets/4b8b5cba-f8ac-4c97-b2c3-8ada47dee05e" />

## Dashboard Preview
<img width="2732" height="1536" alt="Executive Dashboard" src="https://github.com/user-attachments/assets/0f7e4948-2527-4ff8-8f58-d0ece0ab05e4" />
