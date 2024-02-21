SELECT *
FROM app_store_apps;

SELECT *
FROM play_store_apps;


--intersect of the 2 tables with same name
SELECT name, price :: MONEY, rating, review_count :: INTEGER, primary_genre
FROM app_store_apps
INTERSECT
SELECT DISTINCT name, price :: MONEY, rating, review_count, genres  
FROM play_store_apps
ORDER BY review_count DESC;

SELECT name, price :: MONEY, rating, content_rating, review_count :: INTEGER, primary_genre
FROM app_store_apps
-- WHERE rating IS NOT null
ORDER BY review_count DESC;

--highest rating in play_store
SELECT name, price :: MONEY, rating
FROM play_store_apps
WHERE rating IS NOT null
ORDER BY rating DESC;

-- SELECT name, CAST(price as MONEY), content_rating, CAST(review_count as int), primary_genre
-- FROM app_store_apps
-- UNION
-- SELECT name, CAST(price as MONEY), content_rating, CAST(review_count as int), genres
-- FROM play_store_apps

--using cte to create a new table with both combined
WITH both_stores AS 
	(SELECT name, price :: MONEY, rating
	FROM app_store_apps
	INTERSECT
	SELECT name, price :: MONEY, rating
	FROM play_store_apps)
SELECT *
FROM both_stores
ORDER BY rating DESC;