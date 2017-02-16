library(RODBC)
dbhandle <- odbcDriverConnect('driver={SQL Server};server=sql.golos.cloud;UID=golos;PWD=golos;CharSet=utf8')
w <- sqlQuery(dbhandle, 
              'SELECT TOP 10 author, COUNT(*)
                        FROM Comments
                        WHERE depth=0
                   AND created >= DateAdd(hh, -24, GETDATE())
                   GROUP BY author
                   ORDER BY COUNT(*) DESC')
w
odbcClose(dbhandle)