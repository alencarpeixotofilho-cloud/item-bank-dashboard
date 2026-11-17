# Item Bank Dashboard ----------------------------------------------------------------
# Run with: shiny::runApp()

library(shiny)
library(bslib)

source("R/indicators.R")
source("R/plots.R")

DEFAULT_BANK <- "examples/item_bank.csv"
DEFAULT_TARGET <- c("Internal Medicine" = 25, "Surgery" = 20, "Pediatrics" = 20,
                    "Obstetrics & Gynecology" = 20, "Public Health" = 15)

ui <- page_sidebar(
  title = "Item Bank Dashboard",
  theme = bs_theme(version = 5, primary = "#1f6feb", base_font = font_google("Inter")),
  sidebar = sidebar(
    width = 300,
    fileInput("file", "Item bank export (CSV)", accept = ".csv"),
    helpText("Leave empty to explore the synthetic sample bank."),
    selectInput("domain", "Domain", choices = c("All"), selected = "All"),
    checkboxGroupInput("status", "Status",
                       choices = c("Draft", "Under review", "Approved", "Returned", "Retired"),
                       selected = c("Draft", "Under review", "Approved", "Returned")),
    hr(),
    numericInput("exam_items", "Items per exam", 100, min = 10, step = 10),
    numericInput("forms", "Parallel forms needed", 8, min = 1, max = 20)
  ),
  layout_columns(
    fill = FALSE,
    value_box("Items in bank", textOutput("k_total"), showcase = icon("database")),
    value_box("Approved", textOutput("k_approved"), showcase = icon("circle-check"), theme = "success"),
    value_box("Higher-order (approved)", textOutput("k_higher"), showcase = icon("brain"), theme = "primary"),
    value_box("With detected flaws", textOutput("k_flawed"), showcase = icon("triangle-exclamation"), theme = "warning")
  ),
  navset_card_underline(
    nav_panel("Coverage", layout_columns(
      plotOutput("p_coverage", height = 320), tableOutput("t_coverage"), col_widths = c(7, 5))),
    nav_panel("Cognitive level", layout_columns(
      plotOutput("p_bloom", height = 320), tableOutput("t_bloom"), col_widths = c(7, 5))),
    nav_panel("Pipeline", layout_columns(
      plotOutput("p_status", height = 320), plotOutput("p_flow", height = 320))),
    nav_panel("Psychometrics", plotOutput("p_psy", height = 380)),
    nav_panel("Items", DT::DTOutput("t_items"))
  )
)

server <- function(input, output, session) {
  bank <- reactive({
    path <- if (is.null(input$file)) DEFAULT_BANK else input$file$datapath
    read_bank(path)
  })
  observe({
    updateSelectInput(session, "domain", choices = c("All", sort(unique(bank()$domain))))
  })
  filtered <- reactive({
    b <- bank()
    if (input$domain != "All") b <- b[b$domain == input$domain, ]
    b[b$status %in% input$status, ]
  })
  k <- reactive(kpis(filtered()))

  output$k_total <- renderText(format(k()$total, big.mark = ","))
  output$k_approved <- renderText(sprintf("%d (%.0f%%)", k()$approved, k()$approved_pct))
  output$k_higher <- renderText(sprintf("%.0f%%", k()$higher_order_pct))
  output$k_flawed <- renderText(sprintf("%.0f%%", k()$flawed_pct))

  cov <- reactive(coverage(bank(), DEFAULT_TARGET, input$exam_items, input$forms))
  output$p_coverage <- renderPlot(plot_coverage(cov()), res = 110)
  output$t_coverage <- renderTable(cov()[, c("domain", "approved", "needed", "gap")])
  output$p_bloom <- renderPlot(plot_bloom(filtered()), res = 110)
  output$t_bloom <- renderTable(bloom_table(filtered()), rownames = TRUE)
  output$p_status <- renderPlot(plot_status(filtered()), res = 110)
  output$p_flow <- renderPlot(plot_flow(monthly_flow(filtered())), res = 110)
  output$p_psy <- renderPlot(plot_psychometrics(psychometric_flags(filtered())), res = 110)
  output$t_items <- DT::renderDT(
    DT::datatable(filtered()[, c("item_id", "domain", "topic", "competency", "bloom", "status",
                                 "flaws_detected", "times_used", "p_value", "r_pbis")],
                  filter = "top", rownames = FALSE, options = list(pageLength = 15))
  )
}

shinyApp(ui, server)
