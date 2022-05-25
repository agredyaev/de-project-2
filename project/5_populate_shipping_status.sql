truncate
	table shipping_status;

drop table if exists last_state;

drop table if exists start_end_date;

create temp table last_state(shippingid bigint not null primary key,
max_state_datetime timestamp);

insert
	into
	last_state(shippingid,
	max_state_datetime)
select
	shippingid,
	max(state_datetime) max_state_datetime
from
	shipping_old so
group by
	shippingid;

create index inx_555
    on
last_state (shippingid,
max_state_datetime);

create temp table start_end_date(shippingid bigint not null primary key,
shipping_start_fact_datetime timestamp,
shipping_end_fact_datetime timestamp);

insert
	into
	start_end_date(shippingid,
	shipping_start_fact_datetime,
	shipping_end_fact_datetime)
select
	shippingid,
	max(state_datetime) filter (where state = 'booked') as shipping_start_fact_datetime,
	max(state_datetime) filter (where state = 'recieved') as shipping_end_fact_datetime
from
	shipping_old
group by
	shippingid;

create index inx_666
    on
start_end_date (shippingid);

insert
	into
	shipping_status (shippingid,
	status,
	state,
	shipping_start_fact_datetime,
	shipping_end_fact_datetime)
select
	so.shippingid,
	so.status,
	so.state,
	sed.shipping_start_fact_datetime,
	sed.shipping_end_fact_datetime
from
	shipping_old so
join last_state ls
    on
	ls.shippingid = so.shippingid
	and ls.max_state_datetime = so.state_datetime
left join start_end_date sed
    on
	sed.shippingid = so.shippingid