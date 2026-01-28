# ankiR

<!-- badges: start -->
[![R-CMD-check](https://github.com/chrislongros/ankiR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/chrislongros/ankiR/actions/workflows/R-CMD-check.yaml)
[![r-universe](https://cran.r-universe.dev/badges/ankiR)](https://cran.r-universe.dev/ankiR)
<!-- badges: end -->

Comprehensive R toolkit for reading, analyzing, and visualizing [Anki](https://apps.ankiweb.net/) flashcard collection databases. **133 functions** with full support for FSRS (Free Spaced Repetition Scheduler).

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

# One-liner overview
anki_quick_summary()
#> Anki: 5847 cards (4521 mature, 892 young, 434 new) | Due: 127 | Streak: 47 days | Retention: 91.2%

# Detailed report
anki_report()

# Collection health check (0-100 score)
anki_health_check()
```

## What's New in 0.6.0

### Learning Efficiency Analysis

```r
anki_learning_efficiency()    # ROI: retention per time spent
anki_retention_by_type()      # Retention by card type (cloze, basic, media)
anki_roi_analysis()           # Knowledge half-life extension per study minute
```

### Forgetting Curve Fitting

```r
# Fit your personal forgetting curve and compare to FSRS defaults
curve <- anki_fit_forgetting_curve()
anki_plot_forgetting_curve(curve)
```

### Optimal Review Times

```r
anki_best_review_times()      # Find when you learn best
anki_session_analysis()       # Analyze study session patterns
anki_simulate_session(30)     # Simulate a 30-minute session
```

### Sibling & Interference Analysis

```r
anki_sibling_analysis()       # How do sibling cards affect each other?
anki_interference_analysis()  # Find cards you confuse with each other
anki_weak_areas()             # Tags/decks with lowest retention
```

### Actionable Recommendations

```r
anki_card_recommendations()   # Leeches to rewrite, cards to unsuspend
anki_health_check()           # Comprehensive health score (0-100)
anki_summary()                # One-liner stats
anki_today()                  # Today's activity breakdown
```

### Academic/Exam Preparation

```r
anki_exam_readiness("2024-06-15")  # Will you be ready for your exam?
anki_coverage_analysis()           # % complete by topic
anki_study_priorities()            # What to study first
anki_study_plan("2024-06-15", hours_per_day = 2)
```

### Enhanced FSRS Analysis

```r
fsrs_compare_parameters()     # Compare your FSRS params to defaults
fsrs_memory_states()          # Current memory state for all cards
fsrs_decay_distribution()     # FSRS-6 per-card decay analysis
```

### New Export Formats

```r
anki_to_obsidian_sr()         # Obsidian Spaced Repetition plugin
anki_to_mochi()               # Mochi Cards JSON
anki_to_json()                # Full collection as JSON
anki_progress_report("html")  # Shareable progress report
```

### Enhanced Search

```r
# Advanced search operators
anki_search_enhanced("added:7 rated:3:1")      # Added in 7 days, rated Again in 3 days
anki_search_enhanced("prop:lapses>5 is:leech") # High-lapse leeches
anki_search_enhanced("re:^The\\s+")            # Regex search
anki_search_enhanced("deck:German OR deck:Spanish")

# Find similar cards with TF-IDF
anki_find_similar(1234567890, method = "tfidf")
```

### Enhanced Simulation & Forecasting

```r
# Monte Carlo simulation with confidence intervals
fsrs_simulate_enhanced(days = 90, simulations = 100)

# ARIMA/seasonal forecasting
anki_forecast_enhanced("reviews", method = "seasonal")

# Scenario-based workload projection
anki_workload_projection(days = 30)
```

## Visualizations

```r
anki_plot_heatmap()           # Calendar heatmap
anki_plot_retention()         # Retention over time
anki_plot_forecast()          # Upcoming workload
anki_plot_difficulty()        # FSRS difficulty distribution
anki_plot_intervals()         # Interval distribution
anki_plot_hours()             # Reviews by hour
anki_plot_weekdays()          # Reviews by weekday
anki_plot_forgetting_curve()  # Personal forgetting curve
```

![Review Heatmap](man/figures/heatmap.png)

### Time Series Analysis

```r
anki_ts_retention(by = "week")
anki_ts_intervals(by = "week")
anki_ts_decompose()           # Trend + seasonal + residual
anki_ts_anomalies()           # Unusual study days
anki_ts_forecast()            # Forecast future reviews
```

![Time Series Decomposition](man/figures/decomposition.png)

## Core Features

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
fsrs_compare_parameters()            # Compare to defaults
```

### Comparative Analysis

```r
anki_compare_periods()    # This month vs last month
anki_compare_decks()      # Side-by-side deck stats
anki_benchmark()          # Compare to FSRS averages
```

### Export

```r
anki_to_csv("Medical", "medical.csv")
anki_to_org("Medical", "medical.org")
anki_to_markdown("Medical", "medical.md", format = "obsidian")
anki_to_obsidian_sr("Medical", "medical_sr.md")
anki_to_mochi("Medical", "medical.json")
anki_to_json(output = "collection.json")
anki_progress_report(format = "html")
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
| Efficiency | 3 | `anki_learning_efficiency`, `anki_retention_by_type`, `anki_roi_analysis` |
| Forgetting | 2 | `anki_fit_forgetting_curve`, `anki_plot_forgetting_curve` |
| Optimal Times | 3 | `anki_best_review_times`, `anki_session_analysis`, `anki_simulate_session` |
| Sibling/Interference | 3 | `anki_sibling_analysis`, `anki_interference_analysis`, `anki_weak_areas` |
| Recommendations | 4 | `anki_card_recommendations`, `anki_health_check`, `anki_summary`, `anki_today` |
| Academic/Exam | 4 | `anki_exam_readiness`, `anki_coverage_analysis`, `anki_study_priorities`, `anki_study_plan` |
| Plotting | 8 | `anki_plot_heatmap`, `anki_plot_retention`, `anki_plot_forecast` |
| Time Series | 15 | `anki_ts_intervals`, `anki_ts_decompose`, `anki_forecast_enhanced` |
| Compare | 5 | `anki_compare_decks`, `anki_compare_periods`, `anki_benchmark` |
| Search | 9 | `anki_search`, `anki_search_enhanced`, `anki_find_similar` |
| Quality | 6 | `anki_quality_report`, `anki_similar_cards`, `anki_tag_analysis` |
| FSRS | 17 | `fsrs_retrievability`, `fsrs_compare_parameters`, `fsrs_memory_states` |
| Media | 5 | `anki_media_list`, `anki_media_unused`, `anki_media_missing` |
| Export | 12 | `anki_to_csv`, `anki_to_obsidian_sr`, `anki_to_mochi`, `anki_to_json` |
| Utilities | 6 | `anki_schema_version`, `anki_cache_enable`, `anki_quick_summary` |
| Dashboard | 1 | `anki_dashboard` |
| **Total** | **133** | |

## Requirements

- R >= 4.1
- Anki 2.1+ (collection.anki2 format)
- Optional: ggplot2 (plots), shiny (dashboard)

## Related Projects

- [r-fsrs](https://github.com/open-spaced-repetition/r-fsrs) - FSRS optimizer in R
- [FSRS4Anki](https://github.com/open-spaced-repetition/fsrs4anki) - FSRS for Anki

## License

MIT
