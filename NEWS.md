# ankiR 0.3.0

## New Features

* Added `anki_decks()` function to read deck information
* Added `anki_models()` function to read note types (models) with field and template names
* Added `fsrs_interval()` function to calculate optimal review intervals
* Added `date_to_anki_timestamp()` utility function
* FSRS functions now support FSRS-6 per-card decay parameter (w20)
* `anki_collection()` now includes `$decks()` and `$models()` methods
* Support for both legacy (col table JSON) and new (separate tables) Anki schema

## Improvements

* Input validation: `anki_collection()` now checks if database file exists and warns about unexpected extensions
* `anki_profiles()` now gives informative errors when Anki directory or profiles are not found
* Better XDG_DATA_HOME support on Linux
* Improved documentation with more examples
* Changed default FSRS decay from 0.256 to 0.5 (FSRS-4.5/5 default)
* Use `vapply()` instead of `sapply()` for type-safe operations

## Documentation

* Added comprehensive vignette "Getting Started with ankiR"
* README now accurately reflects the actual API
* Added more examples to function documentation

# ankiR 0.2.0

* Added FSRS parameter support via `anki_cards_fsrs()`
* Added `fsrs_retrievability()` function to calculate probability of recall
* Initial CRAN submission

# ankiR 0.1.0

* Initial release
* Core functions: `anki_collection()`, `anki_notes()`, `anki_cards()`, `anki_revlog()`
* Path utilities: `anki_base_path()`, `anki_profiles()`, `anki_db_path()`
* Timestamp conversion utilities
