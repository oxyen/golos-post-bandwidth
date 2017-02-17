library(RODBC)
library(dplyr)
dbhandle <- odbcDriverConnect('driver={SQL Server};server=sql.golos.cloud;UID=golos;PWD=golos;CharSet=utf8')
#sqlQuery(dbhandle, 'select * from information_schema.tables')

# Posts in February with at least one vote
p.w.c <- sqlQuery(dbhandle, 'SELECT Created, url, total_vote_weight, category, net_votes, children, total_payout_value, total_pending_payout_value, author FROM Comments WHERE depth=0 AND Created > \'2017-2-1\' AND net_votes > 0 ORDER BY ID DESC')
p.w.c$cpervote <- p.w.c$children/p.w.c$net_votes
p.w.c$cpervote %>% summary
sorted <- p.w.c[order(-p.w.c$cpervote), ]
# Top 10 discussed not liked
sorted$url[1:10]

# Top 10 liked not discussed
sorted <- p.w.c[order(p.w.c$cpervote, -p.w.c$net_votes), ]
# Remove statistics
sorted <- sorted[sorted$category != 'ru--statistika',]
sorted <- sorted[sorted$category != 'ru--reijting',]
sorted$url[1:10]

odbcClose(dbhandle)