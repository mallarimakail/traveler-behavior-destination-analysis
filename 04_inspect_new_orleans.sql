-- ================================================
-- 04_inspect_new_orleans.sql
-- Purpose: Inspect data for New Orleans.
-- Last updated: 06-10-2026
-- ================================================

-- ------------------------------------------------
-- LISTINGS_NEW_ORLEANS
-- ------------------------------------------------

-- Row counts - how many rows come through?
select count(*) from listings_new_orleans;

-- Preview first rows - does it look right?
select * from listings_new_orleans limit 10;

-- What columns exist and what type are they? data_type should all show up as "text".
select column_name, data_type
from information_schema.columns
where table_name = 'listings_new_orleans'
order by ordinal_position;

-- Check nulls in key columns
select
  count(*) as total_rows,
  count(nullif(price, '')) as has_price,
  count(nullif(availability_365, '')) as has_availability,
  count(nullif(review_scores_rating, '')) as has_rating,
  count(nullif(neighbourhood_cleansed, '')) as has_neighbourhood
from listings_new_orleans;
-- NOTE:
-- 6,007 has a price out of 6,218.
-- 5,370 has a rating out of 6,218.

-- Check distinct room types; looking for discrepancies.
select distinct room_type from listings_new_orleans;

-- What neighbourhood groups exist? (1st attempt)
select distinct neighbourhood_group_cleansed from listings_new_orleans;
-- This column returns as NULL.

-- What neighbourhood groups exist? (2nd attempt)
select distinct neighborhood_overview from listings_new_orleans;
-- This column returns as NULL.

-- What neighbourhood groups exist? (3rd attempt)
select distinct neighbourhood from listings_new_orleans;
-- Returns as NULL.

-- What neighbourhood groups ACTUALLY exist?
select distinct neighbourhood_cleansed from listings_new_orleans;
-- Returns 69 rows.



-- Check price and availability ranges; looking for discrepancies.
-- min_price should not be 0 & max_price may be an error to check later.
select
  min(replace(replace(price, '$', ''), ',', '')::numeric) as min_price,
  max(replace(replace(price, '$', ''), ',', '')::numeric) as max_price,
  min(availability_365::numeric) as min_availability,
  max(availability_365::numeric) as max_availability
from listings_new_orleans
where price != '' and availability_365 != '';
-- Values seem plausible.

-- Check distribution of data.
-- How are listings spread across room types?
select
  room_type,
  count(*) as count,
  round(count(*) * 100.0 / sum(count(*)) over (), 1) as pct
from listings_new_orleans
group by room_type
order by count desc;

-- How are listings spread across neighbourhood groups?
select
  neighbourhood_cleansed,
  count(*) as count,
  round(count(*) * 100.0 / sum(count(*)) over (), 1) as pct
from listings_new_orleans
group by neighbourhood_cleansed
order by count desc;

-- New Orleans rental type breakdown
select
  case when minimum_nights::numeric < 30 then 'short term'
       when minimum_nights::numeric = 30 then 'monthly'
       else 'long term'
  end as rental_type,
  count(*) as count,
  round(count(*) * 100.0 / sum(count(*)) over (), 1) as pct
from listings_new_orleans
where minimum_nights != ''
group by rental_type
order by count desc;

-- New Orleans maximum nights distribution
select maximum_nights, count(*) as count
from listings_new_orleans
where maximum_nights != ''
group by maximum_nights
order by count desc
limit 20;
-- maximum_nights final decisions:
-- nyc: 16,205 listings (46%) have garbage value of 1125 -- drop column entirely
-- mexico city: column doesn't exist in source data -- nothing to do
-- new orleans: 2,428 listings have garbage value of 1125 -- drop column entirely

-- Check review scores range for all cities.
select
  min(review_scores_rating::numeric) as min_rating,
  max(review_scores_rating::numeric) as max_rating,
  count(nullif(review_scores_rating, '')) as has_rating,
  count(*) as total_rows
from listings_new_orleans
where review_scores_rating != '';

-- REVIEW SCORE FINDINGS:
-- NYC: range 0.0 - 5.0, 24,542 out of 35,036 listings have a rating (70% coverage)
--      ratings of 0.0 are suspicious -- likely listings with no reviews yet, filter out in cleaning
-- MEXICO CITY: no review_scores_rating column in source data -- cannot use for q3
-- NEW ORLEANS: range 1.0 - 5.0, 5,370 out of 6,218 listings have a rating (86% coverage)
--              clean range, no filtering needed beyond nulls
-- DECISION:
-- NYC: filter out review_scores_rating = 0 in clean table
-- MEXICO CITY: q3 attribute analysis will exclude rating -- use occupancy and price only
-- NEW ORLEANS: filter nulls and blanks only

-- Check availability range; confirm no impossible values over 365.
select
  min(availability_365::numeric) as min_avail,
  max(availability_365::numeric) as max_avail
from listings_nyc
where availability_365 != '';
-- availability_365 findings:
-- all three cities: range 0-365, no impossible values
-- decision: filter nulls and blanks only

-- New Orleans data freshness
select
  min(last_review::date) as earliest_review,
  max(last_review::date) as latest_review
from listings_new_orleans
where last_review != '';
-- data freshness findings:
-- nyc: 2011-05-12 to 2026-04-15 -- 15 years of history, data is current
-- mexico city: 2015-11-01 to 2026-04-02 -- 10 years of history, data is current
-- new orleans: 2014-04-08 to 2026-03-18 -- 12 years of history, data is current
-- decision: no date filtering needed -- all cities have current data as of early 2026



-- RENTAL TYPE FINDINGS:
-- NYC: 81% monthly -- likely impact of local law 18 (2023 short term rental restrictions)
-- Filter NYC to minimum_nights < 30 for travel analysis
-- Mexico City: 100% short term -- no filter needed
-- New Orleans: 64.6% short term, 33.6% monthly -- filter to minimum_nights < 30
-- This is a key finding for the executive brief.



-- ------------------------------------------------
-- CALENDAR_NEW_ORLEANS
-- ------------------------------------------------

-- Row counts - how many rows come through?
select count(*) from calendar_new_orleans;

-- Preview first rows - does it look right?
select * from calendar_new_orleans limit 10;

-- What columns exist and what type are they? data_type should all show up as "text".
select column_name, data_type
from information_schema.columns
where table_name = 'calendar_nyc'
order by ordinal_position;

-- Check nulls in key columns
select
  count(*) as total_rows,
  count(nullif(listing_id, '')) as has_listingid,
  count(nullif(date, '')) as has_date,
  count(nullif(available, '')) as has_availability,
  count(nullif(minimum_nights, '')) as has_min,
  count(nullif(maximum_nights, '')) as has_max
from calendar_new_orleans;
-- All columns have exactly the same number of rows as total.

-- Check distinct availability types.
select distinct available from calendar_new_orleans;

-- Check night ranges; looking for discrepancies.
-- Maximum nights should not be more than 365 days as a short term rental.
select
  min(minimum_nights::numeric) as min_min_nights,
  max(minimum_nights::numeric) as max_min_nights,
  min(maximum_nights::numeric) as min_max_nights,
  max(maximum_nights::numeric) as max_max_nights
from calendar_new_orleans
where minimum_nights != '' and maximum_nights != '';

-- How many listings have suspicious minimum nights? 366 --> needs to be cleaned.
select count(*) from calendar_new_orleans
where minimum_nights::numeric > 365;

-- How many have the garbage max value? Documented 862,893 / 2,269,570 --> deciding to exclude maximum_nights from analysis.
select count(*) from calendar_new_orleans
where maximum_nights::numeric > 1000;


-- ------------------------------------------------
-- REVIEWS_NEW_ORLEANS
-- ------------------------------------------------

-- Row counts; how many rows come through?
select count(*) from reviews_new_orleans;

-- Does it look right?
select * from reviews_new_orleans limit 10;

-- What is the review date range?
select min(date) as earliest, max(date) as latest from reviews_new_orleans where date != '';


-- ------------------------------------------------
-- NEIGHBOURHOODS_NEW_ORLEANS
-- ------------------------------------------------

-- Row counts; how many rows are there?
select count(*) from neighbourhoods_new_orleans;

-- Does it look right?
select * from neighbourhoods_new_orleans limit 10;

-- How many distinct neighbourhood groups exist?
select neighbourhood, count(*) as neighbourhood_count
from neighbourhoods_new_orleans
group by neighbourhood
order by neighbourhood_count desc;

