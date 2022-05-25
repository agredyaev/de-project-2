insert into shipping_info(shippingid, vendor_id, payment_amount, shipping_plan_datetime, shipping_country_id, agreementid, transfer_type_id)
WITH base AS 
    (SELECT shippingid,
         vendorid AS vendor_id,
         payment_amount,
         shipping_plan_datetime,
         shipping_country,
         regexp_split_to_array(shipping_transfer_description,
         E'\\:+') AS transfer, regexp_split_to_array(vendor_agreement_description, E'\\:+') AS agreement
    FROM shipping_old 
	)
SELECT DISTINCT shippingid,
         vendor_id,
         payment_amount,
         shipping_plan_datetime,
         scr.id AS shipping_country_id,
         agreement[1]::bigint agreementid,
         st.id transfer_type_id
FROM base b
JOIN shipping_country_rates scr
    ON scr.shipping_country=b.shipping_country
JOIN shipping_transfer st
    ON st.transfer_type=b.transfer[1]
        AND st.transfer_model=b.transfer[2] 