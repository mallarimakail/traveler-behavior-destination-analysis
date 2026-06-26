

-- ================================================
-- 01_create_tables.sql
-- Purpose: Create all raw tables for each city.
-- Last updated: 06-10-2026
-- ================================================

-- ------------------------------------------------
-- LISTINGS_NYC
-- ------------------------------------------------

create table if not exists listings_nyc (
  id text,
  listing_url text,
  scrape_id text,
  last_scraped text,
  source text,
  name text,
  description text,
  neighborhood_overview text,
  picture_url text,
  host_id text,
  host_url text,
  host_profile_id text,
  host_profile_url text,
  host_name text,
  host_since text,
  hosts_time_as_user_years text,
  hosts_time_as_user_months text,
  hosts_time_as_host_years text,
  hosts_time_as_host_months text,
  host_location text,
  host_about text,
  host_response_time text,
  host_response_rate text,
  host_acceptance_rate text,
  host_is_superhost text,
  host_thumbnail_url text,
  host_picture_url text,
  host_neighbourhood text,
  host_listings_count text,
  host_total_listings_count text,
  host_verifications text,
  host_has_profile_pic text,
  host_identity_verified text,
  neighbourhood text,
  neighbourhood_cleansed text,
  neighbourhood_group_cleansed text,
  latitude text,
  longitude text,
  property_type text,
  room_type text,
  accommodates text,
  bathrooms text,
  bathrooms_text text,
  bedrooms text,
  beds text,
  amenities text,
  price text,
  price_quote_checkin_date text,
  price_quote_checkout_date text,
  price_quote_total_price text,
  price_quote_price_per_night text,
  price_quote_raw text,
  minimum_nights text,
  maximum_nights text,
  minimum_minimum_nights text,
  maximum_minimum_nights text,
  minimum_maximum_nights text,
  maximum_maximum_nights text,
  minimum_nights_avg_ntm text,
  maximum_nights_avg_ntm text,
  calendar_updated text,
  has_availability text,
  availability_30 text,
  availability_60 text,
  availability_90 text,
  availability_365 text,
  calendar_last_scraped text,
  number_of_reviews text,
  number_of_reviews_ltm text,
  number_of_reviews_l30d text,
  availability_eoy text,
  number_of_reviews_ly text,
  estimated_occupancy_l365d text,
  estimated_revenue_l365d text,
  first_review text,
  last_review text,
  review_scores_rating text,
  review_scores_accuracy text,
  review_scores_cleanliness text,
  review_scores_checkin text,
  review_scores_communication text,
  review_scores_location text,
  review_scores_value text,
  license text,
  instant_bookable text,
  calculated_host_listings_count text,
  calculated_host_listings_count_entire_homes text,
  calculated_host_listings_count_private_rooms text,
  calculated_host_listings_count_shared_rooms text,
  reviews_per_month text
);


-- ------------------------------------------------
-- CALENDAR_NYC
-- ------------------------------------------------

create table if not exists calendar_nyc (
  listing_id text,
  date text,
  available text,
  minimum_nights text,
  maximum_nights text
);

-- ------------------------------------------------
-- REVIEWS_NYC
-- ------------------------------------------------

create table if not exists reviews_nyc (
  listing_id text,
  id text,
  date text,
  reviewer_id text,
  reviewer_name text,
  comments text
);


-- ------------------------------------------------
-- NEIGHBORHOODS_NYC
-- ------------------------------------------------

create table if not exists neighbourhoods_nyc (
  neighbourhood_group text,
  neighbourhood text
);


-- ------------------------------------------------
-- LISTINGS_MEXICO_CITY
-- ------------------------------------------------

create table if not exists listings_mexico_city (
  id text,
  name text,
  host_id text,
  host_profile_id text,
  host_name text,
  neighbourhood_group text,
  neighbourhood text,
  latitude text,
  longitude text,
  room_type text,
  price text,
  minimum_nights text,
  number_of_reviews text,
  last_review text,
  reviews_per_month text,
  calculated_host_listings_count text,
  availability_365 text,
  number_of_reviews_ltm text,
  license text
);


-- -----------------------------------------------
-- CALENDAR_MEXICO_CITY
-- -----------------------------------------------

create table if not exists calendar_mexico_city (like calendar_nyc including all);


-- -----------------------------------------------
-- REVIEWS_MEXICO_CITY
-- -----------------------------------------------

create table if not exists reviews_mexico_city (like reviews_nyc including all);


-- -----------------------------------------------
-- NEIGHBOURHOODS_MEXICO_CITY
-- -----------------------------------------------

create table if not exists neighbourhoods_mexico_city (like neighbourhoods_nyc including all);


-- -----------------------------------------------
-- LISTINGS_NEW_ORLEANS
-- -----------------------------------------------

create table if not exists listings_new_orleans (like listings_nyc including all);


-- -----------------------------------------------
-- CALENDAR_NEW_ORLEANS
-- -----------------------------------------------

create table if not exists calendar_new_orleans (like calendar_nyc including all);

-- -----------------------------------------------
-- REVIEWS_NEW_ORLEANS
-- -----------------------------------------------

create table if not exists reviews_new_orleans (like reviews_nyc including all);


-- -----------------------------------------------
-- NEIGHBOURHOODS_NEW_ORLEANS
-- -----------------------------------------------

create table if not exists neighbourhoods_new_orleans (like neighbourhoods_nyc including all);