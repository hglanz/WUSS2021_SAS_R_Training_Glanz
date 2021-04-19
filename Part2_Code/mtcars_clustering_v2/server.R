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

function(input, output, session) {
    
    # Combine the selected variables into a new data frame
    selectedData <- reactive({
        mtcars[, c(input$xcol, input$ycol, "cyl")] %>%
            mutate(
                cyl = as.character(cyl)
            )
    })
    
    clusters <- reactive({
        kmeans(selectedData(), input$clusters)
    })
    
    output$plot1 <- renderPlot({
        palette(c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
                  "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999"))
        
        par(mar = c(5.1, 4.1, 0, 1))
        selectedData() %>%
            ggplot(aes_string(x = input$xcol, y = input$ycol, color = as.factor(clusters()$cluster), shape = "cyl")) +
            geom_point() +
            geom_point(data = as.data.frame(clusters()$centers), aes_string(x = input$xcol, y = input$ycol), shape = 4, size = 4, color = "black", stroke = 2)
    })
    
    output$summaryx <- renderText({
        summary(selectedData()[, input$xcol])
    })

    output$summaryy <- renderText({
        summary(selectedData()[, input$ycol])
    })
    
}
