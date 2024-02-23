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






WITH both_stores AS(
	SELECT
	name,
	'App Store' as store,
	CAST(price as MONEY) as price,
	content_rating,
	rating,
	CAST(review_count as int),
	primary_genre
FROM app_store_apps
UNION ALL
SELECT
	 name,
	'Play Store' as store,
	CAST(price as MONEY),
	content_rating,
	rating,
	CAST(review_count as int),
	genres
FROM play_store_apps)
---Begin main query to build table
SELECT both_stores.name AS app_name,
	COUNT(DISTINCT both_stores.store) AS store_count,
	(SELECT GREATEST(
     		(SELECT MAX(app_store_apps.price) :: MONEY FROM app_store_apps),
			(SELECT MAX(play_store_apps.price) :: MONEY FROM play_store_apps))) AS app_price
FROM both_stores, app_store_apps, play_store_apps
GROUP BY app_name






--Script CTE.  Union all stacks app store data on top of play store data
WITH both_stores AS(
	SELECT
	name,
	'App Store' as store,
	CAST(price as MONEY) as price,
	content_rating,
	ROUND(1+(2*(ROUND((rating) * 2, 0) / 2)),2) as lifespan,
	CAST(review_count as int),
	primary_genre
FROM app_store_apps
UNION ALL
SELECT
	 name,
	'Play Store' as store,
	CAST(price as MONEY),
	content_rating,
	ROUND(1+(2*(ROUND((rating) * 2, 0) / 2)),2) as lifespan,
	CAST(review_count as int),
	genres
FROM play_store_apps)
SELECT
	both_stores.*,
	app_price.app_price,
	(1000*12*(lifespan)) as lifespan_mktg_spend,
	case when app_price.app_price < 1
		THEN 10000
		ELSE app_price.app_price * 10000 end as purchase_price
-- 	CASE WHEN cast(trim(replace(app_price.app_price,'$','')) as numeric(5,2))  > 1
--  	  	THEN cast(trim(replace(app_price.app_price,'$',''))as numeric(5,2))  * 10000
--  		ELSE 10000 END AS purchase_price
FROM both_stores
---Begin main query to build table
-- SELECT
-- 	both_stores.name AS app_name,
-- 	COUNT(DISTINCT both_stores.store) AS store_count,
-- 	ROUND((rating) * 2, 0) / 2 as rating
INNER JOIN
(SELECT name, MAX(price) as app_price
FROM (SELECT name, price :: MONEY FROM app_store_apps
UNION
SELECT name, price :: MONEY FROM play_store_apps) as all_price GROUP BY name) as app_price
ON both_stores.name = app_price.name