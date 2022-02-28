#
# This Shiny web application displays values from three democracy indexes
#  for one country over a specified time range. 
#
# You can run the application by clicking the 'Run App' button above.
# Find out more about building applications with Shiny at:
#    http://shiny.rstudio.com/
#
# Code by Tony Sutton
# January 2022

library(shiny)
library(tidyverse)

# Define server logic required to draw the three-line chart
server <- function(input, output, session) {
  
  
  #load data
  dem <- read_csv('./democracy_index_comparison.csv')
  
  #list countries to choose from
  updateSelectizeInput(session,
                       'country',
                       choices = str_sort(unique(dem$country[dem$year==2020])),
                       selected = 'India',
                       server = TRUE)
  
  #specify colors
  index_colors <- c(vdem = 'blueviolet', polity = 'dodgerblue', fh = 'cadetblue2')
  
  #create chart
  output$three_line_chart <- renderPlot({
    # draw the line chart with the specified country and year range
    dem %>% filter(year >= input$year_range[1],
                   year <= input$year_range[2],
                   tolower(country) == tolower(input$country)) %>%
      ggplot(aes(x = year, y = score, color = index))+
      geom_line(size = 1.6)+
      scale_color_manual(values = index_colors, labels = c('\nFreedom\n  House', '\nPolity 5\n', '\nV-Dem\n  Polyarchy'))+
      coord_cartesian(ylim = c(0,1))+
      theme_minimal()+
      labs(title = paste('Measuring Democracy in', input$country),
           y = 'Democracy Score',
           x = 'Year',
           color = 'Democracy\n index')+
      theme(title = element_text(size = 20, face = 'bold'),
            axis.title = element_text(size = 18, face = 'bold'),
            axis.title.y = element_text(margin = margin(r = 8)),
            panel.grid.minor.y = element_blank(),
            axis.text = element_text(size = 16),
            legend.text = element_text(size = 16)) 
  })
}
