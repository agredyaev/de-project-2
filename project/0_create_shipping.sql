

DROP TABLE IF EXISTS public.shipping_old;



--shipping
CREATE TABLE public.shipping_old (
   ID serial ,
   shippingid                         BIGINT,
   saleid                             BIGINT,
   orderid                            BIGINT,
   clientid                           BIGINT,
   payment_amount                          NUMERIC(14,2),
   state_datetime                    TIMESTAMP,
   productid                          BIGINT,
   description                       text,
   vendorid                           BIGINT,
   namecategory                      text,
   base_country                      text,
   status                            text,
   state                             text,
   shipping_plan_datetime            TIMESTAMP,
   hours_to_plan_shipping           NUMERIC(14,2),
   shipping_transfer_description     text,
   shipping_transfer_rate           NUMERIC(14,3),
   shipping_country                  text,
   shipping_country_base_rate       NUMERIC(14,3),
   vendor_agreement_description      text,
   PRIMARY KEY (ID)
);
CREATE INDEX shippingid ON public.shipping (shippingid);
CREATE INDEX shipping_old_state_datetime_idx ON public.shipping_old (state_datetime,state);
COMMENT ON COLUMN public.shipping.shippingid is 'id of shipping of sale';


-- COPY public.shipping_old FROM '/lessons/shipping.csv' WITH DELIMITER ',' CSV HEADER;
