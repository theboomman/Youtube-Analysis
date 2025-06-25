-- Solve The Real World Challenge
USE DATABASE SELF_PROJECT;

-- If i had to launch a new Youtube channel , which category (excluding “Music”
-- and “Entertainment” because these titles have many more videos than others)  of video will i be trying to create to have them appear in the top
-- trend of YoutubeinUS? Will this strategy work in every country?

CREATE VIEW my_youtube_channel AS
SELECT category_title, publishedat, trending_date, view_count, country 
FROM table_youtube_final
WHERE category_title NOT IN ('Music', 'Entertainment'); --Exclude Music and Entertainment

SELECT * FROM my_youtube_channel;  -- My YouTube channel view table has been created.

SELECT category_title, COUNT(trending_date) AS days_of_trending
FROM my_youtube_channel
GROUP BY category_title
ORDER BY days_of_trending DESC
LIMIT 5;                        -- TOP 5 of the most trending date is Gaming, Sports, People & Blogs, Comedy and News & Politics


SELECT category_title, COUNT(DISTINCT video_id) AS video_counts
FROM table_youtube_final
WHERE category_title NOT IN ('Music', 'Entertainment')
GROUP BY category_title
ORDER BY video_counts DESC
LIMIT 5;                            -- Top 5 of video counts is sports, people & blogs, gaming, comedy, news & politics

SELECT category_title, SUM(view_count) AS total_views
FROM my_youtube_channel
GROUP BY category_title
ORDER BY total_views DESC
LIMIT 5;                    -- Top 5 of the most views categories is gaming, people & blogs, sports, comedy and Film & Animation

-- Ranked by Country
CREATE OR REPLACE TABLE ranked_total_views_categories_by_country AS
SELECT country, category_title, SUM(view_count) AS total_views, ROW_NUMBER() OVER (PARTITION BY country ORDER BY total_views DESC) AS rk
FROM my_youtube_channel
GROUP BY country, category_title
ORDER BY country, rk;

SELECT * 
FROM ranked_total_views_categories_by_country
WHERE rk <= 5
ORDER BY country, rk;  -- Top 5 of most views by categories for each country has been retrieved.

CREATE OR REPLACE TABLE ranked_days_trending_categories_by_country AS
SELECT country, category_title, COUNT(trending_date) AS days_trending, ROW_NUMBER() OVER (PARTITION BY country ORDER BY days_trending DESC) AS rk
FROM my_youtube_channel
GROUP BY country, category_title
ORDER BY country, rk;

SELECT * 
FROM ranked_days_trending_categories_by_country
WHERE rk <= 5
ORDER BY country, rk;               -- Top 5 of most trending days by categories for each country has been retrieved.

-- If I had to open my YouTube channel, I would choose the gaming category because it's always on the long trending and attracts a lot of views, which has been shown in every country. Moreover, the number of videos is less than sports and people & blogs. There will be some chances to make it trendy.