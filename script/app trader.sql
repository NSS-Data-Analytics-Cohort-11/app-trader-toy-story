-- app store table
Select * 
FROM public.app_store_apps

-- play store table
SELECT *
FROM public.play_store_apps

-- top 30 app store
SELECT name, review_count
FROM public.app_store_apps
Limit 30

-- top 30 play store
SELECT 