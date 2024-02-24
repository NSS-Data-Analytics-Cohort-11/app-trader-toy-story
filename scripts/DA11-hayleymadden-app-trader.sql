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
--BASIC METRICS SOURCED FROM CTE
	both_stores.name as app_name,
	--genre.primary_genre as genre,
	total_review_count.total_review_count as total_review_count,
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
	
INNER JOIN(
	SELECT name, SUM(review_count) as total_review_count
	FROM both_stores
GROUP BY name) as total_review_count
	ON both_stores.name = total_review_count.name
	
WHERE both_stores.rating IS NOT NULL

GROUP BY total_review_count.total_review_count, both_stores.name, app_price.max_price, both_stores.lifespan, both_stores.rating --genre.primary_genre
ORDER BY lifetime_profit DESC, 
total_review_count DESC
LIMIT 10






