library(RODBC)
dbhandle <- odbcDriverConnect('driver={SQL Server};server=sql.golos.cloud;UID=golos;PWD=golos')
#z<-sqlQuery(dbhandle, 'select top 20 following, count(*) from txCustomsFollows where what=\'["blog"]\' and timestamp BETWEEN \'2017-02-10\' AND \'2017-02-17\' AND following not in (select top 100 following from txCustomsFollows where what=\'["blog"]\' and timestamp < \'2017-02-10\' group by following order by count(*) desc) group by following order by count(*) desc')
start <- "2017-02-17"
end <- "2017-02-24"
z<-sqlQuery(dbhandle, paste0(
 'SELECT top 20 following, count(*) from txCustomsFollows WHERE what=\'[\"blog\"]\' AND timestamp BETWEEN \'',
 start, '\' AND \'', end, '\' AND following NOT IN (SELECT TOP 100 following FROM txCustomsFollows WHERE what=\'[\"blog\"]\' AND timestamp < \'',
 start, '\' group by following order by count(*) desc) group by following order by count(*) desc'))
print(z)
odbcClose(dbhandle)

cat("|Место|Автор|Число новых подписчиков|\n|-------|-----|-----|\n")
for(i in 1:nrow(z))
{ cat(paste0('|', i, '|@', z[i,1], '|', z[i,2], '|\n'))}
