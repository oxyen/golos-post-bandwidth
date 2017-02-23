library(RODBC)
library(ggplot2)
library(lubridate)
dbhandle <- odbcDriverConnect('driver={SQL Server};server=sql.golos.cloud;UID=golos;PWD=golos;CharSet=utf8')
repu<-function(x) {round((log10(x)-9)*9+25,digits=1)}

#a <- sqlQuery(dbhandle, 'SELECT Created, net_votes, children, author_reputation, total_payout_value, total_pending_payout_value  FROM Comments as c WHERE c.depth=0 AND c.Created BETWEEN \'2017-2-18\' AND \'2017-2-19\' AND c.net_votes > 0 ORDER BY c.ID DESC')
#a <- sqlQuery(dbhandle, 'SELECT cast(replace(c.vesting_shares,\' GESTS\',\'\') AS decimal) as shares, c.Created, c.net_votes, c.children, c.author_reputation, c.total_payout_value, c.total_pending_payout_value, (select count(*) from txCustomsFollows as f where f.what=\'["blog"]\' and f.timestamp < c.Created AND c.author=f.following) as foll FROM Comments as c WHERE c.depth=0 AND c.Created BETWEEN \'2017-2-18\' AND \'2017-2-19\' AND c.net_votes > 0 ORDER BY c.ID DESC')
whales <- sqlQuery(dbhandle, 'SELECT Top 100 name FROM Accounts order by cast(replace(vesting_shares,\' GESTS\',\'\') AS decimal) DESC') 
whales <- unlist(whales)
posts.src <- sqlQuery(dbhandle, 'SELECT Created, net_votes, children, author_reputation, url, depth, permlink, total_payout_value, total_pending_payout_value, author FROM Comments WHERE depth=0')
posts<-posts.src
posts$date <-date(posts$Created)
posts <- posts[posts$date > '2017-1-15' & posts$date < max(posts$date),]
posts$earned<-posts$total_payout_value + posts$total_pending_payout_value


posts$whaled <- sapply(posts$author, function(x) x %in% whales)
share.of.whales <- tapply(posts$whaled, posts$date, sum)/tapply(posts$whaled, posts$date, length)
q<-data.frame(date=date(names(share.of.whales)), shares=share.of.whales)
medians <- tapply(posts$earned,posts$date, median)
plot(q)
plot(q$date,medians)


# Earned in GBG depends on currency rate

posts<-data.table(posts)
posts[, Daily := sum(earned), by = date]
posts$earnedshare <- posts$earned/posts$Daily
qq<-tapply(posts$earnedshare,posts$date, mean)
qplot(names(qq),qq)
qplot(q$shares,qq)

# The more whales post, the higher mean and median share of daily earnings per post


a <- sqlQuery(dbhandle, 'SELECT a.vesting_shares, a.balance, c.Created, c.net_votes, c.children, c.author_reputation, c.total_payout_value, c.total_pending_payout_value, (select count(*) from txCustomsFollows as f where f.what=\'["blog"]\' and f.timestamp < c.Created AND c.author=f.following) as foll FROM Comments as c JOIN Accounts a on c.author=a.name WHERE c.depth=0 AND c.Created BETWEEN \'2017-2-18\' AND \'2017-2-19\' AND c.net_votes > 0 ORDER BY c.ID DESC')


a1<-a[a$author_reputation>0,]

a1<-a1[a1$foll>0,]

a1$earned<-a1$total_payout_value + a1$total_pending_payout_value

a1$repu<-sapply(a1$author_reputation,repu)

a1$pervote <- a1$earned / a1$net_votes
a1$voteper100f <- 100 * a1$net_votes / a1$foll

a1$shares<-sapply(a1$vesting_shares, function(x){strsplit(as.character(x)," ", fixed=TRUE)[[1]][1]})
a1$shares<-as.numeric(a1$shares)
summary(with(a1, lm(earned ~ foll + shares)))

# How much payout depends on GBG/Golos rate?

# with(a1, lm(earned ~ net_votes))

#ggplot(a1, aes (net_votes, earned)) + geom_point() + stat_smooth(method="lm")
#ggplot(a1, aes (repu, earned)) + geom_point() + stat_smooth(method="lm")

#with(a1, lm(earned ~ net_votes + foll + repu + pervote + voteper100f))
l<-with(a1, lm(earned ~ foll + 0))
l
summary(l)
ggplot(a1, aes (shares, earned)) + geom_point() + stat_smooth(method="lm")
