insert into
	shipping_country_rates (shipping_country, shipping_country_base_rate)
SELECT
	DISTINCT shipping_country,
	shipping_country_base_rate
FROM
	shipping_old so;