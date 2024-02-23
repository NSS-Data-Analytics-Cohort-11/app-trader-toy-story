------------------app store table
Select * 
FROM public.app_store_apps
ORDER BY rating DESC
LIMIT 100

----------------- play store table
SELECT *
FROM public.play_store_apps
ORDER BY rating DESC
LIMIT 100

----------------- top 30 app store
SELECT name, review_count
FROM public.app_store_apps
Limit 30

 
 
 ----------------Name and price of both
SELECT name, app_store_apps.price :: MONEY AS app_store_price, play_store_apps.price :: MONEY AS play_store_price
FROM app_store_apps
INNER JOIN play_store_apps
USING (name)
WHERE app_store_apps.name = play_store_apps.name
	AND app_store_apps.price :: MONEY <> play_store_apps.price :: MONEY;


------------------------------------------
SELECT name, price :: MONEY, rating
FROM app_store_apps
INTERSECT
SELECT name, price :: MONEY, rating
FROM play_store_apps
ORDER BY rating DESC;





----------------------------------------

CREATE TABLE appt_trader 
name varchar (200)
rating int (200)




---------------------------------------
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
	 

	 
---------------------------------------------------------------
SELECT name, CONCAT(ROUND(price :: MONEY), rating
FROM app_store_apps
INTERSECT
SELECT name, ROUND (price :: MONEY), rating
FROM play_store_apps
ORDER BY rating DESC;
	 
----
			
	 
	 