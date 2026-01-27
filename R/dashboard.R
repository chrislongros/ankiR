#' Launch interactive Anki dashboard
#'
#' Opens a Shiny dashboard with comprehensive collection analytics.
#'
#' @param path Path to collection.anki2 (auto-detected if NULL)
#' @param profile Profile name (first profile if NULL)
#' @return Opens a Shiny app in the browser
#' @export
#' @examples
#' \dontrun{
#' anki_dashboard()
#' }
anki_dashboard <- function(path = NULL, profile = NULL) {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' is required. Install with: install.packages('shiny')")
  }
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required. Install with: install.packages('ggplot2')")
  }
 
  # Resolve path once
  if (is.null(path)) {
    path <- anki_db_path(profile)
  }
 
  ui <- shiny::fluidPage(
    shiny::titlePanel("ankiR Dashboard"),
   
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        width = 3,
        shiny::h4("Collection"),
        shiny::verbatimTextOutput("collection_path"),
        shiny::hr(),
        shiny::h4("Quick Stats"),
        shiny::tableOutput("quick_stats"),
        shiny::hr(),
        shiny::actionButton("refresh", "Refresh Data", class = "btn-primary")
      ),
     
      shiny::mainPanel(
        width = 9,
        shiny::tabsetPanel(
          shiny::tabPanel("Overview",
            shiny::fluidRow(
              shiny::column(6, shiny::plotOutput("heatmap", height = "300px")),
              shiny::column(6, shiny::plotOutput("retention_plot", height = "300px"))
            ),
            shiny::fluidRow(
              shiny::column(6, shiny::plotOutput("intervals_plot", height = "300px")),
              shiny::column(6, shiny::plotOutput("hours_plot", height = "300px"))
            )
          ),
         
          shiny::tabPanel("Decks",
            shiny::h4("Deck Statistics"),
            shiny::tableOutput("deck_stats"),
            shiny::hr(),
            shiny::h4("Deck Comparison"),
            shiny::plotOutput("deck_comparison", height = "400px")
          ),
         
          shiny::tabPanel("FSRS",
            shiny::fluidRow(
              shiny::column(6, shiny::plotOutput("difficulty_plot", height = "300px")),
              shiny::column(6, shiny::plotOutput("stability_plot", height = "300px"))
            ),
            shiny::hr(),
            shiny::h4("Forgetting Index"),
            shiny::verbatimTextOutput("forgetting_index"),
            shiny::hr(),
            shiny::h4("Workload Estimate"),
            shiny::tableOutput("workload_estimate")
          ),
         
          shiny::tabPanel("Time Analysis",
            shiny::h4("Reviews by Hour"),
            shiny::tableOutput("hourly_stats"),
            shiny::hr(),
            shiny::h4("Reviews by Day of Week"),
            shiny::tableOutput("weekday_stats"),
            shiny::hr(),
            shiny::h4("Consistency Score"),
            shiny::verbatimTextOutput("consistency")
          ),
         
          shiny::tabPanel("Quality",
            shiny::h4("Quality Report"),
            shiny::verbatimTextOutput("quality_report"),
            shiny::hr(),
            shiny::h4("Tag Analysis"),
            shiny::verbatimTextOutput("tag_analysis"),
            shiny::hr(),
            shiny::h4("Leeches"),
            shiny::tableOutput("leeches")
          ),
         
          shiny::tabPanel("Streaks",
            shiny::h4("Current Streak"),
            shiny::verbatimTextOutput("streak_info"),
            shiny::hr(),
            shiny::h4("Monthly Summary"),
            shiny::tableOutput("monthly_summary")
          )
        )
      )
    )
  )
 
  server <- function(input, output, session) {
    # Reactive data
    data <- shiny::reactiveValues(loaded = FALSE)
   
    load_data <- function() {
      shiny::withProgress(message = "Loading data...", {
        data$report <- anki_report(path)
        shiny::incProgress(0.2)
        data$deck_stats <- anki_stats_deck(path)
        shiny::incProgress(0.2)
        data$daily <- anki_stats_daily(path, from = Sys.Date() - 90)
        shiny::incProgress(0.2)
        data$cards_fsrs <- tryCatch(anki_cards_fsrs(path), error = function(e) NULL)
        shiny::incProgress(0.2)
        data$cards <- anki_cards(path)
        data$loaded <- TRUE
      })
    }
   
    shiny::observe({
      load_data()
    })
   
    shiny::observeEvent(input$refresh, {
      load_data()
    })
   
    output$collection_path <- shiny::renderText({
      basename(dirname(path))
    })
   
    output$quick_stats <- shiny::renderTable({
      shiny::req(data$loaded)
      r <- data$report
      data.frame(
        Metric = c("Cards", "Notes", "Reviews", "Streak"),
        Value = c(r$total_cards, r$total_notes, r$total_reviews, r$current_streak)
      )
    }, striped = TRUE)
   
    output$heatmap <- shiny::renderPlot({
      shiny::req(data$loaded)
      tryCatch(anki_plot_heatmap(path), error = function(e) NULL)
    })
   
    output$retention_plot <- shiny::renderPlot({
      shiny::req(data$loaded)
      tryCatch(anki_plot_retention(path, days = 90), error = function(e) NULL)
    })
   
    output$intervals_plot <- shiny::renderPlot({
      shiny::req(data$loaded)
      tryCatch(anki_plot_intervals(path), error = function(e) NULL)
    })
   
    output$hours_plot <- shiny::renderPlot({
      shiny::req(data$loaded)
      tryCatch(anki_plot_hours(path), error = function(e) NULL)
    })
   
    output$deck_stats <- shiny::renderTable({
      shiny::req(data$loaded)
      df <- data$deck_stats
      if (nrow(df) > 0) {
        df[, c("name", "total", "new", "review", "mature", "avg_interval")]
      }
    }, striped = TRUE)
   
    output$deck_comparison <- shiny::renderPlot({
      shiny::req(data$loaded)
      df <- data$deck_stats
      if (nrow(df) > 0) {
        ggplot2::ggplot(df, ggplot2::aes(x = reorder(name, total), y = total)) +
          ggplot2::geom_col(fill = "#3498db", alpha = 0.8) +
          ggplot2::coord_flip() +
          ggplot2::labs(title = "Cards by Deck", x = NULL, y = "Cards") +
          ggplot2::theme_minimal()
      }
    })
   
    output$difficulty_plot <- shiny::renderPlot({
      shiny::req(data$loaded)
      tryCatch(anki_plot_difficulty(path), error = function(e) NULL)
    })
   
    output$stability_plot <- shiny::renderPlot({
      shiny::req(data$loaded)
      tryCatch(anki_plot_stability(path), error = function(e) NULL)
    })
   
    output$forgetting_index <- shiny::renderPrint({
      shiny::req(data$loaded)
      tryCatch({
        fi <- fsrs_forgetting_index(path)
        cat("Forgetting Index:", fi$forgetting_index, "%\n")
        cat("Cards Below Target:", fi$cards_below_target, "/", fi$cards_analyzed, "\n")
        cat("Average Retrievability:", fi$avg_retrievability, "\n")
      }, error = function(e) cat("FSRS data not available"))
    })
   
    output$workload_estimate <- shiny::renderTable({
      shiny::req(data$loaded)
      tryCatch(fsrs_workload_estimate(path), error = function(e) data.frame())
    }, striped = TRUE)
   
    output$hourly_stats <- shiny::renderTable({
      shiny::req(data$loaded)
      tryCatch({
        df <- anki_time_by_hour(path)
        df[df$reviews > 0, c("hour", "reviews", "retention", "total_time_min")]
      }, error = function(e) data.frame())
    }, striped = TRUE)
   
    output$weekday_stats <- shiny::renderTable({
      shiny::req(data$loaded)
      tryCatch(anki_time_by_weekday(path), error = function(e) data.frame())
    }, striped = TRUE)
   
    output$consistency <- shiny::renderPrint({
      shiny::req(data$loaded)
      tryCatch({
        c <- anki_consistency(path)
        cat("Study Rate:", c$study_rate, "%\n")
        cat("Consistency Score:", c$consistency_score, "\n")
        cat("Avg Reviews/Day:", c$avg_reviews_per_day, "\n")
        cat("Current Streak:", c$current_streak, "days\n")
      }, error = function(e) cat("Error calculating consistency"))
    })
   
    output$quality_report <- shiny::renderPrint({
      shiny::req(data$loaded)
      tryCatch({
        q <- anki_quality_report(path)
        cat("=== Overview ===\n")
        print(q$overview, row.names = FALSE)
        cat("\n=== Recommendations ===\n")
        cat(paste(q$recommendations, collapse = "\n"))
      }, error = function(e) cat("Error generating quality report"))
    })
   
    output$tag_analysis <- shiny::renderPrint({
      shiny::req(data$loaded)
      tryCatch({
        t <- anki_tag_analysis(path)
        cat("Total Tags:", t$total_tags, "\n")
        cat("Notes with Tags:", t$notes_with_tags, "\n")
        cat("Notes without Tags:", t$notes_without_tags, "\n")
        cat("Avg Tags/Note:", t$avg_tags_per_note, "\n")
        if (length(t$orphan_tags) > 0) {
          cat("\nOrphan Tags:", paste(head(t$orphan_tags, 5), collapse = ", "), "\n")
        }
      }, error = function(e) cat("Error analyzing tags"))
    })
   
    output$leeches <- shiny::renderTable({
      shiny::req(data$loaded)
      tryCatch({
        l <- anki_leeches(path, include_notes = TRUE)
        if (nrow(l) > 0) {
          head(l[, c("cid", "lapses", "ivl", "sfld")], 20)
        } else {
          data.frame(Message = "No leeches found")
        }
      }, error = function(e) data.frame())
    }, striped = TRUE)
   
    output$streak_info <- shiny::renderPrint({
      shiny::req(data$loaded)
      s <- anki_streak(path)
      cat("Current Streak:", s$current_streak, "days\n")
      cat("Longest Streak:", s$longest_streak, "days\n")
      cat("Total Days Studied:", s$total_days_studied, "\n")
      cat("Last Review:", as.character(s$last_review), "\n")
    })
   
    output$monthly_summary <- shiny::renderTable({
      shiny::req(data$loaded)
      tryCatch(anki_monthly_summary(path), error = function(e) data.frame())
    }, striped = TRUE)
  }
 
  shiny::shinyApp(ui, server)
}
