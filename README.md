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

## Package Overview

```
ankiR
|-- Core Access ------- anki_cards(), anki_notes(), anki_decks(), anki_revlog()
|-- Analytics --------- anki_report(), anki_stats_deck(), anki_retention_rate()
|-- Visualization ----- anki_plot_heatmap(), anki_plot_retention(), ...
|-- Time Series ------- anki_ts_intervals(), anki_ts_decompose(), ...
|-- FSRS -------------- fsrs_retrievability(), fsrs_forgetting_index(), ...
|-- Search ------------ anki_search(), anki_leeches(), anki_mature()
|-- Quality ----------- anki_quality_report(), anki_similar_cards()
|-- Export ------------ anki_to_csv(), anki_to_org(), anki_to_markdown()
+-- Dashboard --------- anki_dashboard()
```

## Quick Start

```r
library(ankiR)

# Get a comprehensive report
anki_report()
#> Using profile: User 1
#> 
#> $total_cards
#> [1] 5847
#> 
#> $total_notes
#> [1] 4521
#> 
#> $mature_cards
#> [1] 3892
#> 
#> $retention_rate
#> [1] 91.2
#> 
#> $current_streak
#> [1] 47
#> 
#> $avg_reviews_per_day
#> [1] 156
```

## Features

### Visualization

```r
# Calendar heatmap (GitHub-style)
anki_plot_heatmap()
```
```
        Review Activity 2024
     +--------------------------------------------------+
 Mon |..##..##..##..##..##..##..##..##..##..##..##..##..|
 Tue |..##..##..##..##..##..##..##..##..##..##..##..##..|
 Wed |################################################..|  @@@@ 400+
 Thu |##@@##@@##@@##@@##@@##@@##@@##@@##@@##@@##@@##@@..|  #### 200+
 Fri |..##..##..##..##..##..##..##..##..##..##..##..##..|  .... 1+
 Sat |..........##..........##..........##..........##..|       0
 Sun |..................................................|
     +--------------------------------------------------+
      Jan    Feb    Mar    Apr    May    Jun    Jul
```

```r
# Other visualizations
anki_plot_retention()      # Retention rate over time with rolling average
anki_plot_forecast()       # Upcoming review workload
anki_plot_difficulty()     # FSRS difficulty distribution
anki_plot_intervals()      # Card interval distribution
anki_plot_hours()          # Reviews by hour of day
anki_plot_weekdays()       # Reviews by day of week
```

### Time Series Analysis

```r
# Track how your intervals grow over time
intervals <- anki_ts_intervals(by = "week")
intervals
#> # A tibble: 52 x 8
#>    date       reviews mean_ivl median_ivl sd_ivl max_ivl pct_mature mean_ivl_ma
#>    <date>       <int>    <dbl>      <dbl>  <dbl>   <dbl>      <dbl>       <dbl>
#>  1 2024-01-01     847     45.2         32   52.3     365       67.2        NA
#>  2 2024-01-08     923     48.1         35   54.1     380       69.5        NA
#>  3 2024-01-15     891     51.3         38   55.8     392       71.8        NA
#>  4 2024-01-22     856     54.7         41   57.2     405       73.4        49.8

# Plot with trend line
anki_ts_plot(intervals, "median_ivl", "Median Interval Growth")

# Detect unusual study days
anomalies <- anki_ts_anomalies(threshold = 2)
#> # A tibble: 5 x 6
#>   date       reviews time_minutes retention reviews_z anomaly_type
#>   <date>       <int>        <dbl>     <dbl>     <dbl> <chr>
#> 1 2024-03-15     523         87.2      89.1      3.21 high_reviews
#> 2 2024-05-01      12          2.1      75.0     -2.45 low_reviews

# Decompose into trend + seasonal + residual
decomp <- anki_ts_decompose()
plot(decomp)

# Find weekly patterns (autocorrelation)
acf <- anki_ts_autocorrelation()
#> Weekly pattern detected (autocorrelation at lag 7: 0.423)
```

### Search (Anki-like syntax)

```r
# Search just like in Anki's browser
anki_search("deck:Medical tag:cardiology")
anki_search("is:due -is:suspended prop:ivl>30")
anki_search("rated:7:1")  # Cards rated "Again" in last 7 days

# Quick filters
anki_leeches(threshold = 8)
#> # A tibble: 23 x 5
#>         cid lapses   ivl queue sfld
#>       <dbl>  <int> <int> <int> <chr>
#> 1 148293847     12     3    -1 "What is the mechanism of..."
#> 2 148293912      9     5     2 "Name the branches of..."

anki_mature()              # Cards with interval >= 21 days
anki_due()                 # Cards due for review
anki_suspended()           # Suspended cards
```

### FSRS Support

```r
# Get FSRS parameters for all cards
cards_fsrs <- anki_cards_fsrs()
#> # A tibble: 5,847 x 5
#>         cid stability difficulty decay last_review
#>       <dbl>     <dbl>      <dbl> <dbl> <date>
#> 1 148293847      45.2       4.32  0.52 2024-06-15
#> 2 148293912      12.1       7.89  0.48 2024-06-14

# Current memory state
fsrs_current_retrievability()
#> # A tibble: 4,521 x 4
#>         cid stability days_elapsed retrievability
#>       <dbl>     <dbl>        <dbl>          <dbl>
#> 1 148293847      45.2            3          0.967
#> 2 148293912      12.1            4          0.891

# What percentage of cards are below target retention?
fsrs_forgetting_index(target_retention = 0.9)
#> $forgetting_index
#> [1] 12.3
#> 
#> $cards_below_target
#> [1] 557
#> 
#> $distribution
#> # A tibble: 4 x 2
#>   range    percentage
#>   <chr>         <dbl>
#> 1 < 70%           2.1
#> 2 70-80%          4.5
#> 3 80-90%          5.7
#> 4 > 90%          87.7

# Predict when a deck will be "learned"
fsrs_time_to_mastery(deck = "Medical", target_mature_pct = 90)
#> $estimated_days_to_target
#> [1] 45
#> 
#> $estimated_date
#> [1] "2024-08-01"
```

### Comparative Analysis

```r
# Compare this month vs last month
anki_compare_periods()
#> # A tibble: 3 x 8
#>   period    total_reviews days_studied avg_per_day retention time_hours
#>   <chr>             <int>        <int>       <dbl>     <dbl>      <dbl>
#> 1 June 2024          4521           28       161.       91.2       18.2
#> 2 July 2024          4892           27       181.       92.1       19.5
#> 3 Change              371           -1        20.1       0.9        1.3

# Benchmark against FSRS research averages
anki_benchmark()
#> # A tibble: 6 x 5
#>   metric              benchmark your_value difference status
#>   <chr>                   <dbl>      <dbl>      <dbl> <chr>
#> 1 Retention Rate           0.9       0.91       0.01  OK Good
#> 2 Avg Interval (days)     45        52          7     OK Above
#> 3 Avg Difficulty           5.5       4.8       -0.7   OK Good
#> 4 Avg Stability (days)    60        68          8     OK Above
```

### Card Quality Analysis

```r
# Comprehensive quality report
anki_quality_report()
#> $overview
#> # A tibble: 8 x 2
#>   metric                    value
#>   <chr>                     <dbl>
#> 1 Total Notes                4521
#> 2 Total Cards                5847
#> 3 Notes with Empty Fields      23
#> 4 Very Long Notes (>2000)      12
#> 5 Leech Cards                  45
#> 
#> $recommendations
#> [1] "! 0.5% of notes have empty fields"
#> [2] "! 0.8% of cards are leeches (8+ lapses)"
#> [3] "TIP: Consider adding more images/audio for better retention"

# Find potential duplicates
anki_similar_cards(threshold = 0.9)
#> # A tibble: 3 x 5
#>      nid1    nid2 similarity text1                    text2
#>     <dbl>   <dbl>      <dbl> <chr>                    <chr>
#> 1 1482938 1482945      0.95  "What causes hyperten.." "What is the cause of.."

# Tag analysis
anki_tag_analysis()
#> $total_tags
#> [1] 156
#> 
#> $orphan_tags
#> [1] "cardiology::old" "temp::review"
```

### Export Formats

```r
# Export to various formats
anki_to_csv("Medical", "medical.csv")
anki_to_org("Medical", "medical.org")           # Org-mode (org-fc)
anki_to_markdown("Medical", "medical.md", format = "obsidian")
anki_to_supermemo("Medical", "medical.txt")     # SuperMemo Q&A
anki_to_html("report.html")                     # Standalone HTML report

# Export reviews for external FSRS analysis
fsrs_export_reviews("reviews.csv")
```

### Interactive Dashboard

```r
# Launch Shiny dashboard with all analytics
anki_dashboard()
```
```
+-----------------------------------------------------------------+
|  ankiR Dashboard                                    [Refresh]   |
+----------+------------------------------------------------------+
|          |  Overview | Decks | FSRS | Time | Quality | Streaks  |
| Profile  +------------------------------------------------------+
| User 1   |  +-----------------+  +-----------------+            |
|          |  | Review Heatmap  |  | Retention Plot  |            |
| Cards    |  | ##..##..##..##  |  |    ___/\___     |            |
| 5,847    |  | ############### |  |   /        \    |            |
|          |  | ..##..##..##..  |  |  /          \   |            |
| Streak   |  +-----------------+  +-----------------+            |
| 47 days  |  +-----------------+  +-----------------+            |
|          |  | Interval Dist.  |  | Reviews/Hour    |            |
| Reviews  |  |    .:#@#:.      |  |      .#@#.      |            |
| 89,432   |  +-----------------+  +-----------------+            |
+----------+------------------------------------------------------+
```

## Function Reference (91 functions)

| Category | Count | Key Functions |
|----------|-------|---------------|
| **Core** | 8 | `anki_collection()`, `anki_cards()`, `anki_notes()`, `anki_decks()`, `anki_models()`, `anki_revlog()` |
| **Analytics** | 12 | `anki_report()`, `anki_stats_deck()`, `anki_stats_daily()`, `anki_retention_rate()`, `anki_streak()` |
| **Plotting** | 8 | `anki_plot_heatmap()`, `anki_plot_retention()`, `anki_plot_forecast()`, `anki_plot_difficulty()` |
| **Time Series** | 11 | `anki_ts_intervals()`, `anki_ts_retention()`, `anki_ts_decompose()`, `anki_ts_anomalies()`, `anki_ts_forecast()` |
| **Compare** | 5 | `anki_compare_decks()`, `anki_compare_periods()`, `anki_benchmark()`, `anki_compare_by_age()` |
| **Time Analysis** | 6 | `anki_time_by_hour()`, `anki_time_by_weekday()`, `anki_session_stats()`, `anki_consistency()` |
| **Search** | 7 | `anki_search()`, `anki_leeches()`, `anki_suspended()`, `anki_buried()`, `anki_due()`, `anki_mature()` |
| **Quality** | 6 | `anki_card_complexity()`, `anki_similar_cards()`, `anki_tag_analysis()`, `anki_quality_report()` |
| **FSRS** | 14 | `anki_cards_fsrs()`, `fsrs_retrievability()`, `fsrs_forgetting_index()`, `fsrs_review_burden()` |
| **Media** | 5 | `anki_media_list()`, `anki_media_unused()`, `anki_media_missing()`, `anki_media_stats()` |
| **Export** | 8 | `anki_to_csv()`, `anki_to_org()`, `anki_to_markdown()`, `anki_to_html()`, `fsrs_export_reviews()` |
| **Dashboard** | 1 | `anki_dashboard()` |

## Data Flow

```
+---------------------+
|  collection.anki2   |  SQLite database
+----------+----------+
           |
           v
+--------------------------------------------------------------+
|  anki_collection()                                           |
|  |-- $cards()   -> tibble of cards with FSRS state           |
|  |-- $notes()   -> tibble of notes with fields               |
|  |-- $decks()   -> tibble of deck names and IDs              |
|  |-- $models()  -> tibble of note types                      |
|  +-- $revlog()  -> tibble of review history                  |
+--------------------------------------------------------------+
           |
           v
+--------------------------------------------------------------+
|  Analysis Functions                                          |
|  |-- anki_stats_*()      -> Statistics                       |
|  |-- anki_plot_*()       -> Visualizations (ggplot2)         |
|  |-- anki_ts_*()         -> Time series analysis             |
|  |-- anki_search()       -> Filter cards                     |
|  |-- fsrs_*()            -> FSRS calculations                |
|  +-- anki_to_*()         -> Export to files                  |
+--------------------------------------------------------------+
```

## Requirements

- R >= 4.1
- Anki 2.1.x or later (collection.anki2 format)
- Optional: ggplot2 (plotting), shiny (dashboard)

## Related Projects

- [r-fsrs](https://github.com/open-spaced-repetition/r-fsrs) - FSRS optimizer in R
- [FSRS4Anki](https://github.com/open-spaced-repetition/fsrs4anki) - FSRS for Anki

## License

MIT
