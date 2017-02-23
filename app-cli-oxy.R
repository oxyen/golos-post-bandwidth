library(RODBC)
name='oxygendependant'
dbhandle <- odbcDriverConnect('driver={SQL Server};server=sql.golos.cloud;UID=golos;PWD=golos')
# TODO Need a check if the username exists at all (and there wasn't a typo)
last.created <- sqlQuery(dbhandle, 
                         paste0('SELECT Top 1 created FROM Comments WHERE depth=0
                                AND author=\'', name, '\'
                                ORDER BY Created DESC'))[[1]]
last.created <- sqlQuery(dbhandle, 
                         paste0('SELECT Top 1 created FROM Comments WHERE depth=0
                                AND author=\'', name, '\'
                                ORDER BY Created DESC'))[[1]]
in30min <- sqlQuery(dbhandle, 
                    paste0('SELECT COUNT(*) FROM Comments WHERE depth=0
                           AND author=\'', name, '\'
                           AND created >= DateAdd(mi, -30, GETUTCDATE())'))[[1]]
last.bandw <- sqlQuery(dbhandle, 
                       paste0('SELECT Top 1 post_bandwidth FROM Accounts
                              WHERE name=\'', name, '\''))[[1]]

orig.time <- Sys.time()
gmttime <- function(x) as.character(as.POSIXlt(x, tz="GMT"))
curtime <- gmttime(orig.time)
passed <- as.integer(difftime(curtime, last.created, units="secs"))
bandw <- round(last.bandw * (1 - min(passed, 86400) / 86400))

acceptable.age <- round(86400 - 2592000000 / max(last.bandw, 30000))
# 2592000000 = 30k * (60 * 60 * 24)

extra.bandw <- max(bandw - 30000, 0)

cat("Currently consumed bandwidth is",
            bandw,
            "(be sure that GolosSQL has catched up on the latest ones - it knows of",
            in30min,
            "posts from the last 30 minutes).",
            if(extra.bandw > 0) {
                    remaining_time_min <-  (acceptable.age - passed) / 60
                    penalty <- round(100 * (1 - (40000 / (bandw + 10000)) ^ 2))
                    paste0("Remaining time is ",
                           remaining_time_min%/%60,
                           " hours ",
                           round(remaining_time_min%%60),
                           " minutes. If you were to post right now, penalty would be ",
                           penalty,
                           "%.")
            }
            else
                    "It's ok to post now."
)
odbcClose(dbhandle)

