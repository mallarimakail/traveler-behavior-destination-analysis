-- ================================================
-- 02_inspect_nyc.sql
-- Purpose: Inspect data for New York City.
-- Last updated: 06-10-2026
-- ================================================

-- ------------------------------------------------
-- LISTINGS_NYC
-- ------------------------------------------------

-- Row counts - how many rows come through?
select count(*) from listings_nyc;

-- Preview first rows - does it look right?
select * from listings_nyc limit 10;

-- What columns exist and what type are they? data_type should all show up as "text".
select column_name, data_type
from information_schema.columns
where table_name = 'listings_nyc'
order by ordinal_position;

-- Check nulls in key columns
select
  count(*) as total_rows,
  count(nullif(price, '')) as has_price,
  count(nullif(availability_365, '')) as has_availability,
  count(nullif(review_scores_rating, '')) as has_rating,
  count(nullif(neighbourhood_cleansed, '')) as has_neighbourhood
from listings_nyc;
-- NOTE:
-- Only 20,693 has a price out of 35,036.
-- Only 24,542 has a rating out of 35,036.

-- Check distinct room types; looking for discrepancies.
select distinct room_type from listings_nyc;

-- What neighbourhood groups exist?
select distinct neighbourhood_group_cleansed from listings_nyc;


-- Check price and availability ranges; looking for discrepancies.
-- min_price should not be 0 & max_price may be an error to check later.
select
  min(replace(replace(price, '$', ''), ',', '')::numeric) as min_price,
  max(replace(replace(price, '$', ''), ',', '')::numeric) as max_price,
  min(availability_365::numeric) as min_availability,
  max(availability_365::numeric) as max_availability
from listings_nyc
where price != '' and availability_365 != '';

-- Check distribution of data.
-- How are listings spread across room types?
select
  room_type,
  count(*) as count,
  round(count(*) * 100.0 / sum(count(*)) over (), 1) as pct
from listings_nyc
group by room_type
order by count desc;

-- How are listings spread across neighbourhood groups?
select
  neighbourhood_group_cleansed,
  count(*) as count,
  round(count(*) * 100.0 / sum(count(*)) over (), 1) as pct
from listings_nyc
group by neighbourhood_group_cleansed
order by count desc;

-- Look for listings above $5,000/night in NYC (sounds unrealistic).
select count(*) from listings_nyc
where replace(replace(price, '$', ''), ',', '')::numeric > 5000;

-- See exactly what price values look like.
select distinct price
from listings_nyc
where price like '%$%'
order by price desc
limit 20;

-- View the unreasonable listings.
select id, name, neighbourhood_cleansed, room_type, price
from listings_nyc
where regexp_replace(price, '[$,]', '', 'g')::numeric > 5000
order by regexp_replace(price, '[$,]', '', 'g')::numeric desc;

-- Check distribution of minimum nights in NYC. 
 -- Discovered 28,372 have a 30 day minimum --> majority of listings are long-term.
select minimum_nights, count(*) as count
from listings_nyc
where minimum_nights != ''
group by minimum_nights
order by count desc
limit 20;

-- What percentage are short term (under 30 nights) vs long term?
select
  case when minimum_nights::numeric < 30 then 'short term'
       when minimum_nights::numeric = 30 then 'monthly'
       else 'long term'
  end as rental_type,
  count(*) as count,
  round(count(*) * 100.0 / sum(count(*)) over (), 1) as pct
from listings_nyc
where minimum_nights != ''
group by rental_type
order by count desc;
-- NYC Findings: 81% are 30+ night monthly rentals, 15.8% are short term
    -- & 3.2% are long term rentals.
	-- Decision: filter to minimum_nights < 30 in a clean table for project.
	-- Note as a key limitation.


-- Check distribution of maximum nights in NYC.
select maximum_nights, count(*) as count
from listings_nyc 
where maximum_nights != ''
group by maximum_nights 
order by count desc
limit 20;
-- NYC maximum_nights Findings for listings_nyc:
-- 16,205 listings (46%) have maximum_nights = 1125 -- garbage value
-- combined with 81% monthly minimum_nights, this column is unreliable
-- decision: drop maximum_nights from listings_nyc_clean entirely



-- NYC CLEANING DECISIONS:
-- Price: no upper limit filter -- all high price listings verified as legitimate luxury properties
-- Price: no $0 listings found -- no lower limit filter needed
-- availability_365: filter out blanks and nulls
-- minimum_nights: filter out > 365 (14,418 rows)
-- maximum_nights: drop column entirely (46% garbage values)
-- neighbourhood_cleansed: filter out blanks and nulls
-- All columns imported as TEXT -- cast to correct types in clean table

-- Check review scores range for all three cities.
select
  min(review_scores_rating::numeric) as min_rating,
  max(review_scores_rating::numeric) as max_rating,
  count(nullif(review_scores_rating, '')) as has_rating,
  count(*) as total_rows
from listings_nyc
where review_scores_rating != '';

-- Check availability range; confirm no impossible values over 365.
select
  min(availability_365::numeric) as min_avail,
  max(availability_365::numeric) as max_avail
from listings_nyc
where availability_365 != '';

-- NYC data freshness
select
  min(last_review::date) as earliest_review,
  max(last_review::date) as latest_review
from listings_nyc
where last_review != '';



-- ------------------------------------------------
-- CALENDAR_NYC
-- ------------------------------------------------

-- Row counts - how many rows come through?
select count(*) from calendar_nyc;

-- Preview first rows - does it look right?
select * from calendar_nyc limit 10;

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
from calendar_nyc;

-- Check distinct availability types.
select distinct available from calendar_nyc;

-- Check night ranges; looking for discrepancies.
-- Maximum nights should not be more than 365 days as a short term rental.
select
  min(minimum_nights::numeric) as min_min_nights,
  max(minimum_nights::numeric) as max_min_nights,
  min(maximum_nights::numeric) as min_max_nights,
  max(maximum_nights::numeric) as max_max_nights
from calendar_nyc
where minimum_nights != '' and maximum_nights != '';

-- How many listings have suspicious minimum nights? 14,418 --> needs to be cleaned.
select count(*) from calendar_nyc
where minimum_nights::numeric > 365;

-- How many have the garbage max value? Documented 5,833,254 / 12,788,141 --> deciding to exclude maximum_nights from analysis.
select count(*) from calendar_nyc
where maximum_nights::numeric > 1000;


-- ------------------------------------------------
-- REVIEWS_NYC
-- ------------------------------------------------

-- Row counts; how many rows come through?
select count(*) from reviews_nyc;

-- Does it look right?
select * from reviews_nyc limit 10;

-- What is the review date range?
select min(date) as earliest, max(date) as latest from reviews_nyc where date != '';


-- ------------------------------------------------
-- NEIGHBOURHOODS_NYC
-- ------------------------------------------------

-- Row counts; how many rows are there?
select count(*) from neighbourhoods_nyc;

-- Does it look right?
select * from neighbourhoods_nyc limit 10;

-- How many distinct neighbourhood groups exist?
select neighbourhood_group, count(*) as neighbourhood_count
from neighbourhoods_nyc
group by neighbourhood_group
order by neighbourhood_count desc;