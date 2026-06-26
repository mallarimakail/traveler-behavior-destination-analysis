-- ================================================
-- 09_q4_market_entry.sql
-- purpose: identify markets where a new entrant
--          could compete on price
-- business question: are there markets where a new
--          entrant could compete on price?
-- output: 2-3 market assessments with go/no-go signal
-- last updated: 2026-06-10
-- ================================================


-- ================================================
-- q4 findings summary & market assessments
-- ================================================

-- ------------------------------------------------
-- city level price variance summary
-- ------------------------------------------------
-- nyc: cv 1.17 -- high variance, chaotic pricing
--      avg occupancy 41%, avg price $346
--      discounting finding: marginal occupancy gains below $200
--      conclusion: discounting compresses margins more than drives bookings

-- mexico city: cv 1.79 -- highest variance of all three cities
--              avg occupancy 30%, avg price 2,254 mxn
--              discounting finding: cheap listings (under 500 mxn) underperform
--              travelers use price as quality signal -- do not compete on low price
--              conclusion: price at 1000-1999 mxn range to signal quality

-- new orleans: cv 0.94 -- most stable pricing of all three cities
--              avg occupancy 34%, avg price $358
--              discounting finding: under $100 listings hit 51% occupancy
--              but ratings are lower -- drives bookings but risks quality perception
--              conclusion: strategic discounting works in new orleans
--                         but only if quality scores are maintained

-- ------------------------------------------------
-- market assessments: go/no-go signals
-- ------------------------------------------------

-- market 1: new orleans -- GO
-- strongest case for new entrant across all three cities
-- nearly every top neighborhood shows go signal
-- entire market is underpriced relative to demand
-- top opportunities:
--   irish channel: 50% occupancy, $291 avg price (-$67 below city avg)
--   city park: 55% occupancy, $312 avg price (-$47 below city avg)
--   fairgrounds: 51% occupancy, $323 avg price, volatile market = pricing opportunity
-- rationale: consistent demand, underpriced market, clear seasonal peak
--            new entrant with well-priced quality listings can capture
--            significant market share during mardi gras season
-- go signal: strong

-- market 2: mexico city (iztacalco & venustiano carranza) -- GO
-- two emerging neighborhoods with strong go signals
-- iztacalco: 32% occupancy (above 30% avg), 1,377 mxn (-877 mxn below city avg)
-- venustiano carranza: 31% occupancy, 1,225 mxn (-1,030 mxn below city avg)
--                      highest review velocity (3.01/month)
-- rationale: 100% short term market, no regulatory risk (unlike nyc)
--            price at 1,500-2,000 mxn range to signal quality
--            while undercutting cuauhtémoc premium pricing
--            strong cultural tourism growth post-covid
-- go signal: moderate -- currency conversion complexity for foreign partners

-- market 3: nyc (gramercy & gowanus) -- MONITOR
-- gramercy: 68% occupancy, $236 avg price (-$110 below city avg), cv 0.91
-- gowanus: 61% occupancy, $326 avg price (-$20 below city avg), cv 0.82
-- rationale: strong demand signals but nyc market heavily regulated
--            local law 18 restricts short term rentals severely
--            only 4,297 short term listings remain in entire city
--            new entrant faces significant regulatory and legal risk
--            discounting shows minimal incremental booking gains
-- go signal: no go for new operators -- monitor for content partnerships only

-- ------------------------------------------------
-- cross city discounting conclusion
-- ------------------------------------------------
-- discounting drives bookings in new orleans (under $100 = 51% occupancy)
-- discounting hurts perception in mexico city (cheap = low quality signal)
-- discounting has minimal impact in nyc (regulated, mature market)
-- recommendation: discount strategy only appropriate for new orleans
--                 and only when paired with strong quality scores



-- ------------------------------------------------
-- section 1: city level price vs occupancy overview
-- ------------------------------------------------

select
  'NYC' as city,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(price), 2) as avg_price,
  round(stddev(price), 2) as price_stddev,
  round(stddev(price) / nullif(avg(price), 0), 4) as coeff_of_variation,
  round(min(price), 2) as min_price,
  round(max(price), 2) as max_price
from listings_nyc_clean
union all
select
  'Mexico City' as city,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(price), 2) as avg_price,
  round(stddev(price), 2) as price_stddev,
  round(stddev(price) / nullif(avg(price), 0), 4) as coeff_of_variation,
  round(min(price), 2) as min_price,
  round(max(price), 2) as max_price
from listings_mexico_city_clean
union all
select
  'New Orleans' as city,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(price), 2) as avg_price,
  round(stddev(price), 2) as price_stddev,
  round(stddev(price) / nullif(avg(price), 0), 4) as coeff_of_variation,
  round(min(price), 2) as min_price,
  round(max(price), 2) as max_price
from listings_new_orleans_clean;



-- ------------------------------------------------
-- section 2: price buckets vs occupancy
-- does discounting drive incremental bookings?
-- ------------------------------------------------

select
  'NYC' as city,
  case
    when price < 100 then '1. under $100'
    when price between 100 and 199 then '2. $100-$199'
    when price between 200 and 299 then '3. $200-$299'
    when price between 300 and 399 then '4. $300-$399'
    when price between 400 and 499 then '5. $400-$499'
    when price between 500 and 699 then '6. $500-$699'
    else '7. $700+'
  end as price_bucket,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(review_scores_rating), 2) as avg_rating
from listings_nyc_clean
group by price_bucket
order by price_bucket;



-- mexico city in mxn buckets
select
  'Mexico City' as city,
  case
    when price < 500 then '1. under 500 mxn'
    when price between 500 and 999 then '2. 500-999 mxn'
    when price between 1000 and 1999 then '3. 1000-1999 mxn'
    when price between 2000 and 2999 then '4. 2000-2999 mxn'
    when price between 3000 and 4999 then '5. 3000-4999 mxn'
    when price between 5000 and 9999 then '6. 5000-9999 mxn'
    else '7. 10000+ mxn'
  end as price_bucket,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy
from listings_mexico_city_clean
group by price_bucket
order by price_bucket;



select
  'New Orleans' as city,
  case
    when price < 100 then '1. under $100'
    when price between 100 and 199 then '2. $100-$199'
    when price between 200 and 299 then '3. $200-$299'
    when price between 300 and 399 then '4. $300-$399'
    when price between 400 and 499 then '5. $400-$499'
    when price between 500 and 699 then '6. $500-$699'
    else '7. $700+'
  end as price_bucket,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(review_scores_rating), 2) as avg_rating
from listings_new_orleans_clean
group by price_bucket
order by price_bucket;




-- ------------------------------------------------
-- section 3: neighborhood price vs occupancy gap
-- identifies most underpriced neighborhoods
-- ------------------------------------------------

-- nyc neighborhood price vs occupancy gap
with nyc_stats as (
  select
    'NYC' as city,
    neighbourhood_cleansed as neighbourhood,
    neighbourhood_group_cleansed as area,
    count(*) as listing_count,
    round(avg(occupancy_rate), 4) as avg_occupancy,
    round(avg(price), 2) as avg_price,
    round(stddev(price), 2) as price_stddev,
    round(stddev(price) / nullif(avg(price), 0), 4) as coeff_of_variation
  from listings_nyc_clean
  group by neighbourhood_cleansed, neighbourhood_group_cleansed
  having count(*) >= 10
),
nyc_city_avg as (
  select
    avg(occupancy_rate) as city_avg_occupancy,
    avg(price) as city_avg_price
  from listings_nyc_clean
)
select
  n.city,
  n.neighbourhood,
  n.area,
  n.listing_count,
  n.avg_occupancy,
  n.avg_price,
  n.coeff_of_variation,
  round(c.city_avg_occupancy::numeric, 4) as city_avg_occupancy,
  round(c.city_avg_price::numeric, 2) as city_avg_price,
  round((n.avg_occupancy - c.city_avg_occupancy::numeric) * 100, 2) as occupancy_gap_pct,
  round((n.avg_price - c.city_avg_price::numeric), 2) as price_gap,
  case
    when n.avg_occupancy > c.city_avg_occupancy
      and n.avg_price < c.city_avg_price
      and n.coeff_of_variation > 0.8 then 'GO -- high demand, underpriced, volatile market'
    when n.avg_occupancy > c.city_avg_occupancy
      and n.avg_price < c.city_avg_price then 'GO -- high demand, underpriced'
    when n.avg_occupancy > c.city_avg_occupancy
      and n.avg_price > c.city_avg_price then 'MONITOR -- high demand, already premium'
    when n.avg_occupancy < c.city_avg_occupancy
      and n.avg_price < c.city_avg_price then 'NO GO -- low demand, low price'
    else 'NO GO -- overpriced relative to demand'
  end as market_signal
from nyc_stats n, nyc_city_avg c
order by occupancy_gap_pct desc, price_gap asc;



-- mexico city neighborhood price vs occupancy gap
with cdmx_stats as (
  select
    'Mexico City' as city,
    neighbourhood,
    count(*) as listing_count,
    round(avg(occupancy_rate), 4) as avg_occupancy,
    round(avg(price), 2) as avg_price,
    round(stddev(price), 2) as price_stddev,
    round(stddev(price) / nullif(avg(price), 0), 4) as coeff_of_variation
  from listings_mexico_city_clean
  group by neighbourhood
  having count(*) >= 10
),
cdmx_city_avg as (
  select
    avg(occupancy_rate) as city_avg_occupancy,
    avg(price) as city_avg_price
  from listings_mexico_city_clean
)
select
  n.city,
  n.neighbourhood,
  n.listing_count,
  n.avg_occupancy,
  n.avg_price,
  n.coeff_of_variation,
  round(c.city_avg_occupancy::numeric, 4) as city_avg_occupancy,
  round(c.city_avg_price::numeric, 2) as city_avg_price,
  round((n.avg_occupancy - c.city_avg_occupancy::numeric) * 100, 2) as occupancy_gap_pct,
  round((n.avg_price - c.city_avg_price::numeric), 2) as price_gap,
  case
    when n.avg_occupancy > c.city_avg_occupancy
      and n.avg_price < c.city_avg_price
      and n.coeff_of_variation > 0.8 then 'GO -- high demand, underpriced, volatile market'
    when n.avg_occupancy > c.city_avg_occupancy
      and n.avg_price < c.city_avg_price then 'GO -- high demand, underpriced'
    when n.avg_occupancy > c.city_avg_occupancy
      and n.avg_price > c.city_avg_price then 'MONITOR -- high demand, already premium'
    when n.avg_occupancy < c.city_avg_occupancy
      and n.avg_price < c.city_avg_price then 'NO GO -- low demand, low price'
    else 'NO GO -- overpriced relative to demand'
  end as market_signal
from cdmx_stats n, cdmx_city_avg c
order by occupancy_gap_pct desc, price_gap asc;



-- new orleans neighborhood price vs occupancy gap
with nola_stats as (
  select
    'New Orleans' as city,
    neighbourhood_cleansed as neighbourhood,
    neighbourhood_group_cleansed as area,
    count(*) as listing_count,
    round(avg(occupancy_rate), 4) as avg_occupancy,
    round(avg(price), 2) as avg_price,
    round(stddev(price), 2) as price_stddev,
    round(stddev(price) / nullif(avg(price), 0), 4) as coeff_of_variation
  from listings_new_orleans_clean
  group by neighbourhood_cleansed, neighbourhood_group_cleansed
  having count(*) >= 10
),
nola_city_avg as (
  select
    avg(occupancy_rate) as city_avg_occupancy,
    avg(price) as city_avg_price
  from listings_new_orleans_clean
)
select
  n.city,
  n.neighbourhood,
  n.area,
  n.listing_count,
  n.avg_occupancy,
  n.avg_price,
  n.coeff_of_variation,
  round(c.city_avg_occupancy::numeric, 4) as city_avg_occupancy,
  round(c.city_avg_price::numeric, 2) as city_avg_price,
  round((n.avg_occupancy - c.city_avg_occupancy::numeric) * 100, 2) as occupancy_gap_pct,
  round((n.avg_price - c.city_avg_price::numeric), 2) as price_gap,
  case
    when n.avg_occupancy > c.city_avg_occupancy
      and n.avg_price < c.city_avg_price
      and n.coeff_of_variation > 0.8 then 'GO -- high demand, underpriced, volatile market'
    when n.avg_occupancy > c.city_avg_occupancy
      and n.avg_price < c.city_avg_price then 'GO -- high demand, underpriced'
    when n.avg_occupancy > c.city_avg_occupancy
      and n.avg_price > c.city_avg_price then 'MONITOR -- high demand, already premium'
    when n.avg_occupancy < c.city_avg_occupancy
      and n.avg_price < c.city_avg_price then 'NO GO -- low demand, low price'
    else 'NO GO -- overpriced relative to demand'
  end as market_signal
from nola_stats n, nola_city_avg c
order by occupancy_gap_pct desc, price_gap asc;