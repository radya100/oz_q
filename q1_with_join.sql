select
	q1.macroBU
	, q1.cat1
	, q1.month
	, (q1.gmvdr/q2.gmvdr) - 1 as inc_periods_to_date
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
) as q1
left semi join
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
) as q2 on q2.macroBU = q1.macroBU and q2.cat1 = q1.cat1 and (q2.month + interval 1 year) = q1.month 
format Pretty;
