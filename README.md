# ankiR

[![R-CMD-check](https://github.com/chrislongros/ankiR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/chrislongros/ankiR/actions/workflows/R-CMD-check.yaml)
[![r-universe](https://cran.r-universe.dev/badges/ankiR)](https://cran.r-universe.dev/ankiR)

R package for reading [Anki](https://apps.ankiweb.net/) flashcard databases with [FSRS-6](https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-Algorithm) parameter support.

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

# Auto-detect Anki installation and open collection
col <- anki_collection()

# Access data via methods
notes <- col$notes()
cards <- col$cards()
decks <- col$decks()
models <- col$models()
reviews <- col$revlog()

# Close when done
col$close()
```

## Convenience Functions

For one-off queries (connection handled automatically):
```r
notes <- anki_notes()
cards <- anki_cards()
decks <- anki_decks()
models <- anki_models()
reviews <- anki_revlog()

# Specify profile or path
cards <- anki_cards(profile = "User 1")
cards <- anki_cards(path = "/path/to/collection.anki2")
```

## FSRS-6 Support

Extract memory state parameters from cards using FSRS:
```r
# Get cards with FSRS parameters
cards_fsrs <- anki_cards_fsrs()
# Returns: stability, difficulty, desired_retention, decay

# Calculate current retrievability (probability of recall)
r <- fsrs_retrievability(
  stability = 30,
  days_elapsed = 15,
  decay = 0.5
)

# Calculate optimal interval for target retention
interval <- fsrs_interval(stability = 30, desired_retention = 0.9)
```

## Example: Analyze Learning Progress
```r
library(ankiR)
library(dplyr)

# Reviews per day
anki_revlog() |>
  count(review_date) |>
  tail(30)

# Deck statistics
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
    avg_interval = mean(ivl[type == 2], na.rm = TRUE)
  )
```

## Platform Support

Automatically detects Anki on:
- **Windows**: `%APPDATA%\Anki2`
- **macOS**: `~/Library/Application Support/Anki2`
- **Linux**: `~/.local/share/Anki2`

## Related

- [r-fsrs](https://github.com/open-spaced-repetition/r-fsrs) - FSRS algorithm implementation in R
- [py-fsrs](https://github.com/open-spaced-repetition/py-fsrs) - Python FSRS implementation

## License

MIT
