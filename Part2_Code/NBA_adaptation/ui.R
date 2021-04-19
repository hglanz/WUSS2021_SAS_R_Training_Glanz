#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(haven)
library(ggvis)

nba <- read_sas("clean_nba3.sas7bdat") 


# For dropdown menu
actionLink <- function(inputId, ...) {
    tags$a(href='javascript:void',
           id=inputId,
           class='action-button',
           ...)
}

fluidPage(
    titlePanel("Movie explorer"),
    fluidRow(
        column(3,
               wellPanel(
                   h4("Filter"),
                   sliderInput("seasons", "Minimum number of seasons in the league",
                               min(nba$Seasons_in_league), max(nba$Seasons_in_league), 1, step = 1),
                   sliderInput("season_short", "Award Season", min(nba$Season_short), max(nba$Season_short), value = c(min(nba$Season_short), max(nba$Season_short)),
                               sep = ""),
                   sliderInput("timeswon", "Minimum number of awards won",
                               min(nba$timesWon), max(nba$timesWon), 1, step = 1),
                   textInput("player", "Player name contains (e.g., Iverson)"),
                   textInput("team", "Team name contains (e.g. Bulls)")
               ),
               wellPanel(
                   selectInput("xvar", "X-axis variable", c("heightIn", "weightlb", "timesWon", "Age", "Seasons_in_league"), selected = "heightIn"),
                   selectInput("yvar", "Y-axis variable", c("heightIn", "weightlb", "timesWon", "Age", "Seasons_in_league"), selected = "timesWon")
               )
        ),
        column(9,
               ggvisOutput("plot1"),
               wellPanel(
                   span("Number of players selected:",
                        textOutput("n_players")
                   )
               )
        )
    )
)
