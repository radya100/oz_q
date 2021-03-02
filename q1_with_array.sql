select 
	macroBU
	, cat1
	, toYYYYMM((arraySort(z -> g.1, g) as arr)[2].1) as month
	, (arr[2].2/arr[1].2) - 1 as inc_periods_to_date
from 
(
	select
		macroBU
		, cat1
		, arrayMap
		(
			x -> arrayFilter(y -> y.1 = arr[x].1 or y.1 = arr[x].1 - interval 1 year, arr)
			, arrayEnumerate((groupArray(tuple(month, gmvdr)) as arr))
		) as g
	from
	(
		select
			toDate(parseDateTimeBestEffort(month)) as month
			, macroBU
			, cat1
			, sum(gmvdr) as gmvdr
		from
		(
			select
				month
				, macroBU
				, cat1
				, argMax(gmvdr, parseDateTimeBestEffortOrZero(time_load)) as gmvdr
			from file('calc3_mp.csv', CSV, 'month String, macroBU String, cat1 String, cat2 String, supermarket UInt8, version String, itdr Int64, gmvdr Int64, time_load String')
			group by month, macroBU, cat1, cat2, supermarket, version
		)
		group by month, macroBU, cat1
		order by macroBU, cat1, month
	)
group by macroBU, cat1) 
array join g 
where length(g) > 1
format Pretty;
