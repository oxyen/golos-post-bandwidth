library(RODBC)
dbhandle <- odbcDriverConnect('driver={SQL Server};server=sql.golos.cloud;UID=golos;PWD=golos')
#z<-sqlQuery(dbhandle, 'select top 20 following, count(*) from txCustomsFollows where what=\'["blog"]\' and timestamp BETWEEN \'2017-02-10\' AND \'2017-02-17\' AND following not in (select top 100 following from txCustomsFollows where what=\'["blog"]\' and timestamp < \'2017-02-10\' group by following order by count(*) desc) group by following order by count(*) desc')
start <- "2017-03-05"
end <- "2017-03-20"
z<-sqlQuery(dbhandle, paste0(
 'SELECT TOP 30 following, COUNT(*) FROM txCustomsFollows WHERE what=\'[\"blog\"]\' AND timestamp BETWEEN \'',
 start, '\' AND \'', end, '\' AND following NOT IN (SELECT TOP 100 following FROM txCustomsFollows WHERE what=\'[\"blog\"]\' ',
 'AND following NOT LIKE \'bm-%\' ', 
 'AND timestamp < \'',
 start, '\' GROUP BY following ORDER BY COUNT(*) DESC) ',
 'AND following NOT LIKE \'bm-%\' ',
 'GROUP BY following ORDER BY COUNT(*) DESC'))
print(z)
odbcClose(dbhandle)

cat("|Место|Автор|Число новых подписчиков|\n|-------|-----|-----|\n")
for(i in 1:nrow(z))
{ cat(paste0('|', i, '|@', z[i,1], '|', z[i,2], '|\n'))
  cat('|| ||\n')}
