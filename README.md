# ankiR
 
[![R-CMD-check](https://github.com/chrislongros/ankiR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/chrislongros/ankiR/actions/workflows/R-CMD-check.yaml)
[![r-universe](https://cran.r-universe.dev/badges/ankiR)](https://cran.r-universe.dev/ankiR)

R package for reading and analyzing [Anki](https://apps.ankiweb.net/) flashcard databases with [FSRS-6](https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-Algorithm) support.

## Installation

```r
# From r-universe
install.packages("ankiR", repos = "https://cran.r-universe.dev")

# From GitHub
remotes::install_github("chrislongros/ankiR")

# Arch Linux (AUR)
yay -S r-ankir
```

## Quick Start

```r
library(ankiR)

# Auto-detect Anki and get a summary
report <- anki_report()
print(report)

# Read data directly
cards <- anki_cards()
decks <- anki_decks()
reviews <- anki_revlog()
```

## Features

### 📊 Analytics

```r
# Per-deck statistics
anki_stats_deck()

# Daily review statistics
anki_stats_daily(from = "2024-01-01")

# Retention rate (last 30 days)
anki_retention_rate(days = 30, by_deck = TRUE)

# Review streaks
streak <- anki_streak()
streak$current_streak
streak$longest_streak

# Heatmap data for visualization
heatmap <- anki_heatmap_data(year = 2024)
```

### 🔍 Search

```r
# Search like Anki's browser
anki_search("deck:Medical is:review prop:lapses>3")

# Find problem cards
anki_leeches(threshold = 8)
anki_suspended()

# Get specific card types
anki_due(days_ahead = 7)
anki_mature(min_interval = 21)
anki_new()
```

### 🧠 FSRS Analysis

```r
# Cards with FSRS parameters
cards_fsrs <- anki_cards_fsrs()

# Current retrievability for all cards
r <- fsrs_current_retrievability()
urgent <- r[r$retrievability < 0.8, ]

# Difficulty/stability distributions
fsrs_difficulty_distribution(by_deck = TRUE)
fsrs_stability_distribution()

# Workload estimation at different retention targets
fsrs_workload_estimate()

# Prepare data for r-fsrs optimizer
items <- fsrs_prepare_for_optimizer()
```

### 📁 Media Management

```r
# List media files
anki_media_list()

# Find unused media (cleanup candidates)
anki_media_unused()

# Find missing media references
anki_media_missing()

# Media statistics
anki_media_stats()
```

### 📤 Export

```r
# Export deck to CSV
anki_to_csv("Medical", file = "medical_cards.csv")

# Export review history
anki_export_revlog("reviews.csv")

# Full collection report
report <- anki_report()
```

## Example: Learning Analysis

```r
library(ankiR)
library(ggplot2)

# Review heatmap
heatmap_data <- anki_heatmap_data(year = 2024)
ggplot(heatmap_data, aes(week, weekday, fill = reviews)) +
  geom_tile() +
  scale_fill_viridis_c() +
  labs(title = "Review Activity")

# Retention by deck
retention <- anki_retention_rate(days = 90, by_deck = TRUE)
ggplot(retention, aes(reorder(name, retention), retention)) +
  geom_col() +
  coord_flip() +
  labs(title = "Retention Rate by Deck", x = NULL)

# FSRS stability distribution
cards_fsrs <- anki_cards_fsrs()
ggplot(cards_fsrs, aes(stability)) +
  geom_histogram(bins = 50) +
  scale_x_log10() +
  labs(title = "Memory Stability Distribution")
```

## Platform Support

Automatically detects Anki on:
- **Windows**: `%APPDATA%\Anki2`
- **macOS**: `~/Library/Application Support/Anki2`
- **Linux**: `~/.local/share/Anki2`

## Related Projects

- [r-fsrs](https://github.com/open-spaced-repetition/r-fsrs) - FSRS algorithm in R
- [fsrs4anki](https://github.com/open-spaced-repetition/fsrs4anki) - FSRS for Anki
- [py-fsrs](https://github.com/open-spaced-repetition/py-fsrs) - Python FSRS

## License

MIT
