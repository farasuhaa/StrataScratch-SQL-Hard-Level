-- =========================================================
-- Title: Monthly Percentage Difference
-- Language: PostgreSQL
-- Difficulty: Hard
-- Source: StrataScratch
-- ID: 10319
-- =========================================================

-- Problem:
-- Given a table of purchases by date, calculate the month-over-month percentage change in revenue. 
-- The output should include the year-month date (YYYY-MM) and percentage change, rounded to the 2nd decimal point, 
-- and sorted from the beginning of the year to the end of the year.
-- The percentage change column will be populated from the 2nd month forward and can be calculated as 
-- ((this month's revenue - last month's revenue) / last month's revenue)*100.

-- Output: list of YYYY-MM and it's revenue percentage difference

-- Tables:

-- sf_transactions
-- ____________________________
-- |  created_at   |  date    |
-- |  id           |  bigint  |
-- |  purchase_id  |  bigint  |
-- |  value        |  bigint  |

-- =====================================================================================
-- Approach

-- 1. Extract year and month from the transaction date and aggregate total revenue per month.
-- 2. Use LAG() to retrieve the previous month’s revenue.
-- 3. Calculate month-over-month percentage change using ((current - previous) / previous) * 100.
-- 4. Round the result to 2 decimal places and sort by year-month.
-- =====================================================================================

with base as (
    select
        to_char(created_at, 'YYYY-MM') as year_month
        -- , date_trunc('month', created_at) as month_date
        ,*
    from sf_transactions
)

, mth_grp as (
    select
        year_month
        -- , month_date
        , sum(value) as month_value
    from base
    group by 1
    order by 1
)

select
    year_month
    , round(((month_value - lag(month_value) over (order by year_month)) / lag(month_value) over (order by year_month) ::numeric) * 100, 2) as prcnt_diff
from mth_grp
order by 1
