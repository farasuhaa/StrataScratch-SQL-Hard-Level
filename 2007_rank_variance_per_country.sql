-- =========================================================
-- Title: Rank Variance Per Country
-- Language: PostgreSQL
-- Difficulty: Hard
-- Source: StrataScratch
-- ID: 2007
-- =========================================================

-- Problem:
-- Compare the total number of comments made by users in each country during December 2019 and January 2020.

-- Note:
-- For each month, rank countries by their total number of comments in descending order. 
-- Countries with the same total should share the same rank, and the next rank should increase by one (without skipping numbers).

-- Output:
-- Return the names of the countries whose rank improved from December to January (that is, their rank number became smaller).

-- Tables:

-- fb_comments_count
-- ___________________________________
-- |  created_at          |  date    |
-- |  number_of_comments  |  bigint  |
-- |  user_id             |  bigint  |

-- fb_active_users
-- ________________________
-- |  country  |  text    |
-- |  name     |  text    |
-- |  status   |  text    |
-- |  user_id  |  bigint  |

-- =====================================================================================
-- Approach
--
-- 1. Aggregate total comments per country for each month (December 2019 and January 2020).
-- 2. Rank countries within each month using dense_rank() based on total comments.
-- 3. Join December and January rankings by country.
-- 4. Filter countries whose rank improved in January (i.e., lower rank number).
-- =====================================================================================

with dec as (
    with dec_base as (
        select
            country
            , sum(number_of_comments) as n_comments
            , to_char (created_at, 'YYYY-MM') as date_month
        from fb_comments_count c
        left join fb_active_users u     on c.user_id = u.user_id
        where to_char (created_at, 'YYYY-MM') = '2019-12'
            and country is not null
        group by 1,3
        order by 2 desc
    )
    select
        country
        -- , n_comments
        -- , date_month
        , dense_rank() over (order by n_comments desc) as dec_rank
    from dec_base
)

, jan as (
    with jan_base as (
        select
            country
            , sum(number_of_comments) as n_comments
            , to_char (created_at, 'YYYY-MM') as date_month
        from fb_comments_count c
        left join fb_active_users u     on c.user_id = u.user_id
        where to_char (created_at, 'YYYY-MM') = '2020-01'
            and country is not null
        group by 1,3
        order by 2 desc
    )
    
    select
        country
        -- , n_comments
        -- , date_month
        , dense_rank() over (order by n_comments desc) as jan_rank
    from jan_base
)

, combined as (
    select
        coalesce(d.country, j.country) as country
        -- , d.n_comments as dec_comment
        -- , j.n_comments as jan_comment
        -- , d.date_month as dec_month
        -- , j.date_month as jan_month
        , dec_rank
        , jan_rank
    from dec d
    left join jan j     on d.country = j.country
)

select
    country
from combined
where jan_rank < dec_rank
