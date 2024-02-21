--Initial Exploratory Queries

select * from app_store_apps limit 10
select * from play_store_apps limit 10

SELECT DISTINCT primary_genre
FROM app_store_apps

SELECT DISTINCT genres
FROM play_store_apps

--BASE UNION QUERY
SELECT 'App Store' as store, name, CAST(price as MONEY), content_rating, CAST(review_count as int), primary_genre
FROM app_store_apps
UNION
SELECT 'Play Store', name, CAST(price as MONEY), content_rating, CAST(review_count as int), genres
FROM play_store_apps

--SUB IT!

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
UNION
SELECT 
	 name, 
	'Play Store' as store,
	CAST(price as MONEY), 
	content_rating, 
	rating, 
	CAST(review_count as int), 
	genres
FROM play_store_apps)
 
SELECT name, primary_genre, COUNT(store) as number_of_stores, MAX(price), ROUND(AVG(rating),1)
FROM both_stores
-- --WHERE content_rating IS NOT NULL
GROUP BY name, primary_genre
-- --HAVING COUNT(store) = 2
