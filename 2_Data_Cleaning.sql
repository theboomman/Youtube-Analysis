USE DATABASE SELF_PROJECT;

SELECT *
FROM table_youtube_trending     --The YouTube trending table.
LIMIT 10;

SELECT *
FROM table_youtube_category     --The YouTube category table.
;

SELECT *
FROM table_youtube_final        -- The final Youtube table.
LIMIT 10
;

SELECT COUNT(*)
FROM table_youtube_final        -- 2,667,041 rows in the Youtube final table. 
;

-- Data Cleaning
SELECT DISTINCT categoryid, category_title
FROM table_youtube_final
WHERE category_title IS NULL;       -- The missing categoryId is 29.

UPDATE table_youtube_final
SET category_title = 29
WHERE category_title IS NULL; -- 1563 rows have been updated with 29

SELECT COUNT(*)
FROM table_youtube_final
WHERE category_title IS NULL;      -- No Null in category_title

SELECT COUNT(*)
FROM table_youtube_final
WHERE video_id = '#NAME?';          -- 32,081 rows of video_id column that contains "#NAME?"

DELETE FROM table_youtube_final
WHERE video_id = '#NAME?';          -- 32,081 rows of video ID which contains "#NAME?" has been deleted.

SELECT COUNT(*)
FROM table_youtube_final;

CREATE OR REPLACE TABLE table_youtube_duplicates as
SELECT *
FROM ( SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY video_id, country, trending_date ORDER BY view_count DESC) AS row_num
    FROM
        table_youtube_final);

SELECT *
FROM table_youtube_duplicates
LIMIT 10;                                       -- Table_youtube_duplicates that contains duplicated values of table_youtube_final has been created by using the row_number() function as a duplicated value identifier.

SELECT COUNT(*)
FROM table_youtube_duplicates
WHERE ROW_NUM > 1;                  -- There are 37,466 rows in this table that are duplicated

DELETE FROM table_youtube_final
WHERE id IN    (SELECT id
                FROM table_youtube_duplicates
                WHERE row_num > 1);             -- 37,466 duplicated rows have been deleted using table_youtube_duplicates table to identify which rows contain duplicated values.

SELECT COUNT(*)
FROM table_youtube_final;                      -- The table of table_youtube_final has 2,597,494 rows left after the cleaning process.
