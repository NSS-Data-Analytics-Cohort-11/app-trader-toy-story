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
UNION ALL
SELECT 'Play Store', name, CAST(price as MONEY), content_rating, CAST(review_count as int), genres
FROM play_store_apps

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
	
--1000 as monthly_mktg_spend,

	--(COUNT(DISTINCT both_stores.store))*5000 as monthly_income
 		CASE WHEN app_price  > 1.00
 		THEN (app_price*10000
		ELSE 10000 END) AS purchase_price
FROM both_stores 
	 	--app_store_apps, 
	 	--play_store_apps
GROUP BY app_name --, app_price

	purchase_price/(monthly_income-monthly_mktg_spend)/12 AS years_until_profit
	CASE WHEN years_until_profit < projected_life_span 
		THEN 'Y'
		ELSE 'N' 
	END AS will_investment_recoup
	Purchase Price*-1 + monthly_income*12 - monthly_mktg_spend*12 as one_year_balance
	CASE WHEN 
		projected_life_span >= 5 
		THEN purchase_price*-1 + Monthly Income*12*5 + monthly_mktg_spend*12*5
		ELSE 'Not Applicable' 
	END AS year_five_investment_balance
	Purchase Price*-1 + monthly_income*12*projected_life_span - monthly_mktg_spend*12*projected_life_span as lifetime_investment_balance
	FORMAT((lifetime_investment_balance/purchase_price),'P3') as return_on_investment




