# ankiR

[![R-CMD-check](https://github.com/chrislongros/ankiR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/chrislongros/ankiR/actions/workflows/R-CMD-check.yaml)

R package for reading Anki flashcard databases with FSRS parameter support.

## Installation
```r
# From GitHub
remotes::install_github("chrislongros/ankiR")

# Arch Linux (AUR)
# yay -S r-ankir
```

## Usage
```r
library(ankiR)

# Read collection
col <- anki_read("collection.anki2")

# Get cards, decks, reviews
cards <- anki_cards(col)
decks <- anki_decks(col)
reviews <- anki_reviews(col)

# Extract FSRS parameters
fsrs_params <- anki_fsrs_params(col)
```

## License

MIT © 2026
