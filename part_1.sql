-- Create a Database
CREATE DATABASE assignment_1;

-- Use the Database
USE DATABASE assignment_1;

-- Create Stage Assignment and import data from Azure into Snowflake
CREATE or REPLACE STAGE stage_assignment
URL = 'azure://assignment1bde.blob.core.windows.net/assignment1'
CREDENTIALS=(AZURE_SAS_TOKEN='?sv=2022-11-02&ss=b&srt=co&sp=rwdlaciytfx&se=2024-09-03T13:48:53Z&st=2024-08-18T05:48:53Z&spr=https&sig=6zfY8xOPxHlLJQh0YIt5gqtwkSarV5O2q0FgDYDCMzM%3D');


-- Create External Tables
-- 1. ex_table_youtube_trending

CREATE or REPLACE EXTERNAL TABLE ex_table_youtube_trending_columns
WITH location = @stage_assignment
FILE_FORMAT = (TYPE=CSV)
PATTERN = '.*trending_data.*\.csv';

-- Verification
SELECT *
FROM ex_table_youtube_trending_columns
LIMIT 1;

-- Parsing the values of the 11 columns as varchar and displaying the first row
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
FROM ex_table_youtube_trending_columns
LIMIT 1;

-- Creating a specified File Format for CSV files
CREATE OR REPLACE FILE FORMAT file_format_csv
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1
NULL_IF = ('\\N', 'NULL', 'NUL', '')
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
;

--Recreate the external table using the specified file format
CREATE or REPLACE EXTERNAL TABLE ex_table_youtube_trending
WITH LOCATION = @stage_assignment
FILE_FORMAT = file_format_csv
PATTERN = '.*trending_data.*\.csv';

--Parse the values into the 11 columns with correct data types
SELECT
value:c1::varchar as VIDEO_ID,
value:c2::varchar as TITLE,
value:c3::date as PUBLISHEDAT,
value:c4::varchar as CHANNELID,
value:c5::varchar as CHANNELTITLE,
value:c6::int as CATEGORYID,
value:c7::date as TRENDING_DATE,
value:c8::int as VIEW_COUNT,
value:c9::int as LIKES,
value:c10::int as DISLIKES,
value:c11::int as COMMENT_COUNT
FROM ASSIGNMENT_1.PUBLIC.ex_table_youtube_trending;

-- Create the final external table with the right data types
CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_trending
(
VIDEO_ID varchar as (value:c1::varchar),
TITLE varchar as (value:c2::varchar),
PUBLISHEDAT date as (value:c3::date),
CHANNELID varchar as (value:c4::varchar),
CHANNELTITLE varchar as (value:c5::varchar),
CATEGORYID int as (value:c6::int),
TRENDING_DATE date as (value:c7::date),
VIEW_COUNT int as (value:c8::int),
LIKES int as (value:c9::int),
DISLIKES int as (value:c10::int),
COMMENT_COUNT int as (value:c11::int)
)
WITH LOCATION = @stage_assignment
FILE_FORMAT = file_format_csv
PATTERN = '.*trending_data.*\.csv';

-- Verification
SELECT *
FROM ex_table_youtube_trending
LIMIT 3;



-- 2. table_youtube_category

-- Create a standard file format for JSON files
CREATE OR REPLACE FILE FORMAT file_format_json
TYPE = 'JSON'
NULL_IF = ('\\N', 'NULL', 'NUL', '')
;

CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_category_columns
WITH LOCATION = @stage_assignment
FILE_FORMAT = file_format_json
PATTERN = '.*category_id.*\.json';



--Parsing data into the 2 needed columns
SELECT
items.value:id::int as CATEGORYID,
items.value:snippet.title::varchar as CATEGORY_TITLE
FROM assignment_1.public.ex_table_youtube_category_columns,
LATERAL FLATTEN(input => $1:items) AS items
LIMIT 10;

CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_category (
    CATEGORYID INT AS (value:id::int),
    CATEGORY_TITLE VARCHAR AS (value:snippet.title::varchar)
)
WITH LOCATION = @stage_assignment
FILE_FORMAT = file_format_json
PATTERN = '.*category_id.*\.json';

-- Insert the parsed data into the external table
INSERT INTO table_youtube_category (CATEGORY_ID, CATEGORY_TITLE)
SELECT
items.value:id::int AS CATEGORY_ID,
items.value:snippet.title::varchar AS CATEGORY_TITLE
FROM ex_table_youtube_category,  -- Reference the external table directly
LATERAL FLATTEN(input => $1:items) AS items;


-- CREATING INTERNAL TABLES
-- table_youtube_trending

CREATE OR REPLACE TABLE assignment_1.PUBLIC.table_youtube_trending (
VIDEO_ID VARCHAR,
TITLE VARCHAR,
PUBLISHEDAT DATE,
CHANNELID VARCHAR,
CHANNELTITLE VARCHAR,
CATEGORYID INT,
TRENDING_DATE DATE,
VIEW_COUNT INT,
LIKES INT,
DISLIKES INT,
COMMENT_COUNT INT,
COUNTRY VARCHAR
);

-- Insert values into the internal table
INSERT INTO assignment_1.PUBLIC.table_youtube_trending
SELECT
value:c1::varchar as VIDEO_ID,
value:c2::varchar as TITLE,
value:c3::date as PUBLISHEDAT,
value:c4::varchar as CHANNEL_ID,
value:c5::varchar as CHANNEL_TITLE,
value:c6::int as CATEGORY_ID,
value:c7::date as TRENDING_DATE,
value:c8::int as VIEW_COUNT,
value:c9::int as LIKES,
value:c10::int as DISLIKES,
value:c11::int as COMMENT_COUNT,
CASE 
    WHEN METADATA$FILENAME LIKE '%BR%' THEN 'BR'
    WHEN METADATA$FILENAME LIKE '%CA%' THEN 'CA'
    WHEN METADATA$FILENAME LIKE '%DE%' THEN 'DE'
    WHEN METADATA$FILENAME LIKE '%FR%' THEN 'FR'
    WHEN METADATA$FILENAME LIKE '%GB%' THEN 'GB'
    WHEN METADATA$FILENAME LIKE '%IN%' THEN 'IN'
    WHEN METADATA$FILENAME LIKE '%JP%' THEN 'JP'
    WHEN METADATA$FILENAME LIKE '%KR%' THEN 'KR'
    WHEN METADATA$FILENAME LIKE '%MX%' THEN 'MX'
    WHEN METADATA$FILENAME LIKE '%US%' THEN 'US'
    ELSE 'UNKNOWN'
END AS COUNTRY
FROM ASSIGNMENT_1.PUBLIC.ex_table_youtube_trending;


--Get the overall count of rows in the internal table.
SELECT COUNT(*) 
FROM assignment_1.PUBLIC.table_youtube_trending;



-- internal table for table_youtube_category
CREATE OR REPLACE TABLE table_youtube_category 
(
COUNTRY varchar,
CATEGORYID int,
CATEGORY_TITLE varchar
);

INSERT INTO table_youtube_category
SELECT 
CASE 
    WHEN METADATA$FILENAME LIKE '%BR%' THEN 'BR'
    WHEN METADATA$FILENAME LIKE '%CA%' THEN 'CA'
    WHEN METADATA$FILENAME LIKE '%DE%' THEN 'DE'
    WHEN METADATA$FILENAME LIKE '%FR%' THEN 'FR'
    WHEN METADATA$FILENAME LIKE '%GB%' THEN 'GB'
    WHEN METADATA$FILENAME LIKE '%IN%' THEN 'IN'
    WHEN METADATA$FILENAME LIKE '%JP%' THEN 'JP'
    WHEN METADATA$FILENAME LIKE '%KR%' THEN 'KR'
    WHEN METADATA$FILENAME LIKE '%MX%' THEN 'MX'
    WHEN METADATA$FILENAME LIKE '%US%' THEN 'US'
    ELSE 'UNKNOWN'
END AS COUNTRY,
items.value:id::int AS CATEGORYID,
items.value:snippet.title::varchar AS CATEGORY_TITLE
FROM assignment_1.public.ex_table_youtube_category_columns,
LATERAL FLATTEN(input => ex_table_youtube_category_columns.$1:items) AS items;



-- Create a final table combining the two
CREATE or REPLACE TABLE table_youtube_final AS
SELECT
UUID_STRING() as ID,
tr.VIDEO_ID,
tr.TITLE,
tr.PUBLISHEDAT,
tr.CHANNELID,
tr.CHANNELTITLE,
tr.CATEGORYID,
ct.CATEGORY_TITLE,
tr.TRENDING_DATE,
tr.VIEW_COUNT,
tr.LIKES,
tr.DISLIKES,
tr.COMMENT_COUNT,
tr.COUNTRY
FROM 
table_youtube_trending tr
LEFT JOIN
table_youtube_category ct
ON 
tr.COUNTRY = ct.COUNTRY 
AND tr.CATEGORYID = ct.CATEGORYID;


-- Verification
SELECT COUNT(*)
FROM table_youtube_final;