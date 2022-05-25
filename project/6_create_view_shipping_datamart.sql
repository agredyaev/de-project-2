create or replace view shipping_datamart as
select
	si.shippingid,
	si.vendor_id,
	st.transfer_type,
	date_part('day', age(ss.shipping_end_fact_datetime, ss.shipping_start_fact_datetime)) as full_day_at_shipping,
	case
		when date_part('day', age(ss.shipping_end_fact_datetime, si.shipping_plan_datetime)) > 0 then 1
		else 0
	end is_delay,
	case
		when ss.status = 'finished' then 1
		else 0
	end is_shipping_finish,
		case
		when date_part('day', age(ss.shipping_end_fact_datetime, si.shipping_plan_datetime)) > 0 
			then date_part('day', age(ss.shipping_end_fact_datetime, si.shipping_plan_datetime))
		else 0
	end delay_day_at_shipping,
	si.payment_amount,
	si.payment_amount * (sa.agreement_rate + scr.shipping_country_base_rate + st.shipping_transfer_rate) vat,
	si.payment_amount * sa.agreement_commission profit
from
	shipping_info si
left join shipping_transfer st on
	st.id = si.transfer_type_id
left join shipping_status ss on
	ss.shippingid = si.shippingid
left join shipping_country_rates scr on
	scr.id = si.shipping_country_id
left join shipping_agreement sa on
	sa.agreementid = si.agreementid
