--Part 2
--Q1. In “table_youtube_category” which category_title has duplicates if we don’t take into account the categoryid (return only a single row)?
SELECT 
CATEGORY_TITLE
FROM 
table_youtube_category
GROUP BY 
CATEGORY_TITLE
HAVING 
COUNT(DISTINCT CATEGORYID) > 1;
-- Answer = Comedy



--Q2. In “table_youtube_category” which category_title only appears in one country?
SELECT 
CATEGORY_TITLE,
max(COUNTRY) as COUNTRY
FROM
table_youtube_category
GROUP BY 
CATEGORY_TITLE
HAVING
COUNT(DISTINCT COUNTRY) = 1;
-- Answer = Nonprofits & Activism in US



--Q3. In “table_youtube_final”, what is the categoryid of the missing category_title?
SELECT
DISTINCT(CATEGORYID),
FROM
table_youtube_final
WHERE
category_title IS NULL;
-- Answer = 29



--Q4. Update the table_youtube_final to replace the NULL values in category_title with the answer from the previous question.
UPDATE table_youtube_final
SET CATEGORY_TITLE = 'Nonprofits & Activism'
WHERE CATEGORYID = 29;



--Q5. In “table_youtube_final”, which video doesn’t have a channeltitle (return only the title)?
SELECT
TITLE
FROM 
table_youtube_final
WHERE 
CHANNELTITLE IS NULL;
-- Answer = Kala Official Teaser | Tovino Thomas | Rohith V S | Juvis Productions | Adventure Company



--Q6. Delete from “table_youtube_final“, any record with video_id = “#NAME?”
DELETE FROM table_youtube_final
WHERE video_id = '#NAME?';
-- Answer = Deleted 32081 rows



--Q7. Create a new table called “table_youtube_duplicates”  containing only the “bad” duplicates by using the row_number() function.
CREATE OR REPLACE TABLE table_youtube_duplicates AS
WITH ranked_duplicates AS (
SELECT *,
ROW_NUMBER() OVER (
    PARTITION BY VIDEO_ID, COUNTRY, TRENDING_DATE 
    ORDER BY VIEW_COUNT DESC
) AS rn
FROM table_youtube_final
)
SELECT *
FROM ranked_duplicates
WHERE rn > 1;
;

-- Verification
SELECT COUNT(*) FROM table_youtube_duplicates;
-- Answer = 37466



--Q8. Delete the duplicates in “table_youtube_final“ by using “table_youtube_duplicates”.
DELETE from table_youtube_final fi
WHERE (fi.ID)
IN (
    SELECT (du.ID)
    FROM table_youtube_duplicates du
)

-- Verification
SELECT COUNT(*) FROM table_youtube_final;
-- Answer 2597494
