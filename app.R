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
                        dbhandle <- odbcDriverConnect('driver={SQL Server};server=sql.golos.cloud;UID=golos;PWD=golos;CharSet=utf8')
                        # TODO Need a check if the username exists at all (and there wasn't a typo)
                        last24 <- sqlQuery(dbhandle, 
                                           paste0('SELECT created FROM Comments WHERE depth=0
                           AND author=\'', name, '\'
                           AND created >= DateAdd(hh, -24, GETUTCDATE())
                           ORDER BY ID DESC'))
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
                        msg<-paste0("Currently consumed bandwidth is ",
                                        round(current_post_bandwidth),
                                        if(extra_bandwidth > 0) {
                                                remaining_time <-  extra_bandwidth / 
                                                        (posts_count * 10000 / (24 * 60))
                                                penalty <- round(100 * (1 - (40000 / (current_post_bandwidth + 10000)) ^ 2))
                                                paste0(", remaining time is ",
                                                       remaining_time%/%60,
                                                       " hours ",
                                                       round(remaining_time%%60),
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

