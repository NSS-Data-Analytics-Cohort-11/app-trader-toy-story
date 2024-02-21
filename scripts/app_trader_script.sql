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

--Of those in both tables, what are the top ten highest rated apps?
SELECT DISTINCT name
FROM play_store_apps
INTERSECT
SELECT DISTINCT name
FROM app_store_apps
WHERE rating >= 4.0;

--ANSWER


-- SELECT name, CAST(price as MONEY), content_rating, CAST(review_count as int), primary_genre, rating
-- FROM app_store_apps
-- UNION
-- SELECT name, CAST(price as MONEY), content_rating, CAST(review_count as int), genres, rating
-- FROM play_store_apps
-- ORDER BY rating DESC;

WITH both_stores AS(
	SELECT 'App Store' as store, 
	name, CAST(price as MONEY) as price,
	content_rating, rating, CAST(review_count as int), primary_genre
FROM app_store_apps
UNION
SELECT 'Play Store'
	name, CAST(price as MONEY), content_rating, rating, CAST(review_count as int), genres
FROM play_store_apps)

SELECT name, COUNT(store) as no_of_stores, MAX(price), ROUND(AVG(rating,1)), content_rating, primary_genre
FROM both_stores
WHERE content_rating IS NOT NULL
GROUP BY name, content_rating, primary_genre
ORDER BY content_rating DESC
HAVING COUNT(store) = 2