-- Q1. What are the 3 most viewed videos for each country in the Gaming category for the trending_date = 2024-04-011. Order the result by country and the rank

SELECT * 
FROM (
    SELECT COUNTRY, TITLE, CHANNELTITLE, VIEW_COUNT,
        ROW_NUMBER() OVER (PARTITION BY COUNTRY ORDER BY VIEW_COUNT DESC) as RK
    FROM table_youtube_final
    WHERE CATEGORY_TITLE = 'Gaming' AND TRENDING_DATE = '2024-04-11'
) AS ranked_videos
WHERE RK <= 3
ORDER BY COUNTRY, RK;



-- Q2.For each country, count the number of distinct video with a title containing the word “BTS” (case insensitive) and order the result by count in a descending order
SELECT COUNTRY,
    COUNT(DISTINCT(video_id)) AS CT
FROM table_youtube_final
WHERE LOWER(TITLE) LIKE '%bts%'
GROUP BY COUNTRY
ORDER BY CT DESC;



-- Q3. For each country, year and month (in a single column) and only for the year 2024, which video is the most viewed and what is its likes_ratio (defined as the percentage of likes against view_count) truncated to 2 decimals. Order the result by year_month and country.

-- Calculate the view count and likes ratio
WITH year_month_day AS (
    SELECT 
        COUNTRY,
        TRUNC(TRENDING_DATE, 'MONTH') AS YEAR_MONTH,
        TITLE,
        CHANNELTITLE,
        CATEGORY_TITLE,
        VIEW_COUNT,
        LIKES,
        CAST(CAST(LIKES AS FLOAT) / NULLIF(VIEW_COUNT, 0) * 100 AS DECIMAL(10, 2)) AS LIKES_RATIO,
        ROW_NUMBER() OVER (PARTITION BY COUNTRY, TRUNC(TRENDING_DATE, 'MONTH') ORDER BY VIEW_COUNT DESC) AS rn_views
    FROM table_youtube_final
    WHERE YEAR(TRENDING_DATE) = 2024
)
SELECT COUNTRY,
    YEAR_MONTH,
    TITLE,
    CHANNELTITLE,
    CATEGORY_TITLE,
    VIEW_COUNT,
    LIKES,
    LIKES_RATIO
FROM year_month_day
WHERE rn_views = 1 
ORDER BY YEAR_MONTH, COUNTRY;



-- Q4. For each country, which category_title has the most distinct videos and what is its percentage (2 decimals) out of the total distinct number of videos of that country? Only look at the data from 2022. Order the result by category_title and country.

--calculate the total number of distinct videos per country
WITH total_country_videos AS (
    SELECT COUNTRY,
        COUNT(DISTINCT VIDEO_ID) AS TOTAL_COUNTRY_VIDEO
    FROM table_youtube_final
    WHERE EXTRACT(YEAR FROM TRENDING_DATE) >= 2022
    GROUP BY COUNTRY
),

--Calculate the number of distinct videos per category per country
category_video_counts AS (
    SELECT COUNTRY, CATEGORY_TITLE,
        COUNT(DISTINCT VIDEO_ID) AS TOTAL_CATEGORY_VIDEO
    FROM table_youtube_final
    WHERE EXTRACT(YEAR FROM TRENDING_DATE) >= 2022
    GROUP BY COUNTRY, CATEGORY_TITLE
),

--Identify the maximum category video count per country
max_category_country AS (
    SELECT COUNTRY, CATEGORY_TITLE, TOTAL_CATEGORY_VIDEO
    FROM category_video_counts
    WHERE (COUNTRY, TOTAL_CATEGORY_VIDEO) IN (
            SELECT COUNTRY,
                MAX(TOTAL_CATEGORY_VIDEO)
            FROM category_video_counts
            GROUP BY COUNTRY
        )
)
SELECT
    mcc.COUNTRY,
    mcc.CATEGORY_TITLE,
    mcc.TOTAL_CATEGORY_VIDEO,
    tcv.TOTAL_COUNTRY_VIDEO,
    ROUND((mcc.TOTAL_CATEGORY_VIDEO::decimal / tcv.TOTAL_COUNTRY_VIDEO::decimal) * 100, 2) AS PERCENTAGE
FROM max_category_country mcc
JOIN total_country_videos tcv
ON mcc.COUNTRY = tcv.COUNTRY
ORDER BY  mcc.CATEGORY_TITLE, mcc.COUNTRY;



-- Q5. Which channeltitle has produced the most distinct videos and what is this number?
SELECT CHANNELTITLE,
    COUNT(DISTINCT VIDEO_ID) as VIDEO_COUNT
FROM table_youtube_final
GROUP BY CHANNELTITLE
ORDER BY VIDEO_COUNT DESC
LIMIT 1;
-- Answer: Vijay Television with Video count 2049