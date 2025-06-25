--Data Analysis
USE DATABASE SELF_PROJECT;

SELECT *
FROM table_youtube_final        -- The final Youtube table.
;

SELECT COUNT(*)
FROM table_youtube_final        -- 2,597,494 rows in the Youtube final table. 
;
--Analysis 1
CREATE OR REPLACE TABLE ranking_sports_01042024_by_country AS
SELECT country, title, channelTitle, view_count, ROW_NUMBER() OVER (PARTITION BY country ORDER BY view_count DESC) AS rk
FROM table_youtube_final
WHERE category_title = 'Sports'
AND trending_date = '2024-04-01'
ORDER BY country, rk;                               -- Create a table called ranking_sport_01042024_by_country

SELECT * 
FROM ranking_sports_01042024_by_country
WHERE rk <= 3
ORDER BY country, rk;                                   -- The query of the top 3 most viewed videos in the sports category on trending date 01-04-2024 in each country order by country has been retrieved.

--Analysis 2
SELECT country, COUNT(DISTINCT title) AS ct
FROM table_youtube_final
WHERE title LIKE '%BLACKPINK%'
GROUP BY country
ORDER BY ct DESC;                                   -- The query of unique BLACKPINK title videos in each country descending ordered by count.

--Analysis 3
CREATE OR REPLACE TABLE ranking_most_viewed_2024_by_country AS
SELECT country, 
        TO_CHAR(trending_date, 'YYYY-MM-DD') AS year_month, 
        title,
        channeltitle, 
        category_title, 
        view_count,
        ROUND((likes/NULLIF(view_count, 0)) * 100, 2) AS likes_ratio, 
        ROW_NUMBER() OVER (PARTITION BY country, year_month ORDER BY view_count DESC) AS rk
FROM table_youtube_final
WHERE year_month >= '2024-01-01'
ORDER BY rk;

SELECT country, year_month, title ,channeltitle, category_title, view_count, likes_ratio FROM ranking_most_viewed_2024_by_country
WHERE rk = 1
ORDER BY year_month, country; -- Filter the most viewed video title for each country in 2024 by date

--Analysis 4
CREATE OR REPLACE TABLE video_counts_from_2023 AS
SELECT country,
        category_title,
        SUM(COUNT(DISTINCT video_id)) OVER (PARTITION BY country, category_title) AS total_category_videos,
        SUM(COUNT(DISTINCT video_id)) OVER (PARTITION BY country) AS total_country_videos,
        ROUND((total_category_videos / total_country_videos) * 100, 2) AS percentage
FROM table_youtube_final
WHERE EXTRACT(YEAR FROM trending_date) >= 2023
GROUP BY country, category_title;

SELECT * FROM video_counts_from_2023; -- Video count from 2023 grouped by country and category has been created
        
CREATE OR REPLACE TABLE ranked_category_by_country AS 
SELECT country,
        category_title,
        total_category_videos,
        total_country_videos,
        percentage,
        ROW_NUMBER() OVER (PARTITION BY country ORDER BY total_category_videos DESC) AS rk
    FROM 
        video_counts_from_2023; -- Ranking of category video by country table has been created.
        
SELECT country, category_title, total_category_videos, total_country_videos, percentage  
FROM ranked_category_by_country
WHERE rk = 1
ORDER BY category_title, country; -- Filter the most videos number category for each country.

--Analysis 5
SELECT channeltitle, COUNT(DISTINCT video_id) AS distinct_video_counts
FROM table_youtube_final
GROUP BY channeltitle
ORDER BY distinct_video_counts DESC
LIMIT 1;                    --The most produced video is CHANNELTITLE name "Vijay Television". There are 2,049 videos
