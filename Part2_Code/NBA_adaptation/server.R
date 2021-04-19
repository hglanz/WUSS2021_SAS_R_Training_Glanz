#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(haven)
library(ggvis)
library(dbplyr)
library(RSQLite)
library(DescTools)

nba <- read_sas("clean_nba3.sas7bdat") 


function(input, output, session) {
    
    # Filter the movies, returning a data frame
    revised_nba <- reactive({
        seasons <- input$seasons # was reviews
        timeswon <- input$timeswon # was oscars
        minyear <- input$season_short[1]
        maxyear <- input$season_short[2]
        
        # Apply filters
        m <- nba %>%
            filter(
                Seasons_in_league >= seasons,
                timesWon >= timeswon,
                Season_short >= minyear,
                Season_short <= maxyear
            ) %>%
            arrange(timesWon)
        
        # Optional: filter by director/player
        if (!is.null(input$player) && input$player != "") {
            player <- paste0("%", input$player, "%")
            m <- m %>% filter(Player %like% player)
        }
        # Optional: filter by cast member/team
        if (!is.null(input$team) && input$team != "") {
            team <- paste0("%", input$team, "%")
            m <- m %>% filter(Team %like% team)
        }
        
        
        m <- as.data.frame(m)
        
        m
    })
    
    # Function for generating tooltip text
    player_tooltip <- function(x) {
        if (is.null(x)) return(NULL)
        if (is.null(x$ID)) return(NULL)
        
        # Pick out the movie with this ID
        all_players <- isolate(revised_nba())
        player <- all_players[all_players$Player == x$Player, ]
        
        paste0("<b>", player$Player, "</b><br>",
               player$Season_short, "<br>",
               "$", format(player$Age, big.mark = ",", scientific = FALSE)
        )
    }
    
    # A reactive expression with the ggvis plot
    vis <- reactive({
        
        # Labels for axes
        xvar_name <- input$xvar
        yvar_name <- input$yvar
        
        # Normally we could do something like props(x = ~heightIn, y = ~weightlb),
        # but since the inputs are strings, we need to do a little more work.
        xvar <- prop("x", as.symbol(input$xvar))
        yvar <- prop("y", as.symbol(input$yvar))
        
        revised_nba %>%
            ggvis(x = xvar, y = yvar) %>%
            layer_points(size := 50, size.hover := 200,
                         fillOpacity := 0.2, fillOpacity.hover := 0.5,
                         key := ~Player) %>%
            add_tooltip(player_tooltip, "hover") %>%
            add_axis("x", title = xvar_name) %>%
            add_axis("y", title = yvar_name) %>%
            # add_legend("stroke", title = "Won Award", values = c("Yes", "No")) %>%
            # scale_nominal("stroke", domain = c("Yes", "No"),
            #               range = c("orange", "#aaa")) %>%
            set_options(width = 500, height = 500)
    })
    
    vis %>% bind_shiny("plot1")
    
    output$n_players <- renderText({ nrow(revised_nba()) })
}
