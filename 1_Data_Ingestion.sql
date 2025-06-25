-- Data Ingestion
DROP DATABASE IF EXISTS self_project CASCADE;
CREATE DATABASE self_project;
USE DATABASE self_project;


CREATE STORAGE INTEGRATION s3_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::803146170396:role/self-project-glue-s3-role'
  ENABLED = TRUE
  STORAGE_ALLOWED_LOCATIONS = ('s3://self-learning-project/');

DESC INTEGRATION s3_integration;

CREATE OR REPLACE STAGE my_s3_stage
URL = 's3://self-learning-project/'
STORAGE_INTEGRATION = s3_integration;

LIST @my_s3_stage;

CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_trending_columns_name
WITH LOCATION = @my_s3_stage
FILE_FORMAT = (TYPE=CSV)
PATTERN = '.*[A-Z]_youtube_trending_data.*[.]csv';

SELECT *
FROM ex_table_youtube_trending_columns_name
LIMIT 1;

SELECT
value:c1::varchar,
value:c2::varchar,
value:c3::varchar,
value:c4::varchar,
value:c5::varchar,
value:c6::varchar,
value:c7::varchar,
value:c8::varchar,
value:c9::varchar,
value:c10::varchar,
value:c11::varchar
FROM ex_table_youtube_trending_columns_name
LIMIT 1;

CREATE OR REPLACE FILE FORMAT file_format_csv
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1
NULL_IF = ('\\N', 'NULL', 'NUL', '')
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
;

CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_trending
WITH LOCATION = @my_s3_stage
FILE_FORMAT = file_format_csv
PATTERN = '.*[A-Z]_youtube_trending_data.*[.]csv';

SELECT *
FROM EX_TABLE_YOUTUBE_TRENDING
LIMIT 10;                                     -- External Table of ex_table_youtube_trending has been created

SELECT metadata$filename
FROM EX_TABLE_YOUTUBE_TRENDING;

SELECT
SPLIT_PART(split_part(metadata$filename,'/', 2), '_',1) as country
FROM EX_TABLE_YOUTUBE_TRENDING;

SELECT
value:c1::varchar as video_id,
value:c2::varchar as title,
value:c3::timestamp_ntz as publishedAt,
value:c4::varchar as channelId,
value:c5::varchar as channelTitle,
value:c6::int as categoryId,
value:c7::timestamp_ntz as trending_date,
value:c8::int as view_count,
value:c9::int as likes,
value:c10::int as dislikes,
value:c11::int as comment_count,
SPLIT_PART(split_part(metadata$filename,'/', 2), '_',1) as country
FROM EX_TABLE_YOUTUBE_TRENDING 
;

CREATE TABLE table_youtube_trending as
SELECT
value:c1::varchar as video_id,
value:c2::varchar as title,
value:c3::timestamp_ntz as publishedAt,
value:c4::varchar as channelId,
value:c5::varchar as channelTitle,
value:c6::int as categoryId,
value:c7::timestamp_ntz as trending_date,
value:c8::int as view_count,
value:c9::int as likes,
value:c10::int as dislikes,
value:c11::int as comment_count,
SPLIT_PART(split_part(metadata$filename,'/', 2), '_',1) as country
FROM EX_TABLE_YOUTUBE_TRENDING;

SELECT * 
FROM table_youtube_trending
LIMIT 10;

CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_category
WITH LOCATION = @my_s3_stage
FILE_FORMAT = (TYPE=JSON)
PATTERN = '.*[.]json';

SELECT *
FROM ex_table_youtube_category;

SELECT
SPLIT_PART(split_part(metadata$filename,'/', 3), '_',1) as country
FROM ex_table_youtube_category;

CREATE OR REPLACE TABLE table_youtube_category as
SELECT 
SPLIT_PART(split_part(metadata$filename,'/', 3), '_',1) as country,
l.value:id::int as categoryId,
l.value:snippet.title::varchar as category_title
FROM ex_table_youtube_category
, LATERAL FLATTEN(input => ex_table_youtube_category.value:items) l;

SELECT * 
FROM table_youtube_category                        -- Table of table_youtube_trending has been created
LIMIT 10;

CREATE OR REPLACE TABLE table_youtube_final as
SELECT
UUID_STRING() as id,
t.video_id,
t.title,
t.publishedAt,
t.channelId,
t.channelTitle,
t.categoryId,
c.category_title,
t.trending_date,
t.view_count,
t.likes,
t.dislikes,
t.comment_count,
t.country
FROM table_youtube_trending t
LEFT JOIN table_youtube_category c
ON c.categoryId = t.categoryId
AND c.country = t.country;

SELECT *
FROM table_youtube_final
LIMIT 10;

SELECT  COUNT(*)
FROM table_youtube_final;                   -- Row counting is 2,667,041 rows
