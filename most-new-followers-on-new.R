library(RODBC)
dbhandle <- odbcDriverConnect('driver={SQL Server};server=sql.golos.cloud;UID=golos;PWD=golos')
sqlQuery(dbhandle, 'select top 20 following, count(*) from txCustomsFollows where what=\'["blog"]\' and timestamp BETWEEN \'2017-02-10\' AND \'2017-02-17\' AND following not in (select top 100 following from txCustomsFollows where what=\'["blog"]\' and timestamp < \'2017-02-10\' group by following order by count(*) desc) group by following order by count(*) desc')
odbcClose(dbhandle)
