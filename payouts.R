library(RODBC)
library(ggplot2)

dbhandle <- odbcDriverConnect('driver={SQL Server};server=sql.golos.cloud;UID=golos;PWD=golos;CharSet=utf8')
repu<-function(x) {round((log10(x)-9)*9+25,digits=1)}

#a <- sqlQuery(dbhandle, 'SELECT Created, net_votes, children, author_reputation, total_payout_value, total_pending_payout_value  FROM Comments as c WHERE c.depth=0 AND c.Created BETWEEN \'2017-2-18\' AND \'2017-2-19\' AND c.net_votes > 0 ORDER BY c.ID DESC')
a <- sqlQuery(dbhandle, 'SELECT c.Created, c.net_votes, c.children, c.author_reputation, c.total_payout_value, c.total_pending_payout_value, (select count(*) from txCustomsFollows as f where f.what=\'["blog"]\' and f.timestamp < c.Created AND c.author=f.following) as foll FROM Comments as c WHERE c.depth=0 AND c.Created BETWEEN \'2017-2-18\' AND \'2017-2-19\' AND c.net_votes > 0 ORDER BY c.ID DESC')


a1<-a[a$author_reputation>0,]

a1<-a1[a1$foll>0,]

a1$earned<-a1$total_payout_value + a1$total_pending_payout_value

a1$repu<-sapply(a1$author_reputation,repu)

a1$pervote <- a1$earned / a1$net_votes
a1$voteper100f <- 100 * a1$net_votes / a1$foll

# How much payout depends on GBG/Golos rate?

# with(a1, lm(earned ~ net_votes))

#ggplot(a1, aes (net_votes, earned)) + geom_point() + stat_smooth(method="lm")
#ggplot(a1, aes (repu, earned)) + geom_point() + stat_smooth(method="lm")

#with(a1, lm(earned ~ net_votes + foll + repu + pervote + voteper100f))
l<-with(a1, lm(earned ~ foll + 0))
l
summary(l)
ggplot(a1, aes (foll, earned)) + geom_point() + stat_smooth(method="lm")
