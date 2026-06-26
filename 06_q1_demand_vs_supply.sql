-- ================================================
-- 06_q1_demand_vs_supply.sql
-- purpose: identify neighborhoods where demand exceeds
--          supply relative to city average
-- business question: where is demand growing faster than supply?
-- output: ranked shortlist of 3-5 neighborhoods per city
-- last updated: 2026-06-10
-- ================================================

-- ================================================
-- Q1 FINAL OUTPUT: PARTNERSHIP SHORTLIST
-- ================================================

-- nyc top opportunities (min 10 listings, short term only):
-- 1. gramercy -- 68% occupancy, $236 avg price (lag), opportunity signal
-- 2. gowanus -- 61% occupancy, $326 avg price (lag), highest review velocity (3.57)
-- 3. fort greene -- 60% occupancy, $343 avg price (lag), emerging brooklyn

-- mexico city top opportunities (prices in mxn):
-- 1. venustiano carranza -- 31% occupancy, 1,225 mxn (lag), highest review velocity (3.01)
-- 2. iztacalco -- 32% occupancy, 1,377 mxn (lag), emerging neighborhood
-- 3. coyoacán -- 30% occupancy, 1,977 mxn (lag), strong cultural content angle

-- new orleans top opportunities:
-- 1. irish channel -- 50% occupancy, $291 (lag), highest review velocity (2.67)
-- 2. fairgrounds -- 51% occupancy, $322 (lag), jazz fest event driven demand
-- 3. city park -- 55% occupancy, $311 (lag), highest occupancy in city

-- key cross-city finding:
-- all new orleans top neighborhoods show opportunity signal -- entire market is underpriced
-- mexico city cuauhtémoc (roma/condesa) is the only high demand + premium signal = saturated
-- nyc west village is saturated -- avoid for new partnerships


-- ================================================
-- CODE BELOW
-- ================================================

-- ------------------------------------------------
-- nyc
-- ------------------------------------------------

-- create a table identifying neighborhoods where demand exceeds
--   supply relative to city average
-- filter out neighborhoods with fewer than 10 listings to avoid skewed data

with city_avg_nyc as (
  select
    avg(occupancy_rate) as city_avg_occupancy,
    avg(price) as city_avg_price,
    avg(reviews_per_month) as city_avg_reviews
  from listings_nyc_clean
),
neighborhood_stats_nyc as (
  select
    neighbourhood_cleansed,
    neighbourhood_group_cleansed,
    count(*) as supply_count,
    round(avg(occupancy_rate), 4) as avg_occupancy,
    round(avg(price), 2) as avg_price,
    round(avg(reviews_per_month), 2) as avg_reviews_per_month
  from listings_nyc_clean
  group by neighbourhood_cleansed, neighbourhood_group_cleansed
)
select
  'NYC' as city,
  n.neighbourhood_cleansed,
  n.neighbourhood_group_cleansed,
  n.supply_count,
  n.avg_occupancy,
  n.avg_price,
  n.avg_reviews_per_month,
  round(c.city_avg_occupancy, 4) as city_avg_occupancy,
  round(c.city_avg_price, 2) as city_avg_price,
  case when n.avg_occupancy > c.city_avg_occupancy then 'above average' else 'below average' end as occupancy_tier,
  case when n.avg_price > c.city_avg_price then 'premium' else 'lag' end as pricing_tier,
  case
    when n.avg_occupancy > c.city_avg_occupancy and n.avg_price < c.city_avg_price then 'opportunity'
    when n.avg_occupancy > c.city_avg_occupancy and n.avg_price > c.city_avg_price then 'high demand'
    when n.avg_occupancy < c.city_avg_occupancy and n.avg_price > c.city_avg_price then 'overpriced'
    else 'low demand'
  end as market_signal
from neighborhood_stats_nyc n, city_avg_nyc c
where n.supply_count >= 10
order by avg_occupancy desc;



-- ------------------------------------------------
-- mexico city
-- ------------------------------------------------

with city_avg_cdmx as (
  select
    avg(occupancy_rate) as city_avg_occupancy,
    avg(price) as city_avg_price,
    avg(reviews_per_month) as city_avg_reviews
  from listings_mexico_city_clean
),
neighborhood_stats_cdmx as (
  select
    neighbourhood,
    count(*) as supply_count,
    round(avg(occupancy_rate), 4) as avg_occupancy,
    round(avg(price), 2) as avg_price,
    round(avg(reviews_per_month), 2) as avg_reviews_per_month
  from listings_mexico_city_clean
  group by neighbourhood
)
select
  'Mexico City' as city,
  n.neighbourhood,
  n.supply_count,
  n.avg_occupancy,
  n.avg_price,
  n.avg_reviews_per_month,
  round(c.city_avg_occupancy, 4) as city_avg_occupancy,
  round(c.city_avg_price, 2) as city_avg_price,
  case when n.avg_occupancy > c.city_avg_occupancy then 'above average' else 'below average' end as occupancy_tier,
  case when n.avg_price > c.city_avg_price then 'premium' else 'lag' end as pricing_tier,
  case
    when n.avg_occupancy > c.city_avg_occupancy and n.avg_price < c.city_avg_price then 'opportunity'
    when n.avg_occupancy > c.city_avg_occupancy and n.avg_price > c.city_avg_price then 'high demand'
    when n.avg_occupancy < c.city_avg_occupancy and n.avg_price > c.city_avg_price then 'overpriced'
    else 'low demand'
  end as market_signal
from neighborhood_stats_cdmx n, city_avg_cdmx c
where n.supply_count >= 10
order by avg_occupancy desc;



-- ------------------------------------------------
-- new orleans
-- ------------------------------------------------

with city_avg_nola as (
  select
    avg(occupancy_rate) as city_avg_occupancy,
    avg(price) as city_avg_price,
    avg(reviews_per_month) as city_avg_reviews
  from listings_new_orleans_clean
),
neighborhood_stats_nola as (
  select
    neighbourhood_cleansed,
    neighbourhood_group_cleansed,
    count(*) as supply_count,
    round(avg(occupancy_rate), 4) as avg_occupancy,
    round(avg(price), 2) as avg_price,
    round(avg(reviews_per_month), 2) as avg_reviews_per_month
  from listings_new_orleans_clean
  group by neighbourhood_cleansed, neighbourhood_group_cleansed
)
select
  'New Orleans' as city,
  n.neighbourhood_cleansed,
  n.supply_count,
  n.avg_occupancy,
  n.avg_price,
  n.avg_reviews_per_month,
  round(c.city_avg_occupancy, 4) as city_avg_occupancy,
  round(c.city_avg_price, 2) as city_avg_price,
  case when n.avg_occupancy > c.city_avg_occupancy then 'above average' else 'below average' end as occupancy_tier,
  case when n.avg_price > c.city_avg_price then 'premium' else 'lag' end as pricing_tier,
  case
    when n.avg_occupancy > c.city_avg_occupancy and n.avg_price < c.city_avg_price then 'opportunity'
    when n.avg_occupancy > c.city_avg_occupancy and n.avg_price > c.city_avg_price then 'high demand'
    when n.avg_occupancy < c.city_avg_occupancy and n.avg_price > c.city_avg_price then 'overpriced'
    else 'low demand'
  end as market_signal
from neighborhood_stats_nola n, city_avg_nola c
where n.supply_count >= 10
order by avg_occupancy desc;