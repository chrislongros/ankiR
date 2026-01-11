# ankiR

R package for reading Anki flashcard databases.

## Installation
```r
# Install from GitHub
remotes::install_github("clongros/ankiR")
```

## Usage
```r
library(ankiR)

# List profiles
anki_profiles()

# Quick access
notes <- anki_notes()
cards <- anki_cards()
reviews <- anki_revlog()

# Or use collection object
col <- anki_collection()
col$notes()
col$cards()
col$revlog()
col$close()
```
