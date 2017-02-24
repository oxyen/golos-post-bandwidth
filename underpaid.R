library(RODBC)
dbhandle <- odbcDriverConnect('driver={SQL Server};server=sql.golos.cloud;UID=golos;PWD=golos')
names<-sqlQuery(dbhandle, 'SELECT author, count(*) from COmments where reward_weight < 10000 AND Created > \'2017-2-16\' GROUP BY author ORDER BY COUNT(*) DESC')

cat("|Место|Автор|Число постов|\n|-------|-----|-----|\n")
for(i in 1:nrow(names))
{ cat(paste0('|',i,'|@',names[i,1],'|',names[i,2],'|\n'))}

for(i in 1:nrow(names))
{ cat(paste0('@', names[i,1], ', '))}

checked='narin'
sqlQuery(dbhandle, paste0('SELECT url, reward_weight from COmments where reward_weight < 10000 AND author=\'', checked, '\' ORDER BY Created DESC'))
