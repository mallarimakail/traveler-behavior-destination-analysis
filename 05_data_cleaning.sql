-- ================================================
-- 05_data_cleaning.sql
-- purpose: create clean versions of raw listing tables
-- last updated: 2026-06-10
-- ================================================

-- ================================================
-- INSPECTION FINDINGS SUMMARY
-- ================================================

-- PRICES:
-- nyc: prices in usd, range verified --> no $0 listings, max $12,279 (verified luxury)
--      no upper or lower price filter needed
-- mexico city: prices in mexican pesos (mxn), not usd
--              filter out listings above 500,000 mxn (~$25,000 usd) as outliers
--              top 3 listings (1.2m / 1.0m / 970k mxn) confirmed suspicious
--              note: divide by ~20 for usd equivalent in cross-city comparisons
-- new orleans: prices in usd, max $8,137 verified as legitimate (mardi gras/jazz fest)
--              no upper or lower price filter needed

-- MINIMUM NIGHTS:
-- nyc: 81% of listings require 30+ night minimum --> likely impact of local law 18 (2023)
--      filter to minimum_nights < 30  --> reduces from 35,036 to ~5,539 short-term listings
--      flag as key limitation in executive brief
-- mexico city: 100% short term --> no filter needed
-- new orleans: 65% short term, 33.6% monthly
--              filter to minimum_nights < 30 for travel analysis

-- MAXIMUM NIGHTS:
-- nyc: 16,205 listings (46%) have garbage value of 1,125 --> drop column entirely
-- mexico city: column does not exist in source data --> nothing to do
-- new orleans: 2,428 listings have garbage value of 1,125 --> drop column entirely

-- REVIEW SCORES:
-- nyc: range 0.0 - 5.0, 24,542 out of 35,036 listings have a rating (70% coverage)
--      ratings of 0.0 are suspicious --> filter out in clean table
-- mexico city: no review_scores_rating column in source data
--              q3 attribute analysis will use occupancy and price only
-- new orleans: range 1.0 - 5.0, 5,370 out of 6,218 listings have a rating (86% coverage)
--              clean range, filter nulls and blanks only

-- AVAILABILITY:
-- all three cities: range 0-365, no impossible values
-- filter nulls and blanks only

-- RENTAL TYPE BREAKDOWN:
-- nyc: 15.8% short term / 81.0% monthly / 3.2% long term
-- mexico city: 100% short term
-- new orleans: 65% short term / 33.6% monthly / 1.4% long term

-- DATA FRESHNESS:
-- nyc: 2011-05-12 to 2026-04-15 -- data is current
-- mexico city: 2015-11-01 to 2026-04-02 -- data is current
-- new orleans: 2014-04-08 to 2026-03-18 -- data is current
-- decision: no date filtering needed

-- CALENDAR DATA (nyc only fully inspected):
-- maximum_nights: 46% garbage values across all cities --> drop from calendar clean tables
-- minimum_nights: 14,418 rows > 365 nights in nyc --> filter out in cleaning

-- KEY LIMITATIONS TO NOTE IN EXECUTIVE BRIEF:
-- 1. nyc short-term rental market severely restricted by local law 18 (2023)
--    only 5,539 of 35,036 listings are short-term --> analysis reflects a regulated market
-- 2. mexico city prices are in mxn not usd --> not directly comparable to nyc/new orleans
-- 3. mexico city has no review scores column --> q3 analysis excludes mexico city
-- 4. occupancy rate is estimated from availability calendar, not actual booking records
-- 5. data reflects a single snapshot --> supply growth trends require longitudinal data
-- ================================================



-- ================================================
-- SECTION 1: NYC LISTINGS CLEAN
-- ================================================

create table if not exists  listings_nyc_clean as
select
  id,
  name,
  neighbourhood_cleansed,
  neighbourhood_group_cleansed,
  latitude::numeric as latitude,
  longitude::numeric as longitude,
  property_type,
  room_type,
  accommodates::int as accommodates,
  bedrooms::numeric as bedrooms,
  beds::numeric as beds,
  regexp_replace(price, '[$,]', '', 'g')::numeric as price,
  availability_365::int as availability_365,
  round((365 - availability_365::numeric) / 365, 4) as occupancy_rate,
  minimum_nights::int as minimum_nights,
  number_of_reviews::int as number_of_reviews,
  reviews_per_month::numeric as reviews_per_month,
  review_scores_rating::numeric as review_scores_rating,
  review_scores_cleanliness::numeric as review_scores_cleanliness,
  review_scores_location::numeric as review_scores_location,
  review_scores_value::numeric as review_scores_value,
  instant_bookable,
  host_is_superhost,
  calculated_host_listings_count::int as calculated_host_listings_count,
  estimated_occupancy_l365d::numeric as estimated_occupancy_l365d,
  estimated_revenue_l365d::numeric as estimated_revenue_l365d,
  last_review::date as last_review,
  host_since::date as host_since
from listings_nyc
where
  price != '' and price is not null
  and availability_365 != '' and availability_365 is not null
  and neighbourhood_cleansed != '' and neighbourhood_cleansed is not null
  and regexp_replace(price, '[$,]', '', 'g')::numeric > 0
  and review_scores_rating::numeric > 0
  and minimum_nights::int < 30;

select count(*) from listings_nyc_clean;
-- listings_nyc_clean: 4,297 rows
-- down from 35,036 raw listings
-- filters applied: short term only (< 30 nights), no blank prices,
--                  no blank neighbourhoods, no $0 prices,
--                  no zero review scores


-- ================================================
-- SECTION 2: MEXICO CITY LISTINGS CLEAN
-- ================================================

create table if not exists listings_mexico_city_clean as
select
  id,
  name,
  neighbourhood,
  latitude::numeric as latitude,
  longitude::numeric as longitude,
  room_type,
  price::numeric as price,
  round((365 - availability_365::numeric) / 365, 4) as occupancy_rate,
  availability_365::int as availability_365,
  minimum_nights::int as minimum_nights,
  number_of_reviews::int as number_of_reviews,
  reviews_per_month::numeric as reviews_per_month,
  calculated_host_listings_count::int as calculated_host_listings_count,
  last_review::date as last_review
from listings_mexico_city
where
  price != '' and price is not null
  and availability_365 != '' and availability_365 is not null
  and neighbourhood != '' and neighbourhood is not null
  and price::numeric > 0
  and price::numeric < 500000;

select count(*) from listings_mexico_city_clean;
-- listings_mexico_city_clean: 22,366 rows
-- down from raw listings after filters applied
-- filters applied: no blank prices, no blank neighbourhoods,
--                  no $0 prices, removed outliers above 500,000 mxn
-- note: prices in mxn not usd -- divide by ~20 for usd equivalent
-- no minimum nights filter needed -- 100% short term market
-- no review scores column in source data



-- ================================================
-- SECTION 3: NEW ORLEANS LISTINGS CLEAN
-- ================================================

create table listings_new_orleans_clean as
select
  id,
  name,
  neighbourhood_cleansed,
  neighbourhood_group_cleansed,
  latitude::numeric as latitude,
  longitude::numeric as longitude,
  property_type,
  room_type,
  accommodates::int as accommodates,
  bedrooms::numeric as bedrooms,
  beds::numeric as beds,
  regexp_replace(price, '[$,]', '', 'g')::numeric as price,
  availability_365::int as availability_365,
  round((365 - availability_365::numeric) / 365, 4) as occupancy_rate,
  minimum_nights::int as minimum_nights,
  number_of_reviews::int as number_of_reviews,
  reviews_per_month::numeric as reviews_per_month,
  review_scores_rating::numeric as review_scores_rating,
  review_scores_cleanliness::numeric as review_scores_cleanliness,
  review_scores_location::numeric as review_scores_location,
  review_scores_value::numeric as review_scores_value,
  instant_bookable,
  host_is_superhost,
  calculated_host_listings_count::int as calculated_host_listings_count,
  estimated_occupancy_l365d::numeric as estimated_occupancy_l365d,
  estimated_revenue_l365d::numeric as estimated_revenue_l365d,
  last_review::date as last_review,
  host_since::date as host_since
from listings_new_orleans
where
  price != '' and price is not null
  and availability_365 != '' and availability_365 is not null
  and neighbourhood_cleansed != '' and neighbourhood_cleansed is not null
  and regexp_replace(price, '[$,]', '', 'g')::numeric > 0
  and minimum_nights::int < 30;

select count(*) from listings_new_orleans_clean;
-- listings_new_orleans_clean: 3,914 rows
-- down from 6,218 raw listings
-- filters applied: short term only (< 30 nights), no blank prices,
--                  no blank neighbourhoods, no $0 prices





-- ================================================
-- SECTION 4: CALENDAR CLEAN (ALL CITIES)
-- ================================================

create table if not exists calendar_nyc_clean as
select
  listing_id,
  date::date as date,
  available,
  minimum_nights::int as minimum_nights
from calendar_nyc
where
  listing_id != '' and listing_id is not null
  and date != '' and date is not null
  and minimum_nights != '' and minimum_nights is not null
  and minimum_nights::int <= 365;

create table if not exists calendar_mexico_city_clean as
select
  listing_id,
  date::date as date,
  available,
  minimum_nights::int as minimum_nights
from calendar_mexico_city
where
  listing_id != '' and listing_id is not null
  and date != '' and date is not null
  and minimum_nights != '' and minimum_nights is not null
  and minimum_nights::int <= 365;

create table if not exists calendar_new_orleans_clean as
select
  listing_id,
  date::date as date,
  available,
  minimum_nights::int as minimum_nights
from calendar_new_orleans
where
  listing_id != '' and listing_id is not null
  and date != '' and date is not null
  and minimum_nights != '' and minimum_nights is not null
  and minimum_nights::int <= 365;

-- Verify all three exist.
select 'calendar_nyc_clean' as table_name, count(*) from calendar_nyc_clean
union all
select 'calendar_mexico_city_clean', count(*) from calendar_mexico_city_clean
union all
select 'calendar_new_orleans_clean', count(*) from calendar_new_orleans_clean;

-- calendar clean table row counts:
-- calendar_nyc_clean: 12,773,723 rows (down from 12,788,141 -- removed 14,418 bad minimum nights rows)
-- calendar_mexico_city_clean: 8,310,980 rows
-- calendar_new_orleans_clean: 2,269,204 rows (down from 2,269,570 -- minimal rows removed)



