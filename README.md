# ankiR

[![R-CMD-check](https://github.com/chrislongros/ankiR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/chrislongros/ankiR/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/ankiR)](https://CRAN.R-project.org/package=ankiR)
[![r-universe](https://cran.r-universe.dev/badges/ankiR)](https://cran.r-universe.dev/ankiR)

R package for reading [Anki](https://apps.ankiweb.net/) flashcard databases with FSRS-6 parameter support.

## Installation

```r
# From CRAN
install.packages("ankiR")

# From r-universe
install.packages("ankiR", repos = "https://cran.r-universe.dev")

# Development version from GitHub
remotes::install_github("chrislongros/ankiR")
```

## Quick Start

```r
library(ankiR)

# Auto-detect Anki installation and open collection
col <- anki_collection()

# Access data via methods
notes <- col$notes()
cards <- col$cards()
decks <- col$decks()
reviews <- col$revlog()

# Don't forget to close the connection
col$close()
```

## Convenience Functions

For one-off queries, use the standalone functions (they handle connection cleanup automatically):
```r
# Read specific data
notes <- anki_notes()
cards <- anki_cards()
decks <- anki_decks()
models <- anki_models()
reviews <- anki_revlog()

# Specify a profile
cards <- anki_cards(profile = "User 1")

# Or provide a path directly
cards <- anki_cards(path = "/path/to/collection.anki2")
```

## FSRS Support

Extract [FSRS-6](https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-Algorithm) memory state parameters:

```r
# Get cards with FSRS parameters
cards_fsrs <- anki_cards_fsrs()

# Columns include: stability, difficulty, desired_retention, decay

# Calculate current retrievability (probability of recall)
cards_fsrs$days_since_due <- as.numeric(Sys.Date()) - cards_fsrs$due / 86400000
cards_fsrs$retrievability <- fsrs_retrievability(
  stability = cards_fsrs$stability,
  days_elapsed = cards_fsrs$days_since_due,
  decay = cards_fsrs$decay
)

# Calculate optimal interval for 90% retention
fsrs_interval(stability = 30, desired_retention = 0.9)
```

## Example: Analyze Learning Progress

```r
library(ankiR)
library(dplyr)
library(ggplot2)

# Get review history
reviews <- anki_revlog()

# Reviews per day
reviews |>
  count(review_date) |>
  ggplot(aes(review_date, n)) +
  geom_col() +
  labs(title = "Daily Reviews", x = "Date", y = "Reviews")

# Get deck statistics
cards <- anki_cards()
decks <- anki_decks()

cards |>
  left_join(decks, by = "did") |>
  group_by(name) |>
  summarise(
    total = n(),
    new = sum(type == 0),
    learning = sum(type == 1),
    review = sum(type == 2),
    avg_interval = mean(ivl[type == 2])
  )
```

## Platform Support

ankiR automatically detects your Anki installation on:

- **Windows**: `%APPDATA%\Anki2`
- **macOS**: `~/Library/Application Support/Anki2`
- **Linux**: `~/.local/share/Anki2` (or `$XDG_DATA_HOME/Anki2`)

## Related Packages

- [r-fsrs](https://github.com/open-spaced-repetition/r-fsrs) - FSRS algorithm implementation in R
- [py-fsrs](https://github.com/open-spaced-repetition/py-fsrs) - Python FSRS implementation

## License

MIT
