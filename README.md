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

## License

MIT
