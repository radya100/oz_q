/*Смущает , что суммирую в обоих подзапросах поле supermarket - это странно, судя по названию колонки - это категория продающаяся оффлайн ? Если да - ее нельзя суммировать - рассчитывать отдельно. Это как отдельная категория. Так-же формула расчета логистического коста странная - как будто не хватает скобок */
select
	a1.month
	, a1.macroBU
	, a1.cat1
	, (a2.ffcost * a1.itdr + a2.logcost) * (a1.gmvdr/gmvdr_total) as log_cost
from
(
	with
	(
		select
			sum(gmvdr) as gmvdr_total
		from
		(
        		select
                		argMax(gmvdr, parseDateTimeBestEffortOrZero(time_load)) as gmvdr
		        from file('calc3_mp.csv', CSV, 'month String, macroBU String, cat1 String, cat2 String, supermarket UInt8, version String, itdr Int64, gmvdr Int64, time_load String')
        		group by month, macroBU, cat1, cat2, supermarket, version
		)
	) as gmvdr_total
	select
		month
		, macroBU
		, cat1
		, sum(itdr) as itdr
		, sum(gmvdr) as gmvdr
		, gmvdr_total
	from
	(
		select
			month
			, macroBU
			, cat1
			, argMax(itdr, parseDateTimeBestEffortOrZero(time_load)) as itdr
			, argMax(gmvdr, parseDateTimeBestEffortOrZero(time_load)) as gmvdr
		from file('calc3_mp.csv', CSV, 'month String, macroBU String, cat1 String, cat2 String, supermarket UInt8, version String, itdr Int64, gmvdr Int64, time_load String')
		group by month, macroBU, cat1, cat2, supermarket, version
	)
	group by month, macroBU, cat1
) as a1
left semi join
(
	select
		month
		, macroBU
		, cat1
		, sum(ffcost) as ffcost
		, sum(logcost) as logcost
	from file('tariffs.csv', CSV, 'month String, macroBU String, cat1 String, supermarket UInt8, version String, ffcost Int64, logcost Int64')
	group by month, macroBU, cat1
) as a2 on a2.month = a1.month and a2.macroBU = a1.macroBU and a2.cat1 = a1.cat1
order by log_cost desc
limit 10
format Pretty;
