# ankiR

<!-- badges: start -->
[![R-CMD-check](https://github.com/chrislongros/ankiR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/chrislongros/ankiR/actions/workflows/R-CMD-check.yaml)
[![r-universe](https://cran.r-universe.dev/badges/ankiR)](https://cran.r-universe.dev/ankiR)
<!-- badges: end -->

Comprehensive R toolkit for reading, analyzing, and visualizing [Anki](https://apps.ankiweb.net/) flashcard collection databases. Full support for FSRS (Free Spaced Repetition Scheduler).

## Installation

```r
# From r-universe (recommended)
install.packages("ankiR", repos = "https://cran.r-universe.dev")

# From GitHub
remotes::install_github("chrislongros/ankiR")

# Arch Linux (AUR)
# yay -S r-ankir
```

## Quick Start

```r
library(ankiR)

# Get a summary report
anki_report()

# View your cards
cards <- anki_cards()
notes <- anki_notes()

# Check your streak
anki_streak()

# Launch interactive dashboard (requires shiny)
anki_dashboard()
```

## Features

### Analytics & Visualization

```r
anki_plot_heatmap()      # Calendar heatmap
anki_plot_retention()    # Retention over time
anki_plot_forecast()     # Review forecast
anki_plot_difficulty()   # FSRS difficulty distribution
anki_plot_hours()        # Reviews by hour
```

### Time Series Analysis

```r
anki_ts_intervals()      # Interval trends over time
anki_ts_retention()      # Retention trends
anki_ts_stability()      # FSRS stability trends
anki_ts_workload()       # Workload trends
anki_ts_learning()       # New cards learned per period
anki_ts_maturation()     # Card maturation tracking
anki_ts_decompose()      # Decompose to trend/seasonal/residual
anki_ts_anomalies()      # Detect unusual study days
anki_ts_forecast()       # Forecast future reviews
anki_ts_autocorrelation()# Find weekly/cyclical patterns
anki_ts_plot()           # Plot any time series with trend
```

### Search & Filter

```r
anki_search("deck:Medical tag:cardiology")
anki_search("is:due -is:suspended")
anki_leeches()
anki_mature()
```

### Comparative Analysis

```r
anki_compare_decks()
anki_compare_periods()
anki_benchmark()
```

### FSRS Support

```r
anki_cards_fsrs()
fsrs_current_retrievability()
fsrs_forgetting_index()
fsrs_review_burden()
fsrs_time_to_mastery()
```

### Card Quality

```r
anki_quality_report()
anki_similar_cards()
anki_tag_analysis()
```

### Export

```r
anki_to_csv("Medical", "medical.csv")
anki_to_org("Medical", "medical.org")
anki_to_markdown("Medical", "medical.md")
anki_to_html("report.html")
```

### Interactive Dashboard

```r
anki_dashboard()
```

## Function Reference (91 functions)

| Category | Functions |
|----------|-----------|
| **Core** | `anki_collection()`, `anki_cards()`, `anki_notes()`, `anki_decks()`, `anki_models()`, `anki_revlog()` |
| **Analytics** | `anki_report()`, `anki_stats_deck()`, `anki_stats_daily()`, `anki_retention_rate()`, `anki_streak()`, `anki_heatmap_data()` |
| **Plotting** | `anki_plot_heatmap()`, `anki_plot_retention()`, `anki_plot_forecast()`, `anki_plot_difficulty()`, `anki_plot_intervals()`, `anki_plot_stability()`, `anki_plot_hours()`, `anki_plot_weekdays()` |
| **Time Series** | `anki_ts_intervals()`, `anki_ts_retention()`, `anki_ts_stability()`, `anki_ts_workload()`, `anki_ts_learning()`, `anki_ts_maturation()`, `anki_ts_decompose()`, `anki_ts_anomalies()`, `anki_ts_forecast()`, `anki_ts_autocorrelation()`, `anki_ts_plot()` |
| **Compare** | `anki_compare_decks()`, `anki_compare_periods()`, `anki_benchmark()`, `anki_compare_by_age()`, `anki_compare_deck_difficulty()` |
| **Time** | `anki_time_by_hour()`, `anki_time_by_weekday()`, `anki_session_stats()`, `anki_response_time()`, `anki_monthly_summary()`, `anki_consistency()` |
| **Search** | `anki_search()`, `anki_leeches()`, `anki_suspended()`, `anki_buried()`, `anki_due()`, `anki_new()`, `anki_mature()` |
| **Quality** | `anki_card_complexity()`, `anki_similar_cards()`, `anki_tag_analysis()`, `anki_empty_cards()`, `anki_long_cards()`, `anki_quality_report()` |
| **FSRS** | `anki_cards_fsrs()`, `fsrs_retrievability()`, `fsrs_interval()`, `fsrs_current_retrievability()`, `fsrs_forgetting_index()`, `fsrs_review_burden()`, `fsrs_time_to_mastery()`, `fsrs_optimal_new_rate()`, `fsrs_simulate_new_deck()` |
| **Media** | `anki_media_list()`, `anki_media_unused()`, `anki_media_missing()`, `anki_media_stats()` |
| **Export** | `anki_to_csv()`, `anki_to_org()`, `anki_to_markdown()`, `anki_to_supermemo()`, `anki_to_html()`, `fsrs_export_reviews()`, `fsrs_from_csv()` |
| **Dashboard** | `anki_dashboard()` |

## Requirements

- R >= 4.1
- Anki 2.1.x or later (collection.anki2 format)

## License

MIT
