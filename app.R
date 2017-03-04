library(shiny)
library(RODBC)

# Copied from https://github.com/szilard/shinyvalidinp/blob/master/R/shinyvalidinp.R
validinp_character <- function(x, pattern="^[[:alnum:]. _-]*$", many=FALSE) {
        if(many && is.null(x)) return(character(0))  ## hack for checkboxGroupInput
        if(!( is.character(x) && (many || length(x)==1) && 
              all(!is.na(x)) && all(grepl(pattern,x)) )) {
                stop("Illegal characters in the user name")
        }
        x
}

# Define UI for application that draws a histogram
ui <- fluidPage(
        
        # Application title
        titlePanel("Golos - check current post bandwidth"),
        
        # Sidebar with a slider input for number of bins 
        verticalLayout(
                textInput("name",
                          "User name:",
                          width = '200px'),
                actionButton("goButton", "Go!"),
        # TODO make submit on Enter https://github.com/daattali/advanced-shiny/blob/master/proxy-click/app.R
                textOutput("message"),
                HTML("<br /><br />This app is developed by <a href=http://golos.io/@oxygendependant>@oxygendependant</A> and is using GolosSQL server, thanks to <a href=http://golos.io/@arcange>@arcange</a>.
                     <br /><a href=https://github.com/oxyen/golos-post-bandwidth>Source code at github</A>")
        )
)


# Define server logic required to draw a histogram
server <- function(input, output) {
        output$message<-renderText({
                name<-validinp_character(input$name)
                if (input$goButton == 0)
                        return()
                msg<-isolate({
                        dbhandle <- odbcDriverConnect('driver={SQL Server};server=sql.golos.cloud;UID=golos;PWD=golos')
                        # TODO Need a check if the username exists at all (and there wasn't a typo)
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
                        
                        msg<-paste0("Currently consumed bandwidth is ",
                                    bandw,
                                    " (be sure that GolosSQL has catched up on the latest ones - it knows of ",
                                    in30min,
                                    " posts from the last 30 minutes).",
                                    if(extra.bandw > 0) {
                                            remaining_time_min <-  (acceptable.age - passed) / 60
                                            penalty <- round(100 * (1 - (40000 / (bandw + 10000)) ^ 2))
                                            paste0(" Remaining time is ",
                                                   remaining_time_min%/%60,
                                                   " hours ",
                                                   round(remaining_time_min%%60),
                                                   " minutes. If you were to post right now, penalty would be ",
                                                   penalty,
                                                   "%.")
                                    }
                                    else
                                            ". It's ok to post now."
                        )
                        odbcClose(dbhandle)
                        return(msg)
                })
        })
}
# Run the application 
shinyApp(ui = ui, server = server)

# For debug
# sqlQuery(dbhandle, 'SELECT top 1 url FROM Comments WHERE reward_weight < 10000 ORDER BY Created DESC')
