library(RODBC)
library(ggplot2)

dbhandle <- odbcDriverConnect('driver={SQL Server};server=sql.golos.cloud;UID=golos;PWD=golos;CharSet=utf8')
repu<-function(x) {round((log10(x)-9)*9+25,digits=1)}

a <- sqlQuery(dbhandle, 'SELECT comm.Created, comm.net_votes, comm.children, comm.author, comm.author_reputation, (select count(*) from txCustomsFollows as fol where fol.what=\'["blog"]\' and fol.timestamp < comm.Created AND comm.author=fol.following) as foll FROM Comments as comm WHERE comm.depth=0 AND comm.Created BETWEEN \'2017-2-18\' AND \'2017-2-19\' AND comm.net_votes > 0 ORDER BY comm.ID DESC')

a1<-a[a$author_reputation>0,]

a1$repu<-sapply(a1$author_reputation,repu)

a1$repu<-sapply(a1$author_reputation,function(x){repu(x)-34})

with(a1, lm(net_votes ~ foll + repu))

ggplot(a1, aes (foll, net_votes)) + geom_point() + stat_smooth(method="lm")

with(a1, lm(net_votes ~ I((repu-8)^2)))

