insert into
    shipping_agreement (
        agreementid,
        agreement_number,
        agreement_rate,
        agreement_commission
    ) WITH split AS (
        SELECT
            regexp_split_to_array(vendor_agreement_description, E'\\:+') AS arr
        FROM
            shipping_old
    )
SELECT
    DISTINCT arr[1]::bigint agreementid,
    arr[2] agreement_number,
    arr[3]::numeric agreement_rate,
    arr[4]::numeric agreement_commission
FROM
    split
ORDER BY
    agreementid