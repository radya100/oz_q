select
	a1.month
	, a1.macroBU
	, cat1
	, cat2
	, supermarket
	, version
	, gmvdr * k as gmvdr_new
from
(
	select
		month
		, macroBU
		, cat1
		, cat2
		, supermarket
		, version    
		, argMax(gmvdr, parseDateTimeBestEffortOrZero(time_load)) as gmvdr
	from file('calc3_mp.csv', CSV, 'month String, macroBU String, cat1 String, cat2 String, supermarket UInt8, version String, itdr Int64, gmvdr Int64, time_load String')
	where macroBU = 'FMCG'
		and month in ('202101', '202102')
	group by month, macroBU, cat1, cat2, supermarket, version
) as a1
all inner join
(
	select
		month
		, (month = '202101' ? toInt64(100000) : toInt64(13500)) / sum(gmvdr) as k
	from 
	(
		select
			month
			, argMax(gmvdr, parseDateTimeBestEffortOrZero(time_load)) as gmvdr
		from file('calc3_mp.csv', CSV, 'month String, macroBU String, cat1 String, cat2 String, supermarket UInt8, version String, itdr Int64, gmvdr Int64, time_load String')
		where macroBU = 'FMCG'
			and month in ('202101', '202102') 
		group by month, macroBU, cat1, cat2, supermarket, version
	)
	group by month
) as a2 using (month)
format Pretty;
