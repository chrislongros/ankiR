cat > README.md << 'EOF'
# ankiR

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

# List profiles
anki_profiles()

# Read data
notes <- anki_notes()
cards <- anki_cards()
reviews <- anki_revlog()

# FSRS parameters (stability, difficulty, retrievability)
fsrs_cards <- anki_cards_fsrs()

# Calculate retrievability after N days
fsrs_retrievability(stability = 30, days_since_review = 7)
```

## FSRS Support

`anki_cards_fsrs()` returns cards with FSRS parameters:

- `stability` - memory stability in days
- `difficulty` - card difficulty (1-10)
- `retention` - desired retention rate
- `decay` - decay parameter
```r
library(dplyr)
library(ggplot2)

anki_cards_fsrs() |>
  filter(!is.na(stability)) |>
  ggplot(aes(difficulty, stability)) +
  geom_point(alpha = 0.3) +
  scale_y_log10() +
  labs(title = "Stability vs Difficulty")
```

## License

MIT
