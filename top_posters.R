library(RODBC)
dbhandle <- odbcDriverConnect('driver={SQL Server};server=sql.golos.cloud;UID=golos;PWD=golos;CharSet=utf8')
cat("Most posts in 24 hours:\n")
w<-sqlQuery(dbhandle, 
              'SELECT TOP 20 author, COUNT(*)
                        FROM Comments
                        WHERE depth=0
                   AND created >= DateAdd(hh, -24, GETUTCDATE())
                   GROUP BY author
                   ORDER BY COUNT(*) DESC')
print(w)
cat("Penalized most times in last 10 days:\n")
w<-sqlQuery(dbhandle, 'select author, count(*) from Comments where reward_weight<10000 and created >= DateAdd(hh, -24, GETUTCDATE()) group by author order by count(*) desc')
print(w)
odbcClose(dbhandle)