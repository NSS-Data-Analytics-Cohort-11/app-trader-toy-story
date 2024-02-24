WITH both_stores AS(
	SELECT
		name,
		'App Store' as store,
		CAST(price as MONEY) as price,
		--content_rating,
		(ROUND((rating) * 2, 0) / 2) as rating,
		ROUND(1+(2*(ROUND((rating) * 2, 0) / 2)),2) as lifespan,
		CAST(review_count as int),
		primary_genre
	FROM app_store_apps
	group by name, store, price, rating, primary_genre, review_count
UNION ALL
	SELECT
	 p.name,
	'Play Store' as store,
	CAST(p.price as MONEY),
	--content_rating,
	(ROUND((p.rating) * 2, 0) / 2) as rating,
	ROUND(1+(2*(ROUND((p.rating) * 2, 0) / 2)),2) as lifespan,
	CAST(p.review_count as int), 
	a.primary_genre
FROM play_store_apps p
left join app_store_apps a
	on p.name = a.name
group by p.name, store, p.price, p.rating, p.genres,a.primary_genre, p.review_count)

-- select b.*, concat(a.primary_genre, p.genres) as genre
-- from both_stores b
-- left join app_store_apps a
-- on b.name = a.name
-- left join play_store_apps p
-- on b.name = p.name



SELECT
--BASIC METRICS SOURCED FROM CTE
	both_stores.name as app_name,
	--genre.primary_genre as genre,
	SUM(review_count) as total_review_count,
	ROUND(both_stores.rating,1) as app_rating,
	COUNT(DISTINCT both_stores.store) AS store_count,
	app_price.max_price,
--BEGIN CALCULATED METRICS
--Purchase price
	CASE WHEN app_price.max_price < (1 :: MONEY)
		THEN (10000 :: MONEY)
		ELSE app_price.max_price * 10000 END AS purchase_price,
		
--lifetime marketing spend
	((1000 :: MONEY)*12*(lifespan)) as lifespan_mktg_spend,
	
--lifetime income
	((5000 :: MONEY)*COUNT(DISTINCT both_stores.store))*12*(lifespan) as lifetime_income,
	
--calculate lifetime profit
	((CASE WHEN app_price.max_price < (1 :: MONEY)
		THEN (10000 :: MONEY)
		ELSE app_price.max_price * 10000 END)*-1 -- purchase price as cost (-)
 		+ ((-(1000*12*(lifespan))) :: MONEY) -- marketing spend as cost (-)
 		+ (COUNT(DISTINCT both_stores.store))*(5000 :: MONEY)*12*(lifespan)) as lifetime_profit -- lifetime income as profit (+)
FROM both_stores
--join in max price from two stores
INNER JOIN
	(SELECT
	 	name,
	 	MAX(price) as max_price
FROM
	 (SELECT name,
	  	price :: MONEY FROM app_store_apps
		UNION
		SELECT name,
	 	price :: MONEY FROM play_store_apps) as all_price
GROUP BY name) as app_price
	ON both_stores.name = app_price.name
--join in genre name from single source
-- INNER JOIN
-- 	(SELECT
-- 	 	name,
-- 	 	primary_genre
-- 	 	FROM app_store_apps) as genre
-- 	ON both_stores.name = genre.name
where ROUND(both_stores.rating,1) IS NOT NULL
GROUP BY both_stores.name, app_price.max_price, both_stores.lifespan, both_stores.rating--, genre.primary_genre--, total_review_count
ORDER BY lifetime_profit DESC,
total_review_count DESC
LIMIT 10







--CTE. Union All stacks app store data on top of play store data
WITH both_stores AS(
	SELECT
		name,
		'App Store' as store,
		CAST(price as MONEY) as price,
		--content_rating,
		(ROUND((rating) * 2, 0) / 2) as rating,
		ROUND(1+(2*(ROUND((rating) * 2, 0) / 2)),2) as lifespan,
		CAST(review_count as int),
		primary_genre
	FROM app_store_apps
UNION ALL
	SELECT
	 name,
	'Play Store' as store,
	CAST(price as MONEY),
	--content_rating,
	(ROUND((rating) * 2, 0) / 2) as rating,
	ROUND(1+(2*(ROUND((rating) * 2, 0) / 2)),2) as lifespan,
	CAST(review_count as int),
	genres
FROM play_store_apps)

--Main Query
SELECT
	both_stores.name as app_name,
	genre.primary_genre,
	both_stores.rating as app_rating,
	SUM(review_count) as total_review_count,
	COUNT(DISTINCT both_stores.store) AS store_count,
	app_price.app_price,
	((1000 :: MONEY)*12*(lifespan)) as lifespan_mktg_spend,
	CASE WHEN app_price.app_price < (1 :: MONEY)
		THEN (10000 :: MONEY)
		ELSE app_price.app_price * 10000 END AS purchase_price,
		
	((5000 :: MONEY)*COUNT(DISTINCT both_stores.store))*12*(lifespan) as lifetime_income,
	
	((CASE WHEN app_price.app_price < (1 :: MONEY)
		THEN (10000 :: MONEY)
		ELSE app_price.app_price * 10000 END)*-1-- purchase price as cost (-)
	
 		+ ((-(1000*12*(lifespan))) :: MONEY) -- marketing spend as cost (-)
	
	
 		+ (COUNT(DISTINCT both_stores.store))*(5000 :: MONEY)*12*(lifespan)) as lifetime_profit -- lifetime income as profit (+)
		
FROM both_stores
INNER JOIN
	(SELECT
	 	name,
	 	primary_genre
	 	FROM app_store_apps) as genre
	ON both_stores.name = genre.name

INNER JOIN
	(SELECT
	 	name,
	 	MAX(price) as app_price
FROM
	 (SELECT name,
	  price :: MONEY FROM app_store_apps
UNION
	SELECT name,
	  price :: MONEY FROM play_store_apps) as all_price
	 GROUP BY name) as app_price
	ON both_stores.name = app_price.name
	WHERE both_stores.rating IS NOT NULL
	AND both_stores.rating >= 4.5
GROUP BY both_stores.name, genre.primary_genre, app_price, both_stores.lifespan, both_stores.rating
ORDER BY lifetime_profit DESC, total_review_count DESC;




-- SELECT DISTINCT name, primary_genre, SUM(review_count) as total_review_count
-- FROM both_stores
-- WHERE both_stores.rating >= 4.5
-- GROUP BY name, primary_genre, price, rating
-- ORDER BY total_review_count DESC
-- LIMIT 25


--CTE. Union All stacks app store data on top of play store data
WITH both_stores AS(
	SELECT
		name,
		'App Store' as store,
		CAST(price as MONEY) as price,
		--content_rating,
		(ROUND((rating) * 2, 0) / 2) as rating,
		ROUND(1+(2*(ROUND((rating) * 2, 0) / 2)),2) as lifespan,
		CAST(review_count as int),
		primary_genre
	FROM app_store_apps
UNION ALL
	SELECT
	 name,
	'Play Store' as store,
	CAST(price as MONEY),
	--content_rating,
	(ROUND((rating) * 2, 0) / 2) as rating,
	ROUND(1+(2*(ROUND((rating) * 2, 0) / 2)),2) as lifespan,
	CAST(review_count as int),
	genres
FROM play_store_apps)

SELECT DISTINCT name,  SUM(review_count) as total_review_count
FROM both_stores
WHERE both_stores.rating >= 4.5
GROUP BY name, price, rating
ORDER BY total_review_count DESC
LIMIT 25;


























--Script CTE.  Union all stack app store data on top of play store data
-- WITH both_stores AS(
-- 	SELECT
-- 	name,
-- 	'App Store' as store,
-- 	CAST(price as MONEY) as price,
-- 	content_rating,
-- 	ROUND(1+(2*(ROUND((rating) * 2, 0) / 2)),2) as lifespan,
-- 	CAST(review_count as int),
-- 	primary_genre
-- FROM app_store_apps
-- UNION ALL
-- SELECT
-- 	 name,
-- 	'Play Store' as store,
-- 	CAST(price as MONEY),
-- 	content_rating,
-- 	ROUND(1+(2*(ROUND((rating) * 2, 0) / 2)),2) as lifespan,
-- 	CAST(review_count as int),
-- 	genres
-- FROM play_store_apps)
-- SELECT both_stores.*,
-- 	app_price.app_price,
-- 	(1000*12*(lifespan)) as lifespan_mktg_spend,
-- 	CASE WHEN app_price.app_price < 1
-- 		THEN 10000
-- 		ELSE app_price.app_price * 10000 
-- 		END AS purchase_price
-- 	CASE WHEN CAST(TRIM(REPLACE(app_price.app_price,'$','')) as numeric(5,2))  > 1
--  	  	THEN CAST(TRIM(REPLACE(app_price.app_price,'$',''))as numeric(5,2))  * 10000
--  		ELSE 10000 END AS purchase_price
-- FROM both_stores
-- ---Begin main query to build table
-- SELECT both_stores.name AS app_name,
-- 	COUNT(DISTINCT both_stores.store) AS store_count,
-- 	ROUND((rating) * 2, 0) / 2 as rating
-- INNER JOIN
-- (SELECT name, MAX(price) as app_price
-- FROM (SELECT name, price :: MONEY FROM app_store_apps
-- UNION
-- SELECT name, price :: MONEY FROM play_store_apps) as all_price 
--  GROUP BY name) as app_price
-- ON both_stores.name = app_price.name
















































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






--Script CTE.  Union all stack app store data on top of play store data
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
FROM play_store_apps
SELECT
	both_stores.*,
	app_price.app_price,
	(1000*12*(lifespan)) as lifespan_mktg_spend
	case when app_price.app_price < 1
		THEN 10000
		ELSE app_price.app_price * 10000 end as purchase_price
	CASE WHEN cast(trim(replace(app_price.app_price,'$','')) as numeric)  > 1
 	  	THEN cast(trim(replace(app_price.app_price,'$',''))as numeric)  * 10000
 		ELSE 10000 END AS purchase_price
FROM both_stores)
---Begin main query to build table
SELECT
	both_stores.name AS app_name,
	COUNT(DISTINCT both_stores.store) AS store_count,
	ROUND((rating) * 2, 0) / 2 as rating
INNER JOIN
(SELECT name, MAX(price) as app_price
FROM (SELECT name, price :: MONEY FROM app_store_apps
UNION
SELECT name, price :: MONEY FROM play_store_apps) as all_price GROUP BY name) as app_price
ON both_stores.name = app_price.name