
CREATE TABLE shipping_agreement
(
  agreementid          BIGINT        NOT NULL,
  agreement_number     VARCHAR(30)  ,
  agreement_rate       NUMERIC(14,4),
  agreement_commission NUMERIC(14,4),
  PRIMARY KEY (agreementid)
);

CREATE TABLE shipping_country_rates
(
  id                         serial        NOT NULL,
  shipping_country           VARCHAR(30)   UNIQUE,
  shipping_country_base_rate NUMERIC(14,4),
  PRIMARY KEY (id)
);

CREATE TABLE shipping_info
(
  shippingid             bigint        NOT NULL,
  vendor_id              BIGINT        NOT NULL,
  payment_amount         NUMERIC(14,4),
  shipping_plan_datetime timestamp    ,
  transfer_type_id       serial        NOT NULL,
  shipping_country_id    serial        NOT NULL,
  agreementid            BIGINT        NOT NULL,
  PRIMARY KEY (shippingid)
);

CREATE TABLE shipping_status
(
  shippingid                   bigint      NOT NULL,
  status                       VARCHAR(30),
  state                        VARCHAR(30),
  shipping_start_fact_datetime timestamp  ,
  shipping_end_fact_datetime   timestamp  ,
  PRIMARY KEY (shippingid)
);

CREATE TABLE shipping_transfer
(
  id                     serial        NOT NULL,
  transfer_type          VARCHAR(30)  ,
  transfer_model         VARCHAR(30)  ,
  shipping_transfer_rate NUMERIC(14,4),
  PRIMARY KEY (id)
);

ALTER TABLE shipping_info
  ADD CONSTRAINT FK_shipping_agreement_TO_shipping_info
    FOREIGN KEY (agreementid)
    REFERENCES shipping_agreement (agreementid);

ALTER TABLE shipping_info
  ADD CONSTRAINT FK_shipping_transfer_TO_shipping_info
    FOREIGN KEY (transfer_type_id)
    REFERENCES shipping_transfer (id);

ALTER TABLE shipping_info
  ADD CONSTRAINT FK_shipping_country_rates_TO_shipping_info
    FOREIGN KEY (shipping_country_id)
    REFERENCES shipping_country_rates (id);
