-- Find the top 3 categories in each country based on their views and likes
WITH category_aggregates AS (
    SELECT COUNTRY, 
        CATEGORY_TITLE, 
        SUM(VIEW_COUNT) AS total_views, 
        SUM(LIKES) AS total_likes
    FROM table_youtube_final
    GROUP BY COUNTRY, CATEGORY_TITLE
),
ranked_categories AS (
    SELECT COUNTRY, 
        CATEGORY_TITLE, 
        total_views, 
        total_likes,
        ROW_NUMBER() OVER (PARTITION BY COUNTRY ORDER BY total_views DESC, total_likes DESC) AS rn
    FROM category_aggregates
)
SELECT COUNTRY, 
    CATEGORY_TITLE, 
    total_views, 
    total_likes
FROM ranked_categories
WHERE rn <= 3
ORDER BY COUNTRY, rn;



-- Top Category in each country (apart from Music and Entertainment)
WITH top_categories AS (
    SELECT 
        COUNTRY,
        CATEGORY_TITLE,
        SUM(VIEW_COUNT) AS total_views,
        RANK() OVER (PARTITION BY COUNTRY ORDER BY total_views DESC) AS rank
    FROM table_youtube_final
    WHERE CATEGORY_TITLE NOT IN ('Music', 'Entertainment')
    GROUP BY COUNTRY, CATEGORY_TITLE
)
SELECT 
    COUNTRY,
    CATEGORY_TITLE,
    total_views,
    rank;
    
    
    
-- Category (apart from music) with the maximum number of views 
SELECT CATEGORY_TITLE,
    SUM(VIEW_COUNT) as TOTAL_VIEWS
FROM table_youtube_final
WHERE CATEGORY_TITLE != 'Music' AND CATEGORY_TITLE != 'Entertainment'
GROUP BY CATEGORY_TITLE
ORDER BY TOTAL_VIEWS DESC
LIMIT 1;
FROM top_categories
WHERE rank = 1;




