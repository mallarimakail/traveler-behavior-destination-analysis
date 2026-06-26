-- ================================================
-- 07_q2_seasonality.sql
-- purpose: identify seasonal demand patterns to build
--          a content publishing calendar framework
-- business question: when should we publish and promote content?
-- last updated: 2026-06-10
-- ================================================


-- ------------------------------------------------
-- q2 findings summary
-- ------------------------------------------------

-- nyc:
-- peak month: april (100%)
-- season type: year-round high demand destination
-- only off/shoulder month: september (78.6%)
-- publishing recommendation: year-round cadence
--   push hardest february-march for april peak (6-8 weeks prior)
--   never fully pause nyc content

-- mexico city:
-- peak month: april (100%) -- semana santa/easter
-- high season: january, march
-- shoulder season: february, may, june, october, november, december
-- off peak: july, august, september (rainy season)
-- publishing recommendation:
--   push february-march for april peak (6-8 weeks prior)
--   shoulder content in september-october for holiday season
--   pause july-august

-- new orleans:
-- peak month: march (100%) -- mardi gras + jazz fest
-- high season: january, february, april
-- shoulder season: october, december
-- off peak: may through september (5 consecutive months)
-- publishing recommendation:
--   push november-january for mardi gras season (6-8 weeks prior)
--   shoulder content in september for october recovery
--   pause may-august entirely

-- cross city finding:
-- all three cities peak in march-april
-- content team can batch spring destination content together
-- nyc is the only true year-round destination
-- new orleans has the highest risk of content publishing at wrong time
--   5 months of dead season means mistimed content = wasted spend





-- ------------------------------------------------
-- section 1: monthly demand pattern by city
-- booked nights = available = 'f' (not available = booked)
-- ------------------------------------------------

-- nyc monthly demand
select
  'NYC' as city,
  to_char(date, 'MM') as month_number,
  to_char(date, 'Month') as month_name,
  count(*) as booked_nights,
  round(count(*) * 100.0 / sum(count(*)) over (), 2) as pct_of_annual_demand
from calendar_nyc_clean
where available = 'f'
group by to_char(date, 'MM'), to_char(date, 'Month')
order by month_number;



-- mexico city monthly demand
select
  'Mexico City' as city,
  to_char(date, 'MM') as month_number,
  to_char(date, 'Month') as month_name,
  count(*) as booked_nights,
  round(count(*) * 100.0 / sum(count(*)) over (), 2) as pct_of_annual_demand
from calendar_mexico_city_clean
where available = 'f'
group by to_char(date, 'MM'), to_char(date, 'Month')
order by month_number;



-- new orleans monthly demand
select
  'New Orleans' as city,
  to_char(date, 'MM') as month_number,
  to_char(date, 'Month') as month_name,
  count(*) as booked_nights,
  round(count(*) * 100.0 / sum(count(*)) over (), 2) as pct_of_annual_demand
from calendar_new_orleans_clean
where available = 'f'
group by to_char(date, 'MM'), to_char(date, 'Month')
order by month_number;



-- ------------------------------------------------
-- section 2: peak month and publishing lead time
-- ------------------------------------------------

with monthly_demand as (
  select 'NYC' as city, to_char(date, 'MM') as month_number,
    to_char(date, 'Month') as month_name,
    count(*) as booked_nights
  from calendar_nyc_clean where available = 'f'
  group by to_char(date, 'MM'), to_char(date, 'Month')
  union all
  select 'Mexico City' as city, to_char(date, 'MM') as month_number,
    to_char(date, 'Month') as month_name,
    count(*) as booked_nights
  from calendar_mexico_city_clean where available = 'f'
  group by to_char(date, 'MM'), to_char(date, 'Month')
  union all
  select 'New Orleans' as city, to_char(date, 'MM') as month_number,
    to_char(date, 'Month') as month_name,
    count(*) as booked_nights
  from calendar_new_orleans_clean where available = 'f'
  group by to_char(date, 'MM'), to_char(date, 'Month')
),
city_peak as (
  select
    city,
    month_name,
    month_number,
    booked_nights,
    max(booked_nights) over (partition by city) as peak_nights
  from monthly_demand
),
shoulder_season as (
  select
    city,
    month_name,
    month_number,
    booked_nights,
    peak_nights,
    round(booked_nights * 100.0 / peak_nights, 1) as pct_of_peak,
    case when booked_nights = peak_nights then 'peak'
         when booked_nights * 100.0 / peak_nights >= 80 then 'high season'
         when booked_nights * 100.0 / peak_nights >= 60 then 'shoulder season'
         else 'off peak'
    end as season_type
  from city_peak
)
select
  city,
  month_number,
  month_name,
  booked_nights,
  pct_of_peak,
  season_type,
  case
    when season_type = 'peak' then 'publish 6-8 weeks prior'
    when season_type = 'high season' then 'publish 4-6 weeks prior'
    when season_type = 'shoulder season' then 'publish 2-4 weeks prior'
    else 'no push needed'
  end as publishing_recommendation
from shoulder_season
order by city, month_number;

