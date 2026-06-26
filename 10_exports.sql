-- ================================================
-- 10_exports.sql
-- purpose: final export queries for excel and power bi
-- each query below maps to one tab in excel and
-- one visual in the power bi dashboard
-- last updated: 2026-06-10
-- ================================================


-- ------------------------------------------------
-- export 1: q1 neighborhood demand vs supply
-- destination: excel tab 'neighborhood_stats'
-- power bi: q1 demand vs supply page
-- ------------------------------------------------

select
  'NYC' as city,
  neighbourhood_cleansed as neighbourhood,
  neighbourhood_group_cleansed as area,
  count(*) as supply_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(price), 2) as avg_price,
  round(avg(reviews_per_month), 2) as avg_reviews_per_month,
  round(avg(review_scores_rating), 2) as avg_rating,
  case when avg(occupancy_rate) > (select avg(occupancy_rate) from listings_nyc_clean)
    then 'above average' else 'below average' end as occupancy_tier,
  case when avg(price) > (select avg(price) from listings_nyc_clean)
    then 'premium' else 'lag' end as pricing_tier,
  case
    when avg(occupancy_rate) > (select avg(occupancy_rate) from listings_nyc_clean)
      and avg(price) < (select avg(price) from listings_nyc_clean) then 'opportunity'
    when avg(occupancy_rate) > (select avg(occupancy_rate) from listings_nyc_clean)
      and avg(price) > (select avg(price) from listings_nyc_clean) then 'high demand'
    when avg(occupancy_rate) < (select avg(occupancy_rate) from listings_nyc_clean)
      and avg(price) > (select avg(price) from listings_nyc_clean) then 'overpriced'
    else 'low demand'
  end as market_signal
from listings_nyc_clean
group by neighbourhood_cleansed, neighbourhood_group_cleansed
having count(*) >= 10
union all
select
  'Mexico City' as city,
  neighbourhood as neighbourhood,
  null as area,
  count(*) as supply_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(price), 2) as avg_price,
  round(avg(reviews_per_month), 2) as avg_reviews_per_month,
  null as avg_rating,
  case when avg(occupancy_rate) > (select avg(occupancy_rate) from listings_mexico_city_clean)
    then 'above average' else 'below average' end as occupancy_tier,
  case when avg(price) > (select avg(price) from listings_mexico_city_clean)
    then 'premium' else 'lag' end as pricing_tier,
  case
    when avg(occupancy_rate) > (select avg(occupancy_rate) from listings_mexico_city_clean)
      and avg(price) < (select avg(price) from listings_mexico_city_clean) then 'opportunity'
    when avg(occupancy_rate) > (select avg(occupancy_rate) from listings_mexico_city_clean)
      and avg(price) > (select avg(price) from listings_mexico_city_clean) then 'high demand'
    when avg(occupancy_rate) < (select avg(occupancy_rate) from listings_mexico_city_clean)
      and avg(price) > (select avg(price) from listings_mexico_city_clean) then 'overpriced'
    else 'low demand'
  end as market_signal
from listings_mexico_city_clean
group by neighbourhood
having count(*) >= 10
union all
select
  'New Orleans' as city,
  neighbourhood_cleansed as neighbourhood,
  neighbourhood_group_cleansed as area,
  count(*) as supply_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(price), 2) as avg_price,
  round(avg(reviews_per_month), 2) as avg_reviews_per_month,
  round(avg(review_scores_rating), 2) as avg_rating,
  case when avg(occupancy_rate) > (select avg(occupancy_rate) from listings_new_orleans_clean)
    then 'above average' else 'below average' end as occupancy_tier,
  case when avg(price) > (select avg(price) from listings_new_orleans_clean)
    then 'premium' else 'lag' end as pricing_tier,
  case
    when avg(occupancy_rate) > (select avg(occupancy_rate) from listings_new_orleans_clean)
      and avg(price) < (select avg(price) from listings_new_orleans_clean) then 'opportunity'
    when avg(occupancy_rate) > (select avg(occupancy_rate) from listings_new_orleans_clean)
      and avg(price) > (select avg(price) from listings_new_orleans_clean) then 'high demand'
    when avg(occupancy_rate) < (select avg(occupancy_rate) from listings_new_orleans_clean)
      and avg(price) > (select avg(price) from listings_new_orleans_clean) then 'overpriced'
    else 'low demand'
  end as market_signal
from listings_new_orleans_clean
group by neighbourhood_cleansed, neighbourhood_group_cleansed
having count(*) >= 10
order by city, avg_occupancy desc;


-- ------------------------------------------------
-- export 2: q2 seasonality publishing calendar
-- destination: excel tab 'seasonality'
-- power bi: q2 publishing calendar page
-- ------------------------------------------------

with monthly_demand as (
  select 'NYC' as city,
    to_char(date, 'MM') as month_number,
    to_char(date, 'Month') as month_name,
    count(*) as booked_nights
  from calendar_nyc_clean where available = 'f'
  group by to_char(date, 'MM'), to_char(date, 'Month')
  union all
  select 'Mexico City' as city,
    to_char(date, 'MM') as month_number,
    to_char(date, 'Month') as month_name,
    count(*) as booked_nights
  from calendar_mexico_city_clean where available = 'f'
  group by to_char(date, 'MM'), to_char(date, 'Month')
  union all
  select 'New Orleans' as city,
    to_char(date, 'MM') as month_number,
    to_char(date, 'Month') as month_name,
    count(*) as booked_nights
  from calendar_new_orleans_clean where available = 'f'
  group by to_char(date, 'MM'), to_char(date, 'Month')
),
city_peak as (
  select
    city,
    month_number,
    month_name,
    booked_nights,
    max(booked_nights) over (partition by city) as peak_nights
  from monthly_demand
)
select
  city,
  month_number,
  month_name,
  booked_nights,
  round(booked_nights * 100.0 / peak_nights, 1) as pct_of_peak,
  case
    when booked_nights = peak_nights then 'peak'
    when booked_nights * 100.0 / peak_nights >= 80 then 'high season'
    when booked_nights * 100.0 / peak_nights >= 60 then 'shoulder season'
    else 'off peak'
  end as season_type,
  case
    when booked_nights = peak_nights then 'publish 6-8 weeks prior'
    when booked_nights * 100.0 / peak_nights >= 80 then 'publish 4-6 weeks prior'
    when booked_nights * 100.0 / peak_nights >= 60 then 'publish 2-4 weeks prior'
    else 'no push needed'
  end as publishing_recommendation
from city_peak
order by city, month_number;


-- ------------------------------------------------
-- export 3: q3 attribute performance
-- destination: excel tab 'attribute_performance'
-- power bi: q3 listing attributes page
-- ------------------------------------------------

select
  'NYC' as city,
  room_type,
  host_is_superhost,
  accommodates,
  round(review_scores_cleanliness, 0) as cleanliness_score,
  round(review_scores_location, 0) as location_score,
  round(review_scores_value, 0) as value_score,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(review_scores_rating), 2) as avg_rating,
  round(avg(price), 2) as avg_price,
  count(*) as listing_count
from listings_nyc_clean
where review_scores_cleanliness is not null
  and review_scores_location is not null
  and review_scores_value is not null
group by
  room_type,
  host_is_superhost,
  accommodates,
  round(review_scores_cleanliness, 0),
  round(review_scores_location, 0),
  round(review_scores_value, 0)
having count(*) >= 5
union all
select
  'New Orleans' as city,
  room_type,
  host_is_superhost,
  accommodates,
  round(review_scores_cleanliness, 0) as cleanliness_score,
  round(review_scores_location, 0) as location_score,
  round(review_scores_value, 0) as value_score,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(review_scores_rating), 2) as avg_rating,
  round(avg(price), 2) as avg_price,
  count(*) as listing_count
from listings_new_orleans_clean
where review_scores_cleanliness is not null
  and review_scores_location is not null
  and review_scores_value is not null
group by
  room_type,
  host_is_superhost,
  accommodates,
  round(review_scores_cleanliness, 0),
  round(review_scores_location, 0),
  round(review_scores_value, 0)
having count(*) >= 5
order by city, avg_occupancy desc;


-- ------------------------------------------------
-- export 4: q4 market entry assessment
-- destination: excel tab 'market_entry'
-- power bi: q4 market entry page
-- ------------------------------------------------

select
  'NYC' as city,
  neighbourhood_cleansed as neighbourhood,
  neighbourhood_group_cleansed as area,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(price), 2) as avg_price,
  round(stddev(price), 2) as price_stddev,
  round(stddev(price) / nullif(avg(price), 0), 4) as coeff_of_variation,
  round((avg(occupancy_rate) -
    (select avg(occupancy_rate) from listings_nyc_clean)) * 100, 2) as occupancy_gap_pct,
  round(avg(price) -
    (select avg(price) from listings_nyc_clean), 2) as price_gap,
  case
    when avg(occupancy_rate) > (select avg(occupancy_rate) from listings_nyc_clean)
      and avg(price) < (select avg(price) from listings_nyc_clean)
      and stddev(price) / nullif(avg(price), 0) > 0.8
      then 'GO -- high demand, underpriced, volatile market'
    when avg(occupancy_rate) > (select avg(occupancy_rate) from listings_nyc_clean)
      and avg(price) < (select avg(price) from listings_nyc_clean)
      then 'GO -- high demand, underpriced'
    when avg(occupancy_rate) > (select avg(occupancy_rate) from listings_nyc_clean)
      and avg(price) > (select avg(price) from listings_nyc_clean)
      then 'MONITOR -- high demand, already premium'
    when avg(occupancy_rate) < (select avg(occupancy_rate) from listings_nyc_clean)
      and avg(price) < (select avg(price) from listings_nyc_clean)
      then 'NO GO -- low demand, low price'
    else 'NO GO -- overpriced relative to demand'
  end as market_signal
from listings_nyc_clean
group by neighbourhood_cleansed, neighbourhood_group_cleansed
having count(*) >= 10
union all
select
  'Mexico City' as city,
  neighbourhood as neighbourhood,
  null as area,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(price), 2) as avg_price,
  round(stddev(price), 2) as price_stddev,
  round(stddev(price) / nullif(avg(price), 0), 4) as coeff_of_variation,
  round((avg(occupancy_rate) -
    (select avg(occupancy_rate) from listings_mexico_city_clean)) * 100, 2) as occupancy_gap_pct,
  round(avg(price) -
    (select avg(price) from listings_mexico_city_clean), 2) as price_gap,
  case
    when avg(occupancy_rate) > (select avg(occupancy_rate) from listings_mexico_city_clean)
      and avg(price) < (select avg(price) from listings_mexico_city_clean)
      and stddev(price) / nullif(avg(price), 0) > 0.8
      then 'GO -- high demand, underpriced, volatile market'
    when avg(occupancy_rate) > (select avg(occupancy_rate) from listings_mexico_city_clean)
      and avg(price) < (select avg(price) from listings_mexico_city_clean)
      then 'GO -- high demand, underpriced'
    when avg(occupancy_rate) > (select avg(occupancy_rate) from listings_mexico_city_clean)
      and avg(price) > (select avg(price) from listings_mexico_city_clean)
      then 'MONITOR -- high demand, already premium'
    when avg(occupancy_rate) < (select avg(occupancy_rate) from listings_mexico_city_clean)
      and avg(price) < (select avg(price) from listings_mexico_city_clean)
      then 'NO GO -- low demand, low price'
    else 'NO GO -- overpriced relative to demand'
  end as market_signal
from listings_mexico_city_clean
group by neighbourhood
having count(*) >= 10
union all
select
  'New Orleans' as city,
  neighbourhood_cleansed as neighbourhood,
  neighbourhood_group_cleansed as area,
  count(*) as listing_count,
  round(avg(occupancy_rate), 4) as avg_occupancy,
  round(avg(price), 2) as avg_price,
  round(stddev(price), 2) as price_stddev,
  round(stddev(price) / nullif(avg(price), 0), 4) as coeff_of_variation,
  round((avg(occupancy_rate) -
    (select avg(occupancy_rate) from listings_new_orleans_clean)) * 100, 2) as occupancy_gap_pct,
  round(avg(price) -
    (select avg(price) from listings_new_orleans_clean), 2) as price_gap,
  case
    when avg(occupancy_rate) > (select avg(occupancy_rate) from listings_new_orleans_clean)
      and avg(price) < (select avg(price) from listings_new_orleans_clean)
      and stddev(price) / nullif(avg(price), 0) > 0.8
      then 'GO -- high demand, underpriced, volatile market'
    when avg(occupancy_rate) > (select avg(occupancy_rate) from listings_new_orleans_clean)
      and avg(price) < (select avg(price) from listings_new_orleans_clean)
      then 'GO -- high demand, underpriced'
    when avg(occupancy_rate) > (select avg(occupancy_rate) from listings_new_orleans_clean)
      and avg(price) > (select avg(price) from listings_new_orleans_clean)
      then 'MONITOR -- high demand, already premium'
    when avg(occupancy_rate) < (select avg(occupancy_rate) from listings_new_orleans_clean)
      and avg(price) < (select avg(price) from listings_new_orleans_clean)
      then 'NO GO -- low demand, low price'
    else 'NO GO -- overpriced relative to demand'
  end as market_signal
from listings_new_orleans_clean
group by neighbourhood_cleansed, neighbourhood_group_cleansed
having count(*) >= 10
order by city, occupancy_gap_pct desc;


