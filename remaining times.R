library(RODBC)
dbhandle <- odbcDriverConnect('driver={SQL Server};server=sql.golos.cloud;UID=golos;PWD=golos;CharSet=utf8')
last24 <- sqlQuery(dbhandle, 
                   'SELECT created FROM Comments WHERE depth=0
                AND author=\'avtor8904\'
                AND created >= DateAdd(hh, -24, GETUTCDATE())
                  ORDER BY ID DESC')
posts_count <- nrow(last24)
current_post_bandwidth <- ifelse(posts_count>0,
                                 {
                                         curtime <- as.character(as.POSIXlt(Sys.time(), tz="GMT"))
                                         sum(
                                                 sapply(last24$created, 
                                                        function(x) 
                                                        {10000 * (24 - difftime(curtime, x, units="hours")) / 24}
                                                 )
                                         )
                                 }, 0
                                 )
extra_bandwidth <- max(current_post_bandwidth - 30000, 0)
as.character(as.POSIXlt(Sys.time(), tz="GMT"))
cat("Currently consumed bandwidth is ",
    round(current_post_bandwidth),
    if(extra_bandwidth > 0) {
            remaining_time <-  extra_bandwidth / 
                    (posts_count * 10000 / (24 * 60))
            penalty <- round(100 * (1 - (40000 / (current_post_bandwidth + 10000)) ^ 2))
            paste0(", remaining time is ",
                   remaining_time%/%60,
                   " hours ",
                   round(remaining_time%%60),
                   " minutes. If you post now, penalty would be ",
                   penalty,
                   "%.")
    }
    else
            paste0(". It's ok to post now."),
    sep = "")
odbcClose(dbhandle)
