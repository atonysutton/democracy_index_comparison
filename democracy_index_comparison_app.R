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

# Define UI for application that draws a three-line chart

ui <- fluidPage(
    
    # Application title
    #titlePanel('Compare Democracy Indexes'),
    h1('Compare Democracy Indexes'),
    p('  a modest tool provided by Tony Sutton'),
    
    # Sidebar with a slider input for range of years
    sidebarLayout(
        sidebarPanel(
            sliderInput("year_range",
                        "Range of years:",
                        min = 1789,
                        max = 2020,
                        value = c(1945, 2020),
                        sep = ''),
            textInput("country",
                        "Country of interest:",
                        value = 'India'),
            p("Country name must match the name used in V-Dem's dataset. Capitalization does not matter.")
        ),
        
        

        # Show a plot of the generated lines
        mainPanel(
           plotOutput("three_line_chart"),
           #plus notes on data and methodology
           HTML("<p>Note that data for all three indexes come from <a href = 'https://www.v-dem.net/vdemds.html'>V-Dem v11.1</a>.</p>"),
           HTML("<ul>
                  <li>V-Dem offers five indexes of distinct facets of democracy, along with numerous constituent indicators; this chart displays only the polyarchy index.</li>
                  <li><a href = 'https://www.systemicpeace.org/polityproject.html'>Polity</a> codes autocratic and democratic features on separate ten-point scales; this chart subtracts autocracy from democracy and rescales to a one-point scale.</li>
                  <li><a href = 'https://freedomhouse.org/reports/freedom-world/freedom-world-research-methodology'>Freedom House</a> codes civil liberties and political rights on separate seven-point scales; this chart inverts the scale such that higher numbers indicate more democracy, adds the two elements, and rescales to a one-point scale.</li>
                </ul>")
        )
    )
)

# Define server logic required to draw the line chart
server <- function(input, output) {
    
    
    #load data
    dem <- read_csv('../democracy_index_comparison.csv')
    
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
            scale_color_manual(values = index_colors, labels = c('Freedom House', 'Polity 5', 'V-Dem Polyarchy'))+
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

# Run the application 
shinyApp(ui = ui, server = server)
