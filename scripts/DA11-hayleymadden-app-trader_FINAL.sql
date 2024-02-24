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
