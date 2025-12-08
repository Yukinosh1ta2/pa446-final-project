library(shiny)
library(tidyverse)


il_df <- read_csv("../data/processed/il_broadband.csv", show_col_types = FALSE)
median_pct <- median(il_df$pct_broadband_any, na.rm = TRUE)

il_ml <- il_df %>%
  mutate(
    low_bb = if_else(pct_broadband_any < median_pct, "yes", "no")
  ) %>%
  drop_na(med_income, pct_broadband_any)

min_income <- floor(min(il_ml$med_income, na.rm = TRUE) / 1000) * 1000
max_income <- ceiling(max(il_ml$med_income, na.rm = TRUE) / 1000) * 1000

ui <- fluidPage(
  titlePanel("Illinois Broadband Explorer"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "income_range",
        label = "Select median household income range (USD):",
        min = min_income,
        max = max_income,
        value = c(min_income, max_income),
        step = 5000
      ),
      checkboxInput(
        "show_low_only",
        label = "Show only low-broadband counties (below median)",
        value = FALSE
      )
    ),
    
    mainPanel(
      plotOutput("scatter_plot"),
      br(),
      tableOutput("summary_table")
    )
  )
)

server <- function(input, output, session) {
  
  filtered_data <- reactive({
    d <- il_ml %>%
      filter(
        med_income >= input$income_range[1],
        med_income <= input$income_range[2]
      )
    
    if (input$show_low_only) {
      d <- d %>% filter(low_bb == "yes")
    }
    
    d
  })
  
  output$scatter_plot <- renderPlot({
    d <- filtered_data()
    
    ggplot(d, aes(x = med_income, y = pct_broadband_any,
                  color = low_bb)) +
      geom_point(size = 3, alpha = 0.8) +
      labs(
        x = "Median household income (USD)",
        y = "% households with broadband",
        color = "Low broadband?",
        title = "Income vs Broadband Access (interactive Shiny app)"
      ) +
      theme_minimal()
  })
  
  output$summary_table <- renderTable({
    filtered_data() %>%
      summarise(
        n_counties = n(),
        avg_income = round(mean(med_income, na.rm = TRUE), 0),
        avg_pct_bb = round(mean(pct_broadband_any, na.rm = TRUE), 1)
      )
  })
}

shinyApp(ui = ui, server = server)
