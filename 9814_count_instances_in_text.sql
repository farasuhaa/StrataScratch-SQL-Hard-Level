-- =========================================================
-- Title: Counting Instances in Text
-- Language: PostgreSQL
-- Difficulty: Hard
-- Source: StrataScratch
-- ID: 9814
-- =========================================================

-- Problem:
-- Find the number of times the exact words 'bull' and 'bear' appear in the contents column.
-- Count all occurrences, even if they appear multiple times within the same row. 
-- Matches should be case-insensitive and only count exact words, that is, exclude substrings like 'bullish' or 'bearing'.

-- Output: the word (bull or bear) and the corresponding number of occurrences.

-- Tables:

-- google_file_store
-- _______________________
-- |  contents  |  text  |
-- |  filename  |  text  |

-- =====================================================================================
-- Approach

-- 1. Use REGEXP_MATCHES to extract all occurrences of the exact words “bull” and “bear” from the text.
-- 2. Apply word boundary patterns and case-insensitive flag to ensure only exact matches are counted.
-- 3. Combine results for both words using UNION ALL.
-- 4. Aggregate counts for each word to get total occurrences.

-- Notes
-- regexp_matches(contents, '\mbull\M', 'gi')
    -- g → global (find ALL matches in a row)
    -- i → case-insensitive
    -- \m and \M → ensure exact word match
    -- matches: bull, BULL
    -- excludes: bullish, bulls
-- =====================================================================================

with words as (
    select
        'bull' as word
        , regexp_matches(contents, '\mbull\M', 'gi') as match
    from google_file_store
    
    union all
    
    select
        'bear' as word
        , regexp_matches(contents, '\mbear\M', 'gi') as match
    from google_file_store
)

select
    word
    , count(*) as word_count
from words
group by 1
