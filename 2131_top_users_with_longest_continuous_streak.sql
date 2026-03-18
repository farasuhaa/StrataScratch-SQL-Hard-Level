-- =========================================================
-- Title: User Streaks
-- Language: PostgreSQL
-- Difficulty: Hard
-- Source: StrataScratch
-- ID: 2131
-- =========================================================

-- Problem:
-- Provided a table with user id and the dates they visited the platform, 
-- find the top 3 users with the longest continuous streak of visiting the platform as of August 10, 2022. 
  
-- Output: the user ID and the length of the streak.

-- Note:
-- In case of a tie, display all users with the top three longest streaks.

-- Table:

-- user_streaks
-- ___________________________
-- |  date_visited  |  date  |
-- |  user_id       |  text  |

-- =====================================================================================
-- Approach

-- 1. Filter records up to the given date and remove duplicates to get distinct user visit days.
-- 2. Assign row_number() per user and normalize dates to group consecutive visits into streaks.
-- 3. Aggregate each group to compute streak lengths per user.
-- 4. Rank streaks using dense_rank() and select the top 3 longest streaks (including ties).
-- =====================================================================================

with base as (
    select
        distinct user_id
        , date_visited
    from user_streaks
    where date_visited <= '2022-08-10'
    order by 1, date_visited desc
)

, grp as (
    select
        user_id
        , date_visited
        , date_visited - row_number() over (partition by user_id order by date_visited) * interval '1 day' as rnk
    from base
)

, streaks as (
    select
        user_id
        , count(*) as streak_length
    from grp
    group by 1, rnk
    order by 2 desc
)

, streak_ranks as (
    select
        user_id
        , streak_length
        , dense_rank() over (order by streak_length desc) as streak_rank
    from streaks
    group by 1,2
    order by 2 desc
)

select
    user_id
    , streak_length
from streak_ranks
where streak_rank <= 3
group by 1,2
order by 2 desc
