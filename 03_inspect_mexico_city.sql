-- ================================================
-- 03_inspect_mexico_city.sql
-- Purpose: Inspect data for Mexico City.
-- Last updated: 06-10-2026
-- ================================================

-- ------------------------------------------------
-- LISTINGS_MEXICO_CITY
-- ------------------------------------------------

-- Row counts - how many rows come through?
select count(*) from listings_mexico_city;

-- Preview first rows - does it look right?
select * from listings_mexico_city limit 10;

-- What columns exist and what type are they? data_type should all show up as "text".
select column_name, data_type
from information_schema.columns
where table_name = 'listings_mexico_city'
order by ordinal_position;

-- Check nulls in key columns
select
  count(*) as total_rows,
  count(nullif(id, '')) as has_id,
  count(nullif(neighbourhood, '')) as has_neighbourhood,
  count(nullif(room_type, '')) as has_room_type,
  count(nullif(price, '')) as has_price,
  count(nullif(availability_365, '')) as has_availability,
  count(nullif(number_of_reviews, '')) as has_reviews,
  count(nullif(reviews_per_month, '')) as has_reviews_per_month,
  count(nullif(last_review, '')) as has_last_review
from listings_mexico_city;
-- NOTE:
-- 22,770 total rows
-- 22,369 has_price, 20,520 has_reviews_per_month
-- All others have the same rows as total rows.

-- Check distinct room types; looking for discrepancies.
select distinct room_type from listings_mexico_city;

-- What neighbourhood groups exist?
select distinct neighbourhood from listings_mexico_city;
-- NOTE: column neighbourhood_group is NULL.
	-- Column 'neighbourhood' contains the neighborhood groups in this dataset.


-- Check price and availability ranges; looking for discrepancies.
-- min_price should not be 0 & max_price may be an error to check later.
select
  min(replace(replace(price, '$', ''), ',', '')::numeric) as min_price,
  max(replace(replace(price, '$', ''), ',', '')::numeric) as max_price,
  min(availability_365::numeric) as min_availability,
  max(availability_365::numeric) as max_availability
from listings_mexico_city
where price != '' and availability_365 != '';

-- See the listings with suspiciously high prices.
  -- 400 listed as suspicious.
select count(*) as suspicious_count
from listings_mexico_city
where price::numeric > 10000;

-- See the actual filtered suspicious listings.
select id, name, neighbourhood, room_type, price
from listings_mexico_city
where price::numeric > 10000
order by price::numeric desc;


-- Check distribution of data.
-- How are listings spread across room types?
select
  room_type,
  count(*) as count,
  round(count(*) * 100.0 / sum(count(*)) over (), 1) as pct
from listings_mexico_city
group by room_type
order by count desc;

-- How are listings spread across neighbourhood groups?
select
  neighbourhood,
  count(*) as count,
  round(count(*) * 100.0 / sum(count(*)) over (), 1) as pct
from listings_mexico_city
group by neighbourhood
order by count desc;

-- Mexico City rental type breakdown
select
  case when minimum_nights::numeric < 30 then 'short term'
       when minimum_nights::numeric = 30 then 'monthly'
       else 'long term'
  end as rental_type,
  count(*) as count,
  round(count(*) * 100.0 / sum(count(*)) over (), 1) as pct
from listings_mexico_city
where minimum_nights != ''
group by rental_type
order by count desc;

-- Check review scores range for all cities.
	-- Following returns an error due to ratings not existing in data.

-- select
  -- min(review_scores_rating::numeric) as min_rating,
  -- max(review_scores_rating::numeric) as max_rating,
  -- count(nullif(review_scores_rating, '')) as has_rating,
  -- count(*) as total_rows
-- from listings_mexico_city
-- where review_scores_rating != '';

-- What columns exist and what type are they? data_type should all show up as "text".
select column_name, data_type
from information_schema.columns
where table_name = 'reviews_mexico_city'
order by ordinal_position;
-- No records of ratings in data. Exclude out of analysis.

-- Check availability range; confirm no impossible values over 365.
select
  min(availability_365::numeric) as min_avail,
  max(availability_365::numeric) as max_avail
from listings_mexico_city
where availability_365 != '';

-- how many mexico city listings above $10,000?
select count(*) as suspicious_count
from listings_mexico_city
where price::numeric > 10000;

-- view them
select id, name, neighbourhood, room_type, price
from listings_mexico_city
where price::numeric > 10000
order by price::numeric desc;

-- mexico city price findings:
-- prices are in mexican pesos, not usd
-- 1,268,545 mxn = ~$63,000 usd -- likely an error or special event pricing
-- top 3 prices (1,268,545 / 1,027,402 / 970,001 mxn) are suspicious outliers
-- remaining high-price listings appear to be legitimate luxury properties in condesa/roma
-- decision: filter out listings above 500,000 mxn (~$25,000 usd) as outliers
-- note in executive brief: mexico city prices are in mxn, not usd

-- Mexico City data freshness
select
  min(last_review::date) as earliest_review,
  max(last_review::date) as latest_review
from listings_mexico_city
where last_review != '';



-- ------------------------------------------------
-- CALENDAR_NYC
-- ------------------------------------------------

-- Row counts - how many rows come through?
select count(*) from calendar_mexico_city;

-- Preview first rows - does it look right?
select * from calendar_mexico_city limit 10;

-- What columns exist and what type are they? data_type should all show up as "text".
select column_name, data_type
from information_schema.columns
where table_name = 'calendar_mexico_city'
order by ordinal_position;

-- Check nulls in key columns
select
  count(*) as total_rows,
  count(nullif(listing_id, '')) as has_listingid,
  count(nullif(date, '')) as has_date,
  count(nullif(available, '')) as has_availability,
  count(nullif(minimum_nights, '')) as has_min,
  count(nullif(maximum_nights, '')) as has_max
from calendar_mexico_city;

-- Check distinct availability types.
select distinct available from calendar_mexico_city;

-- Check night ranges; looking for discrepancies.
-- Maximum nights should not be more than 365 days as a short term rental.
select
  min(minimum_nights::numeric) as min_min_nights,
  max(minimum_nights::numeric) as max_min_nights,
  min(maximum_nights::numeric) as min_max_nights,
  max(maximum_nights::numeric) as max_max_nights
from calendar_mexico_city
where minimum_nights != '' and maximum_nights != '';

-- How many listings have suspicious minimum nights? 99 --> needs to be cleaned.
select count(*) from calendar_mexico_city
where minimum_nights::numeric > 365;

-- How many have the garbage max value? Documented 3,839,050 / 8,311,079 --> deciding to exclude maximum_nights from analysis.
select count(*) from calendar_mexico_city
where maximum_nights::numeric > 1000;


-- ------------------------------------------------
-- REVIEWS_MEXICO_CITY
-- ------------------------------------------------

-- Row counts; how many rows come through?
select count(*) from reviews_mexico_city;

-- Does it look right?
select * from reviews_mexico_city limit 10;

-- What columns exist and what type are they? data_type should all show up as "text".
select column_name, data_type
from information_schema.columns
where table_name = 'reviews_mexico_city'
order by ordinal_position;

-- What is the review date range?
select min(date) as earliest, max(date) as latest from reviews_mexico_city where date != '';


-- ------------------------------------------------
-- NEIGHBOURHOODS_MEXICO_CITY
-- ------------------------------------------------

-- Row counts; how many rows are there?
select count(*) from neighbourhoods_mexico_city;

-- Does it look right?
select * from neighbourhoods_mexico_city limit 10;

-- How many distinct neighbourhood groups exist?
select neighbourhood_group, count(*) as neighbourhood_count
from neighbourhoods_mexico_city
group by neighbourhood_group
order by neighbourhood_count desc;


