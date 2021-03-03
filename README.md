# Ответы:
1) Скопировать файлы в директорию на mac(склонировать репозиторий)
2) Перейти в папку, содержащую файлы
3) Склонировать пакет для нестандартных окружений (https://clickhouse.tech/docs/ru/getting-started/install/#from-binaries-non-linux)
	$ curl -O 'https://builds.clickhouse.tech/master/macos/clickhouse' && chmod a+x ./clickhouse
4) убедиться что пакет clickhouse находится в одной директории с *.sql файлами
5) запустить любой скрипт на выполнение :
	$ ./clickhouse local --query "$(cat q2.sql)" 

# Создание таблиц для реальных сценариев
Таблицы , созданные выше имеют движок file/ Неправильно его использовать в промышленной эксплуатации/
В пром эксплуатации правильно использовать таблицы семейства MergeTree
create table calc3_mp
(
	month UInt32
	, macroBU LowCardinality(String)
	, cat1 LowCardinality(String)
	, cat2 String
	, supermarket UInt8
	, version LowCardinality(String)
	, itdr Int64
	, gmvdr Int64
	, time_load DateTime
) Engine = MergeTree()
partition by month
order by time_load;

create materialized view mv_calc3_mp_last
Engine = AggregatingMergeTree() partition by month order by (month, macroBU, cat1, cat2, supermarket, version)
as select
	month
	, macroBU
	, cat1
	, cat2
	, supermarket
	, version
	, argMaxState(itdr, time_load) as itdr
	, argMaxState(gmvdr, time_load) as gmvdr
	, maxState(time_load) as last_time_load
from calc3_mp
group by month, macroBU, cat1, cat2, supermarket, version;

Это пример для одной ноды/ Для кластера из нескольких нод - с репликацией или шардированием правильнее использовать вставку в таблицы с null движком и МВ , перекладывающая данные из null таблицы в целевую реплицированную/шардированную/

Создание второй таблицы не отличается от создания таблицы с движком file - за исключением движка/ В текущей реализации - это перезаписываемая MergeTree таблица - в целевой - добавление метки времени загрузки данных по аналогии с таблицей calc3_mp - time_load - который я бы вычислял НЕ средствами  СН//
