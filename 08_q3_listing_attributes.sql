-- ================================================
-- 08_q3_listing_attributes.sql
-- purpose: identify which listing attributes correlate
--          most strongly with occupancy and rating
-- business question: what do high performing listings
--          tell us about what travelers want?
-- note: mexico city excluded from rating analysis
--       (no review_scores_rating column in source data)
-- last updated: 2026-06-10
-- ================================================


-- ================================================
-- q3 tiered advisory framework
-- based on correlation with occupancy rate and rating
-- across nyc and new orleans (mexico city excluded --
-- no review scores in source data)
-- ================================================

-- tier 1: top priorities (strongest correlation with occupancy)
-- ---------------------------------------------------------------
-- 1. cleanliness score
--    nyc: score 5 vs 4 = 11% occupancy drop
--    new orleans: score 5 vs 4 = 52% occupancy drop
--    recommendation: partners must maintain 5.0 cleanliness -- non negotiable
--
-- 2. location score
--    nyc: score 5 vs 4 = 21% occupancy drop
--    new orleans: score 5 vs 4 = 24% occupancy drop
--    recommendation: prioritize well-located properties over cheaper peripheral ones
--
-- 3. superhost status
--    nyc: superhost vs non = 8.5% occupancy gap
--    new orleans: superhost vs non = 21.7% occupancy gap
--    recommendation: only partner with superhost properties where possible

-- tier 2: nice to haves (moderate correlation)
-- ---------------------------------------------------------------
-- 1. value score
--    nyc: score 5 vs 4 = 14% occupancy drop
--    new orleans: score 5 vs 4 = 47% occupancy drop
--    recommendation: partners should avoid overpricing -- hurts both occupancy and rating
--
-- 2. room type
--    entire home/apt outperforms in all three cities
--    recommendation: prioritize entire home partnerships over private/shared rooms
--
-- 3. accommodation size
--    sweet spot: 2-4 guests in both cities
--    large group listings (8+) consistently underperform
--    recommendation: focus content on small-medium sized properties

-- tier 3: no meaningful impact
-- ---------------------------------------------------------------
-- 1. instant_bookable
--    fully null in source data -- could not be analyzed
--    flag for future data collection
--
-- 2. price alone
--    high priced listings do not consistently outperform on occupancy
--    score 3 value listings in nyc charge most ($562) but have 27% occupancy
--    recommendation: price is not a performance driver -- quality scores are

-- cross city finding:
-- new orleans shows stronger penalties for low scores than nyc
-- quality matters more in seasonal markets than year-round destinations
-- partners in new orleans must maintain higher quality standards
--    to survive the off-peak season




-- ------------------------------------------------
-- section 1: performance by room type
-- ------------------------------------------------

-- nyc room type performance
select
  'NYC' as city,
  room_type,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(review_scores_rating), 2) as avg_rating,
  round(avg(price), 2) as avg_price
from listings_nyc_clean
group by room_type
order by avg_occupancy desc;



-- mexico city room type performance
select
  'Mexico City' as city,
  room_type,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(price), 2) as avg_price
from listings_mexico_city_clean
group by room_type
order by avg_occupancy desc;



-- new orleans room type performance
select
  'New Orleans' as city,
  room_type,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(review_scores_rating), 2) as avg_rating,
  round(avg(price), 2) as avg_price
from listings_new_orleans_clean
group by room_type
order by avg_occupancy desc;



-- section 2: performance by instant bookable
select
  'NYC' as city,
  instant_bookable,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(review_scores_rating), 2) as avg_rating,
  round(avg(price), 2) as avg_price
from listings_nyc_clean
group by instant_bookable
order by avg_occupancy desc;

select
  'New Orleans' as city,
  instant_bookable,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(review_scores_rating), 2) as avg_rating,
  round(avg(price), 2) as avg_price
from listings_new_orleans_clean
group by instant_bookable
order by avg_occupancy desc;



-- check what instant_bookable looks like in raw table
select distinct instant_bookable, count(*) as count
from listings_nyc
group by instant_bookable;

-- confirm new orleans
select distinct instant_bookable, count(*) as count
from listings_new_orleans
group by instant_bookable;

-- instant_bookable: fully null in both nyc and new orleans raw data
-- attribute cannot be analyzed -- excluded from q3 framework




-- section 3: performance by superhost status
	-- not available for mexico city.

-- nyc
select
  'NYC' as city,
  host_is_superhost,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(review_scores_rating), 2) as avg_rating,
  round(avg(price), 2) as avg_price
from listings_nyc_clean
group by host_is_superhost
order by avg_occupancy desc;

-- new orleans
select
  'New Orleans' as city,
  host_is_superhost,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(review_scores_rating), 2) as avg_rating,
  round(avg(price), 2) as avg_price
from listings_new_orleans_clean
group by host_is_superhost
order by avg_occupancy desc;




-- section 4: performance by accommodation size
	-- not found in mexico city dataset.

-- nyc
select
  'NYC' as city,
  accommodates,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(review_scores_rating), 2) as avg_rating,
  round(avg(price), 2) as avg_price
from listings_nyc_clean
group by accommodates
order by accommodates asc;



-- new orleans
select
  'New Orleans' as city,
  accommodates,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(review_scores_rating), 2) as avg_rating,
  round(avg(price), 2) as avg_price
from listings_new_orleans_clean
group by accommodates
order by accommodates asc;




-- section 5: performance by cleanliness score

-- nyc
select
  'NYC' as city,
  round(review_scores_cleanliness, 0) as cleanliness_score,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(review_scores_rating), 2) as avg_rating,
  round(avg(price), 2) as avg_price
from listings_nyc_clean
where review_scores_cleanliness is not null
group by round(review_scores_cleanliness, 0)
order by cleanliness_score desc;


-- new orleans
select
  'New Orleans' as city,
  round(review_scores_cleanliness, 0) as cleanliness_score,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(review_scores_rating), 2) as avg_rating,
  round(avg(price), 2) as avg_price
from listings_new_orleans_clean
where review_scores_cleanliness is not null
group by round(review_scores_cleanliness, 0)
order by cleanliness_score desc;




-- section 6: performance by location score

-- nyc
select
  'NYC' as city,
  round(review_scores_location, 0) as location_score,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(review_scores_rating), 2) as avg_rating,
  round(avg(price), 2) as avg_price
from listings_nyc_clean
where review_scores_location is not null
group by round(review_scores_location, 0)
order by location_score desc;


-- new orleans
select
  'New Orleans' as city,
  round(review_scores_location, 0) as location_score,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(review_scores_rating), 2) as avg_rating,
  round(avg(price), 2) as avg_price
from listings_new_orleans_clean
where review_scores_location is not null
group by round(review_scores_location, 0)
order by location_score desc;




-- section 7: performance by value score

-- nyc
select
  'NYC' as city,
  round(review_scores_value, 0) as value_score,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(review_scores_rating), 2) as avg_rating,
  round(avg(price), 2) as avg_price
from listings_nyc_clean
where review_scores_value is not null
group by round(review_scores_value, 0)
order by value_score desc;


-- new orleans
select
  'New Orleans' as city,
  round(review_scores_value, 0) as value_score,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(review_scores_rating), 2) as avg_rating,
  round(avg(price), 2) as avg_price
from listings_new_orleans_clean
where review_scores_value is not null
group by round(review_scores_value, 0)
order by value_score desc;