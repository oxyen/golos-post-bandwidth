library(RODBC)
library(ggplot2)
library(lubridate)

dbhandle <- odbcDriverConnect('driver={SQL Server};server=sql.golos.cloud;UID=golos;PWD=golos')
posts.src <- sqlQuery(dbhandle, 'SELECT Created, net_votes, children, author_reputation, url, depth, permlink, total_payout_value, total_pending_payout_value, author FROM Comments WHERE depth=0')
posts<-posts.src
posts$date <-date(posts$Created)
posts <- posts[posts$date > '2017-1-15' & posts$date < max(posts$date),]

posts$earned<-posts$total_payout_value + posts$total_pending_payout_value
sums <- tapply(posts$earned, posts$date, sum)
counts <- tapply(posts$earned, posts$date, length)

# Find how delayed reaction is
for(i in 1:12) print(summary(lm(counts[(1+i):length(counts)] ~ sums[1:(length(sums)-i)]))$r.squared)

# 9 days
i <- 9
#posts.per.earn <- (counts[(1+i):length(counts)]-270)/sums[1:(length(sums)-i)]
#plot(posts.per.earn[9:length(posts.per.earn)])

ggplot(data=
         data.frame(e9=0.04*sums[1:(length(sums)-i)], 
                            cc=counts[(1+i):length(counts)], 
                            dates=names(sums)[(1+i):length(counts)]),
       aes(e9, cc)) +
  geom_smooth(method="lm") +
  geom_point() +
  xlab("Суммарная выплата 9 днями ранее, $US") +
  ylab("Число постов")
