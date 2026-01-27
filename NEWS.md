# ankiR 0.5.0

## New Features

### Visualization Functions
* `anki_plot_heatmap()` - Calendar heatmap of review activity
* `anki_plot_retention()` - Retention rate over time with rolling average
* `anki_plot_forecast()` - Workload forecast chart
* `anki_plot_difficulty()` - FSRS difficulty distribution histogram
* `anki_plot_intervals()` - Card interval distribution
* `anki_plot_stability()` - FSRS stability distribution
* `anki_plot_hours()` - Reviews by hour of day
* `anki_plot_weekdays()` - Reviews by day of week

### Comparative Analysis
* `anki_compare_decks()` - Side-by-side deck statistics
* `anki_compare_periods()` - Compare two time periods
* `anki_compare_by_age()` - Retention by card age
* `anki_compare_deck_difficulty()` - Rank decks by difficulty
* `anki_benchmark()` - Compare your stats to FSRS averages

### Time Analysis
* `anki_time_by_hour()` - Detailed hourly statistics
* `anki_time_by_weekday()` - Statistics by day of week
* `anki_session_stats()` - Study session analysis
* `anki_response_time()` - Response time by difficulty/interval
* `anki_monthly_summary()` - Monthly statistics
* `anki_consistency()` - Study consistency metrics

### Card Quality Analysis
* `anki_card_complexity()` - Measure card complexity
* `anki_similar_cards()` - Find potential duplicates
* `anki_tag_analysis()` - Tag usage and retention by tag
* `anki_empty_cards()` - Find cards with empty fields
* `anki_long_cards()` - Find overly long cards
* `anki_quality_report()` - Comprehensive quality assessment

### Predictive Features
* `fsrs_time_to_mastery()` - Estimate when deck will be learned
* `fsrs_forgetting_index()` - Percentage of cards below target retention
* `fsrs_review_burden()` - Long-term daily review workload estimate
* `fsrs_optimal_new_rate()` - Sustainable new card rate recommendation
* `fsrs_simulate_new_deck()` - Project workload when adding cards

### Interactive Dashboard
* `anki_dashboard()` - Launch Shiny dashboard with all analytics

### Export Formats
* `anki_to_org()` - Export to Emacs Org-mode (org-drill)
* `anki_to_markdown()` - Export to Markdown (Obsidian/Logseq/basic)
* `anki_to_supermemo()` - Export to SuperMemo Q&A format
* `fsrs_from_csv()` - Import review data from other sources
* `anki_export_importable()` - Export to Anki-importable format

# ankiR 0.4.0

## Features

### Analytics & Statistics
* `anki_cards_full()` - Cards joined with notes, decks, models
* `anki_tags()` - Unique tags with counts
* `anki_field_contents()` - Parse note fields into columns
* `anki_stats_deck()` - Per-deck statistics
* `anki_stats_daily()` - Daily review stats
* `anki_retention_rate()` - Actual retention from history
* `anki_learning_curve()` - Card progression over time
* `anki_heatmap_data()` - Calendar heatmap data
* `anki_streak()` - Current/longest streaks

### Search & Filter
* `anki_search()` - Anki-like search syntax
* `anki_suspended()`, `anki_buried()`, `anki_leeches()`
* `anki_due()`, `anki_new()`, `anki_mature()`

### Media Management
* `anki_media_list()`, `anki_media_unused()`, `anki_media_missing()`
* `anki_media_path()`, `anki_media_stats()`

### FSRS Advanced
* `fsrs_difficulty_distribution()`, `fsrs_stability_distribution()`
* `fsrs_current_retrievability()`, `fsrs_simulate()`
* `fsrs_workload_estimate()`, `fsrs_prepare_for_optimizer()`
* `fsrs_get_parameters()`

### Export
* `anki_to_csv()`, `anki_report()`, `anki_export_revlog()`, `anki_forecast()`

# ankiR 0.3.0

* `anki_decks()`, `anki_models()`, `fsrs_interval()`, `date_to_anki_timestamp()`
* FSRS-6 per-card decay parameter support
* Comprehensive test suite

# ankiR 0.2.0

* FSRS parameter support via `anki_cards_fsrs()`
* `fsrs_retrievability()` function

# ankiR 0.1.0

* Initial release with core functions

### Time Series Analysis (11 functions) - timeseries.R
* `anki_ts_intervals()` - Track interval progression over time
* `anki_ts_retention()` - Track retention rate changes
* `anki_ts_stability()` - FSRS stability trends
* `anki_ts_workload()` - Workload trends over time
* `anki_ts_learning()` - New cards learned per period
* `anki_ts_maturation()` - Card maturation tracking
* `anki_ts_decompose()` - Decompose into trend/seasonal/residual
* `anki_ts_anomalies()` - Detect unusual study days
* `anki_ts_forecast()` - Forecast future reviews
* `anki_ts_autocorrelation()` - Find cyclical patterns
* `anki_ts_plot()` - Plot any time series with trend
