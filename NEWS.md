# ankiR 0.4.0

## New Features

### Analytics & Statistics
* `anki_cards_full()` - Cards joined with notes, decks, and models
* `anki_tags()` - Extract unique tags with counts
* `anki_field_contents()` - Parse note fields into separate columns
* `anki_stats_deck()` - Per-deck statistics (maturity, retention, lapses)
* `anki_stats_daily()` - Daily review counts, time spent, retention
* `anki_retention_rate()` - Calculate actual retention from review history
* `anki_learning_curve()` - Track card progression over time
* `anki_heatmap_data()` - Data formatted for calendar heatmaps
* `anki_streak()` - Current and longest review streaks

### Search & Filter
* `anki_search()` - Search cards with Anki-like syntax (deck:, tag:, is:, prop:)
* `anki_suspended()` - Get suspended cards
* `anki_buried()` - Get buried cards
* `anki_leeches()` - Find cards with high lapse counts
* `anki_due()` - Get cards due for review
* `anki_new()` - Get new (unreviewed) cards
* `anki_mature()` - Get mature cards (interval >= 21 days)

### Media Management
* `anki_media_list()` - List all media files
* `anki_media_unused()` - Find unused media files
* `anki_media_missing()` - Find missing media references
* `anki_media_path()` - Get media folder path
* `anki_media_stats()` - Media statistics by file type

### FSRS Enhancements
* `fsrs_difficulty_distribution()` - Analyze difficulty across cards/decks
* `fsrs_stability_distribution()` - Analyze stability distribution
* `fsrs_current_retrievability()` - Calculate current recall probability for all cards
* `fsrs_simulate()` - Predict future review workload
* `fsrs_workload_estimate()` - Compare workload at different retention targets
* `fsrs_prepare_for_optimizer()` - Export data for r-fsrs optimization
* `fsrs_get_parameters()` - Extract FSRS parameters from deck config

### Export & Reporting
* `anki_to_csv()` - Export deck to CSV
* `anki_report()` - Generate collection summary report
* `anki_export_revlog()` - Export review history
* `anki_forecast()` - Predict upcoming reviews

# ankiR 0.3.0

## New Features

* Added `anki_decks()` function to read deck information
* Added `anki_models()` function to read note types (models)
* Added `fsrs_interval()` function to calculate optimal review intervals
* Added `date_to_anki_timestamp()` utility function
* FSRS functions now support FSRS-6 per-card decay parameter (w20)
* `anki_collection()` now includes `$decks()` and `$models()` methods
* Support for both legacy (col table JSON) and new (separate tables) Anki schema

## Improvements

* Input validation with informative error messages
* Better XDG_DATA_HOME support on Linux
* Use `vapply()` for type safety
* Comprehensive test suite

# ankiR 0.2.0

* Added FSRS parameter support via `anki_cards_fsrs()`
* Added `fsrs_retrievability()` function

# ankiR 0.1.0

* Initial release
* Core functions: `anki_collection()`, `anki_notes()`, `anki_cards()`, `anki_revlog()`
* Path utilities: `anki_base_path()`, `anki_profiles()`, `anki_db_path()`
