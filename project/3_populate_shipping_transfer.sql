insert into shipping_transfer (transfer_type, transfer_model, shipping_transfer_rate)
WITH split AS 
    (SELECT shipping_transfer_rate,
         regexp_split_to_array(shipping_transfer_description,
         E'\\:+') AS arr
    FROM shipping_old )
SELECT DISTINCT arr[1] transfer_type,
         arr[2] transfer_model,
         shipping_transfer_rate
FROM split 