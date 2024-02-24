SELECT *
FROM app_store_apps;

SELECT *
FROM play_store_apps

ORDER BY price::MONEY DESC;


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
	UNION ALL
	SELECT name, price :: MONEY, rating
	FROM play_store_apps)
SELECT name, 
FROM both_stores
GROUP BY name;


ORDER BY avg_rating DESC;

-- AVERAGE NUMBER OF REVIEWS- 272074.493873704053
WITH both_stores AS 
	(SELECT name, price :: MONEY, rating, review_count :: INTEGER
	FROM app_store_apps
	UNION ALL
	SELECT name, price :: MONEY, rating, review_count :: INTEGER
	FROM play_store_apps)
SELECT AVG(review_count)
FROM both_stores;


SELECT *
FROM app_store_apps
WHERE name ILIKE 'ROBLOX';
-- shows this app 1x

SELECT *
FROM play_store_apps
WHERE name ILIKE 'ROBLOX';
-- shows this app 9x

--compare price in both stores
WITH both_stores AS 
	(SELECT name, price :: MONEY, rating
	FROM app_store_apps
	UNION ALL
	SELECT name, price :: MONEY, rating
	FROM play_store_apps)
	
	
-- SELECT name,
--  (SELECT price :: MONEY
--   FROM app_store_apps) As app_store_price,
--   (SELECT price :: MONEY, rating
-- 	FROM play_store_apps) AS play_store_price
-- FROM both_stores

SELECT app_store_apps.name, play_store_apps.name, price :: MONEY
FROM (SELECT name
	  FROM both_stores
		WHERE app_store_apps.name = play_store_apps.name);
		
		
--Apps in both stores with different prices		
SELECT name, app_store_apps.price :: MONEY AS app_store_price, play_store_apps.price :: MONEY AS play_store_price
FROM app_store_apps
INNER JOIN play_store_apps
USING (name)
WHERE app_store_apps.name = play_store_apps.name
	AND app_store_apps.price :: MONEY <> play_store_apps.price :: MONEY;
-- ORDER BY play_store_price, app_store_price DESC;

--subquery for max app price
SELECT name, MAX(price) AS app_price
FROM (SELECT name, price :: MONEY
	 FROM app_store_apps
	 UNION
	 SELECT name, price :: MONEY
	 FROM play_store_apps) AS all_price
Group By name;





--hayley query- resolving errors-** MOST UPDATED
WITH both_stores AS(
	SELECT
	name,
	'App Store' as store,
	CAST(price as MONEY) as price,
	ROUND((rating)*2,0)/2 AS avg_rating, --correct rounding s there is no 0
	ROUND(1+(2*(ROUND((rating)*2,0)/2)) AS lifespan,
	CAST(review_count as int),
	primary_genre
FROM app_store_apps
UNION ALL
SELECT
	 name,
	'Play Store' as store,
	CAST(price as MONEY),
	ROUND((rating)*2,0)/2 AS avg_rating, --correct rounding s there is no 0
	ROUND(1+(2*(ROUND((rating)*2,0)/2))) AS lifespan,   
	CAST(review_count as int),
	genres
FROM play_store_apps
---Begin main query to build table
SELECT
	both_stores.name AS app_name,
	both_stores.rating AS app_rating,
	COUNT(DISTINCT)	  app_price.app_price,
	   (1000*12*(lifespan)) AS total_mktg_cost
	CASE WHEN app_price.app_price < 1
	   THEN 10000
	   ELSE app_price.app_price * 10000 END AS 	
	   purchase_price
FROM both_stores
INNER JOIN
	(SELECT name, 
	 MAX(price) as app_price
	FROM (SELECT name, 
		  price :: MONEY 
		  FROM app_store_apps
UNION
	SELECT name, price :: MONEY 
		  FROM play_store_apps) as all_price 
	 GROUP BY name) as app_price
	ON both_stores.name = app_price.name;
		  
		  
		  

 -- USING SUBQUERY AS CTE

-- WITH both_stores AS(
-- 	SELECT
-- 	name,
-- 	'App Store' as store,
-- 	CAST(price as MONEY) as price,
-- 	content_rating,
-- 	rating,
-- 	CAST(review_count as int),
-- 	primary_genre
-- FROM app_store_apps
-- UNION ALL
-- SELECT
-- 	 name,
-- 	'Play Store' as store,
-- 	CAST(price as MONEY),
-- 	content_rating,
-- 	rating,
-- 	CAST(review_count as int),
-- 	genres
-- FROM play_store_apps),

-- app_price AS (
--  (GREATEST(
--      		(SELECT MAX(app_store_apps.price) :: MONEY FROM app_store_apps),
-- 			(SELECT MAX(play_store_apps.price) :: MONEY FROM play_store_apps)))		


--final result--

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
ON both_stores.name = app_price.name;
	
	
	
--hayley query- resolving errors-** MOST UPDATED
WITH both_stores AS(
	SELECT
	name,
	'App Store' as store,
	CAST(price as MONEY) as price,
	ROUND((rating)*2,0)/2 AS avg_rating, --correct rounding s there is no 0
	ROUND(1+(2*(ROUND((rating)*2,0)/2))) AS lifespan,
	CAST(review_count as int),
	primary_genre
FROM app_store_apps
UNION ALL
SELECT
	 name,
	'Play Store' as store,
	CAST(price as MONEY),
	ROUND((rating)*2,0)/2 AS avg_rating, --correct rounding s there is no 0
	ROUND(1+(2*(ROUND((rating)*2,0)/2))) AS lifespan,   
	CAST(review_count as int),
	genres
FROM play_store_apps)
---Begin main query to build table
SELECT
	both_stores.name AS app_name,
	both_stores.rating AS app_rating,
	COUNT(DISTINCT both_stores.store) AS store_count	  		app_price.app_price,
	   (1000*12*(lifespan)) AS total_mktg_cost,
		  
	CASE WHEN app_price.app_price < (1 :: MONEY)
	   THEN (10000 :: MONEY)
	   ELSE app_price.app_price * 10000 END AS 	
	   purchase_price,
		  
	((5000 :: MONEY) *(COUNT(DISTINCT both_stores.store)*12*	(lifespan)) AS lifetime_ income,
	 
	 ((CASE WHEN app_price.app_price < (1 :: MONEY)
	   THEN (10000 :: MONEY)
		ELSE app_price.app_price * 10000 END)*-1-- purchase price as cost (-)
	
 		+ ((-(1000*12*(lifespan))) :: MONEY) -- marketing spend as cost (-)
	
	
 		+ (COUNT(DISTINCT both_stores.store))*(5000 :: MONEY)*12*(lifespan)) as lifetime_profit -- lifetime income as profit (+)
	 
	 
FROM both_stores
INNER JOIN
	(SELECT name, 
	 MAX(price) as app_price
	FROM (SELECT name, 
		  price :: MONEY 
		  FROM app_store_apps
UNION
	SELECT name, price :: MONEY 
		  FROM play_store_apps) as all_price 
	 GROUP BY name) as app_price
	ON both_stores.name = app_price.name;
	
GROUP BY both_stores.name, app_price, both_stores.lifespan, both_stores.rating
ORDER BY lifetime_profit DESC;
	 
	 
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
-- 	WHERE rating IS NULL

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
-- 	 WHERE rating IS NULL)
--Main Query
SELECT
	both_stores.name as app_name,
	genre.primary_genre,
	both_stores.rating as app_rating,
	COUNT(DISTINCT both_stores.store) AS store_count,
	app_price.app_price,
	 --lifespan marketing expenditure
	((1000 :: MONEY)*12*(lifespan)) as lifespan_mktg_spend,
	 --calculated purchase price
	CASE WHEN app_price.app_price < (1 :: MONEY)
		THEN (10000 :: MONEY)
		ELSE app_price.app_price * 10000 END AS purchase_price,
	 
	 --calculated earnings over lifetime
		
	((5000 :: MONEY)*COUNT(DISTINCT both_stores.store))*12*(lifespan) as lifetime_income,
	
	 --calcualted lifetime prices
	((CASE WHEN app_price.app_price < (1 :: MONEY)
		THEN (10000 :: MONEY)
		ELSE app_price.app_price * 10000 END)*-1-- purchase price as cost (-)
	
 		+ ((-(1000*12*(lifespan))) :: MONEY) -- marketing spend as cost (-)
	
	
 		+ (COUNT(DISTINCT both_stores.store))*(5000 :: MONEY)*12*(lifespan)) as lifetime_profit -- lifetime income as profit (+)
		
FROM both_stores
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
INNER JOIN (SELECT
	 	name,
	 	primary_genre
	 	FROM app_store_apps) as genre
	ON both_stores.name = genre.name
	 
WHERE both_stores.rating IS NOT null
GROUP BY both_stores.name, app_price, both_stores.lifespan, both_stores.rating, genre.primary_genre
HAVING COUNT(DISTINCT both_stores.store)*(5000 :: MONEY)*12*(lifespan) >= 1070000::MONEY
ORDER BY lifetime_profit DESC;

----REVIEW COUNT CALCULATION---
	 
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
	 SELECT DISTINCT name, primary_genre, SUM(review_count) as total_review_count
FROM both_stores
WHERE both_stores.rating >= 4.5
GROUP BY name, primary_genre, price, rating
ORDER BY total_review_count DESC
LIMIT 25

-- including review counts from both stores QUERY BELOW

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
	genre.primary_genre as genre,
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
INNER JOIN
	(SELECT
	 	name,
	 	primary_genre
	 	FROM app_store_apps) as genre
	ON both_stores.name = genre.name
where ROUND(both_stores.rating,1) IS NOT NULL
GROUP BY both_stores.name, app_price.max_price, both_stores.lifespan, both_stores.rating, genre.primary_genre--, total_review_count
ORDER BY lifetime_profit DESC,
total_review_count DESC
LIMIT 10
		  
