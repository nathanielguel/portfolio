** EXPLORATORY DATA ANALYSIS **

-- Check the number of unique apps in both tables match
SELECT count(DISTINCT id) AS uniqueAppIDs
FROM "AppleStore" as2;

SELECT count(DISTINCT id) AS uniqueAppIDs
FROM "appleStore_description" asd;

-- Check for any missing values in key fields
SELECT count(*) AS missingValues
FROM "AppleStore" as2
WHERE
    track_name IS NULL
    OR user_rating IS NULL
    OR prime_genre IS NULL;

SELECT count(*) AS missingValues
FROM "appleStore_description" asd
WHERE app_desc IS NULL;

-- Find out the number of apps per genre
SELECT
    prime_genre,
    count(*) AS numApps
FROM "AppleStore" as2
GROUP BY prime_genre
ORDER BY numApps DESC;

-- Get an overview of the app ratings
SELECT
    min(user_rating) AS minRating,
    max(user_rating) AS maxRating,
    avg(user_rating) AS avgRating
FROM "AppleStore" as2;

** DATA ANALYSIS **

-- Determine whether paid apps have higher ratings than free apps
SELECT
    CASE
        WHEN price > 0 THEN 'paid'
        ELSE 'free'
    END AS appType,
    avg(user_rating) AS avgRating
FROM "AppleStore" as2
GROUP BY appType;

-- Check if apps with more supported languages have higher ratings
SELECT
    CASE 
        WHEN lang_num < 10 THEN '<10 languages'
        WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
        ELSE '>10 languages'
    END AS language_bucket,
    avg(user_rating) AS avgRating
FROM "AppleStore" as2
GROUP BY language_bucket
ORDER BY avgRating DESC;

-- Check genres with low ratings
SELECT 
    prime_genre,
    avg(user_rating) AS avgRating
FROM "AppleStore" as2 
GROUP BY prime_genre 
ORDER BY avg_rating ASC
LIMIT 10;

-- Check if there is correlation between the length of the app description and the user rating
SELECT 
    CASE
        WHEN length(asd.app_desc) < 500 THEN 'Short'
        WHEN length(asd.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
        ELSE 'Long'
    END AS descriptionLengthBucket,
    avg(as2.user_rating) AS avgRating
FROM "AppleStore" as2
JOIN "appleStore_description" asd 
    ON as2.id = asd.id
GROUP BY descriptionLengthBucket
ORDER BY avgRating DESC;

-- Check the top-rated apps for each genre
SELECT 
    prime_genre,
    track_name,
    user_rating
FROM 
    (
        SELECT
            prime_genre,
            track_name,
            user_rating,
            RANK() OVER (
                PARTITION BY prime_genre
                ORDER BY
                    user_rating DESC,
                    rating_count_tot DESC
            ) AS RANK
        FROM
            "AppleStore" as2
    ) AS as3
WHERE as3.RANK = 1