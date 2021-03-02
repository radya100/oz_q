# Ответы:
1) Скопировать файлы в директорию на mac(склонировать репозиторий)
2) Перейти в папку, содержащую файлы
3) Склонировать пакет для нестандартных окружений (https://clickhouse.tech/docs/ru/getting-started/install/#from-binaries-non-linux)
	curl -O 'https://builds.clickhouse.tech/master/macos/clickhouse' && chmod a+x ./clickhouse
4) убедиться что пакет clickhouse находится в одной директории с *.sql файлами
5) запустить любой скрипт на выполнение :
	$ ./clickhouse local --query "$(cat q2.sql)"  
