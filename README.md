# ankiR

<!-- badges: start -->
[![R-CMD-check](https://github.com/chrislongros/ankiR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/chrislongros/ankiR/actions/workflows/R-CMD-check.yaml)
[![r-universe](https://cran.r-universe.dev/badges/ankiR)](https://cran.r-universe.dev/ankiR)
<!-- badges: end -->

Comprehensive R toolkit for reading, analyzing, and visualizing [Anki](https://apps.ankiweb.net/) flashcard collection databases. **91 functions** with full support for FSRS (Free Spaced Repetition Scheduler).

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

anki_report()
#> $total_cards
#> [1] 5847
#> $retention_rate
#> [1] 91.2
#> $current_streak
#> [1] 47
```

## Visualizations

### Time Series Analysis

Track your learning progress over time with built-in time series functions:

```r
retention <- anki_ts_retention(by = "week")
anki_ts_plot(retention, "retention", "Weekly Retention %")
```

![Weekly Retention](man/figures/retention.png)

```r
intervals <- anki_ts_intervals(by = "week")
anki_ts_plot(intervals, "median_ivl", "Weekly Median Interval")
```

![Weekly Intervals](man/figures/intervals.png)

```r
decomp <- anki_ts_decompose()
plot(decomp)
```

![Time Series Decomposition](man/figures/decomposition.png)

```r
anki_plot_heatmap()
```

![Review Heatmap](man/figures/heatmap.png)

### More Visualizations

```r
anki_plot_retention()     # Retention over time
anki_plot_forecast()      # Upcoming review workload
anki_plot_difficulty()    # FSRS difficulty distribution
anki_plot_intervals()     # Interval distribution histogram
anki_plot_hours()         # Reviews by hour of day
anki_plot_weekdays()      # Reviews by day of week
```

## Features

### Time Series Functions

| Function | Description |
|----------|-------------|
| `anki_ts_intervals()` | Track interval growth over time |
| `anki_ts_retention()` | Retention rate trends |
| `anki_ts_stability()` | FSRS stability trends |
| `anki_ts_workload()` | Review workload over time |
| `anki_ts_learning()` | New cards learned per period |
| `anki_ts_maturation()` | Card maturation tracking |
| `anki_ts_decompose()` | Decompose into trend + seasonal + residual |
| `anki_ts_anomalies()` | Detect unusual study days |
| `anki_ts_forecast()` | Forecast future reviews |
| `anki_ts_autocorrelation()` | Find cyclical patterns |
| `anki_ts_plot()` | Plot any time series with trend line |

### Search (Anki-like syntax)

```r
anki_search("deck:Medical tag:cardiology")
anki_search("is:due -is:suspended prop:ivl>30")

anki_leeches()       # Problem cards
anki_mature()        # Cards with ivl >= 21
anki_due()           # Due for review
```

### FSRS Support

```r
anki_cards_fsrs()                    # Get FSRS parameters
fsrs_current_retrievability()        # Current memory state
fsrs_forgetting_index()              # % below target retention
fsrs_time_to_mastery(deck = "Med")   # When will deck be learned?
fsrs_review_burden()                 # Long-term workload estimate
```

### Comparative Analysis

```r
anki_compare_periods()    # This month vs last month
anki_compare_decks()      # Side-by-side deck stats
anki_benchmark()          # Compare to FSRS averages
```

### Card Quality

```r
anki_quality_report()              # Overall quality assessment
anki_similar_cards(threshold=0.9)  # Find duplicates
anki_tag_analysis()                # Tag statistics
```

### Export

```r
anki_to_csv("Medical", "medical.csv")
anki_to_org("Medical", "medical.org")
anki_to_markdown("Medical", "medical.md", format = "obsidian")
anki_to_html("report.html")
fsrs_export_reviews("reviews.csv")
```

### Interactive Dashboard

```r
anki_dashboard()  # Launches Shiny app
```

## Function Reference

| Category | Count | Key Functions |
|----------|------:|---------------|
| Core | 8 | `anki_cards`, `anki_notes`, `anki_decks`, `anki_revlog` |
| Analytics | 12 | `anki_report`, `anki_stats_deck`, `anki_stats_daily` |
| Plotting | 8 | `anki_plot_heatmap`, `anki_plot_retention`, `anki_plot_forecast` |
| Time Series | 11 | `anki_ts_intervals`, `anki_ts_decompose`, `anki_ts_anomalies` |
| Compare | 5 | `anki_compare_decks`, `anki_compare_periods`, `anki_benchmark` |
| Search | 7 | `anki_search`, `anki_leeches`, `anki_mature`, `anki_due` |
| Quality | 6 | `anki_quality_report`, `anki_similar_cards`, `anki_tag_analysis` |
| FSRS | 14 | `fsrs_retrievability`, `fsrs_forgetting_index`, `fsrs_review_burden` |
| Media | 5 | `anki_media_list`, `anki_media_unused`, `anki_media_missing` |
| Export | 8 | `anki_to_csv`, `anki_to_org`, `anki_to_markdown`, `anki_to_html` |
| Dashboard | 1 | `anki_dashboard` |
| **Total** | **91** | |

## Requirements

- R >= 4.1
- Anki 2.1+ (collection.anki2 format)
- Optional: ggplot2 (plots), shiny (dashboard)

## Related Projects

- [r-fsrs](https://github.com/open-spaced-repetition/r-fsrs) - FSRS optimizer in R
- [FSRS4Anki](https://github.com/open-spaced-repetition/fsrs4anki) - FSRS for Anki

## License

MIT
