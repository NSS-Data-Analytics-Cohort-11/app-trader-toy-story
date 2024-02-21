--How many unique names are there in total for both tables?
SELECT DISTINCT name
FROM play_store_apps
UNION
SELECT DISTINCT name
FROM app_store_apps;

--ANSWER 16,526

--How many apps are in both stores?
SELECT DISTINCT name
FROM play_store_apps
INTERSECT
SELECT DISTINCT name
FROM app_store_apps;

--ANSWER 328



--Of those in both tables, how many are rated '5.0'?

SELECT name, CAST(price as MONEY), content_rating, CAST(review_count as int), primary_genre, rating
FROM app_store_apps
UNION
SELECT name, CAST(price as MONEY), content_rating, CAST(review_count as int), genres, rating
FROM play_store_apps
WHERE rating IS NOT NULL AND rating = '5.0'
ORDER BY rating DESC;

--ANSWER 7468

-- How many have a 5.0 rating AND a content_rating of 'Everyone'?
SELECT name, CAST(price as MONEY), content_rating, CAST(review_count as int), primary_genre, rating
FROM app_store_apps
UNION
SELECT name, CAST(price as MONEY), content_rating, CAST(review_count as int), genres, rating
FROM play_store_apps
WHERE rating IS NOT NULL AND rating = '5.0' AND content_rating = 'Everyone'
ORDER BY content_rating DESC;

--ANSWER 237

SELECT name, CAST(price as MONEY), content_rating, CAST(review_count as int), primary_genre, rating
FROM app_store_apps
UNION
SELECT name, CAST(price as MONEY), content_rating, CAST(review_count as int), genres, rating
FROM play_store_apps
WHERE rating IS NOT NULL AND rating = '5.0' AND review_count >= '2000000'
ORDER BY review_count DESC;