# Big-Data---Data-Lakehouse
Analyse a dataset (made of CSVs and Jsons files) by using a Data Lakehouse with Snowflake by uploading the data onto a cloud storage (Azure), ingesting it into the data lakehouse, perform data transformations, and finally analysing it.

Aim:
This project aims to analyse a dataset (made of CSVs and Jsons files) using a Data Lakehouse with Snowflake. You will have to upload the data on a cloud storage, ingest the data into the Data Lakehouse, perform data transformation and finally analyse it.

# Introduction to the dataset
YouTube (the world-famous video sharing website) maintains a list of the top trending videos on the platform. According to Variety magazine, “To determine the year’s top-trending videos, YouTube uses a combination of factors including measuring users' interactions (e.g. number of views, shares, comments and likes). 

A dataset with a daily record of the top trending YouTube videos has been extracted through the Youtube API and made available on the Kaggle (https://www.kaggle.com/rsrishav/youtube-trending-video-dataset)
This dataset includes several months (from 2020-08-12 to 2024-04-15) of data of daily trending YouTube videos. Data is included for the IN, US, GB, DE, CA, FR, BR, MX, KR, and JP regions (India, USA, Great Britain, Germany, Canada, France, Brazil, Mexico, South Korea, and Japan respectively), with up to 200 listed trending videos per day.
Each region’s data is in a separate file. Data includes the video title, channel title, published time, views, likes and dislikes and comment count:

The data also includes a category_id field, which varies between regions. To retrieve the categories for a specific video, find it in the associated JSON. One such file is included for each of the 10 regions in the dataset.


Tasks:
You will need your cloud storage account on Microsoft Azure and your Snowflake account.

Your tasks will be:

# PART 1: Data Ingestion
Provide a sql file containing all the sql code used in Snowflake for part 1 and called it “part_1.sql”:

Download the (compressed) dataset on:
Trending data: https://drive.google.com/file/d/14xKzN4MEtCr1lZ_8w0JKwBTCjo-CBLlL/view?usp=sharing

Category data: 
https://drive.google.com/file/d/1uhkOwCCQK7LoER6tXZpsVbIfAr-CJomJ/view?usp=sharing

Upload the dataset in your storage account on Azure
On Snowflake:
1. Create a database called: “assignment_1”
2. Create a stage called “stage_assignment”, pointing to your azure storage
3. Ingest the data as external tables on Snowflake
4. Create two external tables “ex_table_youtube_trending” and “ex_table_youtube_category” with the correct data type.
5. Transfer the data from external tables into tables with the following columns:

Create a final table called “table_youtube_final” by combining “table_youtube_trending” and  “table_youtube_category” on country and categoryid (be careful to not lose any records), while adding a new field called ideas by using the “UUID_STRING()” function :

You should end up with 2,667,041 rows in table_youtube_final

# PART 2: Data Cleaning 
Provide a sql file containing all the sql code used in Snowflake for part 2 and called it “part_2.sql” (add comments to separate each questions):

1. In “table_youtube_category” which category_title has duplicates if we don’t take into account the categoryid (return only a single row)?
2. In “table_youtube_category” which category_title only appears in one country?
3. In “table_youtube_final”, what is the categoryid of the missing category_titles?
4. Update the table_youtube_final to replace the NULL values in category_title with the answer from the previous question.
5. In “table_youtube_final”, which video doesn’t have a channeltitle (return only the title)?
6. Delete from “table_youtube_final“, any record with video_id = “#NAME?”

The “table_youtube_final“ contains duplicates with the same video_id, country and trending_date however their metrics (likes, dislikes, etc..) can be different. E.g:


We can assume that the highest number of view_count will be the record to keep when we have duplicates.

Create a new table called “table_youtube_duplicates”  containing only the “bad” duplicates by using the row_number() function.
Delete the duplicates in “table_youtube_final“ by using “table_youtube_duplicates”.
Count the number of rows in “table_youtube_final“ and check that it is equal to 2,597,494 rows.

# PART 3: Data Analysis
Provide a sql file containing the sql code used: 

What are the 13 most viewed videos for each country in the Gamingse category for the trending_date = ‘'2024-04-011. Order the result by country and the rank, e.g:

For each country, count the number of distinct video with a title containing the word “BTSa” (case insensitive) and order the result by count in a descending order, e.g:

For each country, year and month (in a single column) and only for the yearefore2024, which video is the most viewed and what is its likes_ratio (defined as the percentage of likes against view_count) truncated to 12 decimals. Order the result by year_month and country. The output should like this:

For each country, which category_title has the most distinct videos and what is its percentage (12 decimals) out of the total distinct number of videos of that country? Only look at the data frombefore2022. Order the result by category_title and country. The output should like this:

Which channeltitle has produced the most distinct videos and what is this number *10? 


# PART 4: Business Question
Provide a single sql file containing all the queries used:

If you were to launch a new Youtube channel tomorrow, which category (excluding “Music” and “Entertainment”) of video will you be trying to create to have them appear in the top trend of YoutubeinUS? Will this strategy work in every country?
