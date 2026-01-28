#' Enhanced FSRS Simulation
#'
#' Improved simulation with Monte Carlo confidence intervals, learning steps,
#' and new card additions.
#'
#' @param path Path to collection.anki2 (auto-detected if NULL)
#' @param profile Profile name (first profile if NULL)
#' @param days Number of days to simulate (default 90)
#' @param new_cards_per_day New cards to add per day (default from deck config or 20)
#' @param learning_steps Learning steps in minutes (default c(1, 10))
#' @param graduating_interval Interval after graduating (default 1)
#' @param simulations Number of Monte Carlo simulations (default 100)
#' @param desired_retention Target retention (default from FSRS or 0.9)
#' @param deck_pattern Deck name pattern to filter (NULL for all)
#' @param include_ci Include confidence intervals
#' @return A tibble with simulation results
#' @export
#'
#' @examples
#' \dontrun{
#' sim <- fsrs_simulate_enhanced(days = 90, simulations = 50)
#' plot(sim$date, sim$reviews_mean, type = "l")
#' }
fsrs_simulate_enhanced <- function(path = NULL, profile = NULL,
                                   days = 90,
                                   new_cards_per_day = NULL,
                                   learning_steps = c(1, 10),
                                   graduating_interval = 1,
                                   simulations = 100,
                                   desired_retention = NULL,
                                   deck_pattern = NULL,
                                   include_ci = TRUE) {
  col <- anki_collection(path, profile)
  on.exit(col$close())
  
  # Get FSRS parameters
  params <- fsrs_get_parameters(path = col$path)
  if (is.null(desired_retention) && !is.null(params$desired_retention)) {
    desired_retention <- params$desired_retention
  }
  if (is.null(desired_retention)) desired_retention <- 0.9
  
  # Get current card state
  cards <- anki_cards_fsrs(path = col$path)
  decks <- col$decks()
  
  # Filter by deck if specified
  if (!is.null(deck_pattern)) {
    deck_ids <- decks$did[grepl(deck_pattern, decks$name, ignore.case = TRUE)]
    cards <- cards[cards$did %in% deck_ids, ]
  }
  
  # Default new cards per day
  if (is.null(new_cards_per_day)) {
    new_cards_per_day <- 20
  }
  
  # Get last review dates
  revlog <- col$revlog()
  last_reviews <- aggregate(review_date ~ cid, data = revlog, FUN = max)
  cards <- merge(cards, last_reviews, by = "cid", all.x = TRUE)
  
  # Calculate days until due
  today <- Sys.Date()
  cards$days_elapsed <- as.numeric(today - cards$review_date)
  cards$days_elapsed[is.na(cards$days_elapsed)] <- 0
  
  # Run Monte Carlo simulations
  all_results <- lapply(1:simulations, function(sim_i) {
    simulate_single_run(
      cards = cards,
      days = days,
      new_cards_per_day = new_cards_per_day,
      learning_steps = learning_steps,
      graduating_interval = graduating_interval,
      desired_retention = desired_retention,
      weights = params$weights
    )
  })
  
  # Aggregate results
  dates <- today + 0:(days - 1)
  
  # Extract daily values from each simulation
  extract_daily <- function(results, metric) {
    do.call(cbind, lapply(results, function(r) r[[metric]]))
  }
  
  reviews_matrix <- extract_daily(all_results, "reviews")
  new_matrix <- extract_daily(all_results, "new_learned")
  retention_matrix <- extract_daily(all_results, "retention")
  total_matrix <- extract_daily(all_results, "total_mature")
  
  # Calculate statistics
  result <- tibble::tibble(
    date = dates,
    day = 1:days,
    reviews_mean = rowMeans(reviews_matrix),
    reviews_median = apply(reviews_matrix, 1, median),
    new_learned = rowMeans(new_matrix),
    retention_mean = rowMeans(retention_matrix, na.rm = TRUE),
    total_mature_mean = rowMeans(total_matrix)
  )
  
  if (include_ci) {
    result$reviews_ci_low <- apply(reviews_matrix, 1, quantile, 0.05)
    result$reviews_ci_high <- apply(reviews_matrix, 1, quantile, 0.95)
    result$retention_ci_low <- apply(retention_matrix, 1, quantile, 0.05, na.rm = TRUE)
    result$retention_ci_high <- apply(retention_matrix, 1, quantile, 0.95, na.rm = TRUE)
  }
  
  # Add cumulative stats
  result$cumulative_reviews <- cumsum(result$reviews_mean)
  result$cumulative_new <- cumsum(result$new_learned)
  
  # Weekly aggregates
  result$week <- ceiling(result$day / 7)
  
  attr(result, "parameters") <- list(
    simulations = simulations,
    new_cards_per_day = new_cards_per_day,
    desired_retention = desired_retention,
    learning_steps = learning_steps
  )
  
  result
}

#' Single simulation run
#' @noRd
simulate_single_run <- function(cards, days, new_cards_per_day, 
                                 learning_steps, graduating_interval,
                                 desired_retention, weights) {
  # Initialize tracking vectors
  reviews <- numeric(days)
  new_learned <- numeric(days)
  retention <- numeric(days)
  total_mature <- numeric(days)
  
  # Card state: list with stability, difficulty, days_until_due
  card_states <- lapply(1:nrow(cards), function(i) {
    list(
      stability = ifelse(is.na(cards$stability[i]) || cards$stability[i] <= 0, 
                        1, cards$stability[i]),
      difficulty = ifelse(is.na(cards$difficulty[i]), 5, cards$difficulty[i]),
      days_until_due = max(0, cards$ivl[i] - cards$days_elapsed[i]),
      is_learning = cards$queue[i] %in% c(0, 1, 3),
      learning_step = 0
    )
  })
  
  # New cards queue
  new_cards_remaining <- sum(cards$queue == 0)
  
  for (day in 1:days) {
    daily_reviews <- 0
    daily_new <- 0
    daily_correct <- 0
    daily_total <- 0
    
    # Process existing cards
    for (i in seq_along(card_states)) {
      state <- card_states[[i]]
      
      if (state$days_until_due <= 0 && !state$is_learning) {
        # Card is due
        daily_reviews <- daily_reviews + 1
        
        # Simulate recall based on retrievability
        days_elapsed <- abs(state$days_until_due)
        r <- fsrs_retrievability(state$stability, days_elapsed)
        
        recalled <- runif(1) < r
        daily_total <- daily_total + 1
        
        if (recalled) {
          daily_correct <- daily_correct + 1
          # Update stability (simplified)
          state$stability <- state$stability * (1 + runif(1, 0.5, 1.5))
          state$days_until_due <- fsrs_interval(state$stability, desired_retention)
        } else {
          # Failed - reset
          state$stability <- max(1, state$stability * 0.3)
          state$days_until_due <- 1
        }
        
        card_states[[i]] <- state
      } else {
        state$days_until_due <- state$days_until_due - 1
        card_states[[i]] <- state
      }
    }
    
    # Add new cards
    cards_to_add <- min(new_cards_per_day, new_cards_remaining)
    if (cards_to_add > 0) {
      for (j in 1:cards_to_add) {
        daily_reviews <- daily_reviews + length(learning_steps)
        daily_new <- daily_new + 1
        
        # Simulate learning
        graduated <- runif(1) < 0.8  # 80% graduate
        if (graduated) {
          card_states <- c(card_states, list(list(
            stability = graduating_interval,
            difficulty = 5,
            days_until_due = graduating_interval,
            is_learning = FALSE,
            learning_step = 0
          )))
        }
      }
      new_cards_remaining <- new_cards_remaining - cards_to_add
    }
    
    # Record daily stats
    reviews[day] <- daily_reviews
    new_learned[day] <- daily_new
    retention[day] <- if (daily_total > 0) daily_correct / daily_total else NA
    total_mature[day] <- sum(sapply(card_states, function(s) !s$is_learning))
  }
  
  list(
    reviews = reviews,
    new_learned = new_learned,
    retention = retention,
    total_mature = total_mature
  )
}

#' Anki Schema Version Detection
#'
#' Detect the Anki database schema version to help debug compatibility issues.
#'
#' @param path Path to collection.anki2 (auto-detected if NULL)
#' @param profile Profile name (first profile if NULL)
#' @return A list with schema information
#' @export
#'
#' @examples
#' \dontrun{
#' schema <- anki_schema_version()
#' }
anki_schema_version <- function(path = NULL, profile = NULL) {
  col <- anki_collection(path, profile)
  on.exit(col$close())
  
  db <- col$db
  
  # Get schema version from col table
  schema_ver <- tryCatch({
    res <- DBI::dbGetQuery(db, "SELECT ver FROM col")
    res$ver[1]
  }, error = function(e) NA)
  
  # Check for FSRS data columns
  card_cols <- DBI::dbListFields(db, "cards")
  has_fsrs <- "data" %in% card_cols
  
  # Get table list
  tables <- DBI::dbListTables(db)
  
  # Check for revlog columns
  revlog_cols <- DBI::dbListFields(db, "revlog")
  
  # Get some stats
  col_data <- tryCatch({
    DBI::dbGetQuery(db, "SELECT crt, mod FROM col")
  }, error = function(e) NULL)
  
  created_date <- if (!is.null(col_data)) {
    as.POSIXct(col_data$crt[1], origin = "1970-01-01")
  } else NA
  
  modified_date <- if (!is.null(col_data)) {
    as.POSIXct(col_data$mod[1] / 1000, origin = "1970-01-01")
  } else NA
  
  # Detect Anki version features
  features <- list(
    fsrs = has_fsrs,
    deck_config_in_json = "dconf" %in% tables || schema_ver >= 11,
    media_db = file.exists(file.path(dirname(col$path), "media.db2")),
    new_scheduler = "originalDue" %in% revlog_cols || schema_ver >= 18
  )
  
  # Determine approximate Anki version
  anki_version <- if (schema_ver >= 18) {
    "Anki 23.10+ (v3 scheduler, FSRS support)"
  } else if (schema_ver >= 15) {
    "Anki 2.1.45+ (v3 scheduler)"
  } else if (schema_ver >= 11) {
    "Anki 2.1.x"
  } else {
    "Legacy Anki"
  }
  
  list(
    schema_version = schema_ver,
    estimated_anki_version = anki_version,
    collection_created = created_date,
    collection_modified = modified_date,
    tables = tables,
    card_columns = card_cols,
    revlog_columns = revlog_cols,
    features = features,
    path = col$path
  )
}

#' Quick Collection Summary
#'
#' Get a one-liner overview of your Anki collection.
#'
#' @param path Path to collection.anki2 (auto-detected if NULL)
#' @param profile Profile name (first profile if NULL)
#' @param print Whether to print the summary (default TRUE)
#' @return Invisibly returns a list with summary stats
#' @export
#'
#' @examples
#' \dontrun{
#' anki_quick_summary()
#' }
anki_quick_summary <- function(path = NULL, profile = NULL, print = TRUE) {
  col <- anki_collection(path, profile)
  on.exit(col$close())
  
  cards <- col$cards()
  notes <- col$notes()
  revlog <- col$revlog()
  
  # Basic counts
  total_cards <- nrow(cards)
  total_notes <- nrow(notes)
  mature <- sum(cards$ivl >= 21)
  young <- sum(cards$queue == 2 & cards$ivl < 21)
  new_cards <- sum(cards$queue == 0)
  suspended <- sum(cards$queue == -1)
  
  # Due today
  today <- as.numeric(Sys.Date() - as.Date("1970-01-01"))
  due_today <- sum(cards$queue == 2 & cards$due <= today)
  
  # Reviews today
  today_revs <- revlog[revlog$review_date == Sys.Date(), ]
  reviews_today <- nrow(today_revs)
  
  # Streak
  streak <- anki_streak(path = col$path)
  
  # 7-day retention
  week_ago <- Sys.Date() - 7
  recent_revs <- revlog[revlog$review_date >= week_ago & revlog$type == 1, ]
  retention_7d <- if (nrow(recent_revs) > 0) {
    round(sum(recent_revs$ease > 1) / nrow(recent_revs) * 100, 1)
  } else NA
  
  result <- list(
    total_cards = total_cards,
    total_notes = total_notes,
    mature = mature,
    young = young,
    new_cards = new_cards,
    suspended = suspended,
    due_today = due_today,
    reviews_today = reviews_today,
    current_streak = streak$current,
    retention_7d = retention_7d
  )
  
  if (print) {
    cat(sprintf(
      "Anki: %d cards (%d mature, %d young, %d new) | Due today: %d | Reviews today: %d | Streak: %d days | 7d retention: %s%%\n",
      total_cards, mature, young, new_cards, due_today, reviews_today,
      streak$current, ifelse(is.na(retention_7d), "N/A", retention_7d)
    ))
  }
  
  invisible(result)
}

#' Today's Activity Summary
#'
#' Detailed breakdown of today's Anki activity.
#'
#' @param path Path to collection.anki2 (auto-detected if NULL)
#' @param profile Profile name (first profile if NULL)
#' @return A list with today's activity breakdown
#' @export
#'
#' @examples
#' \dontrun{
#' anki_today()
#' }
anki_today <- function(path = NULL, profile = NULL) {
  col <- anki_collection(path, profile)
  on.exit(col$close())
  
  revlog <- col$revlog()
  cards <- col$cards()
  
  # Filter to today
  today <- Sys.Date()
  today_revs <- revlog[revlog$review_date == today, ]
  
  if (nrow(today_revs) == 0) {
    return(list(
      date = today,
      total_reviews = 0,
      message = "No reviews yet today"
    ))
  }
  
  # Breakdown by ease
  ease_breakdown <- table(factor(today_revs$ease, levels = 1:4))
  names(ease_breakdown) <- c("Again", "Hard", "Good", "Easy")
  
  # Breakdown by type
  type_breakdown <- table(factor(today_revs$type, levels = 0:3))
  names(type_breakdown) <- c("Learning", "Review", "Relearn", "Filtered")
  
  # Time spent
  time_spent_sec <- sum(today_revs$time) / 1000
  time_spent_min <- time_spent_sec / 60
  
  # Unique cards
  unique_cards <- length(unique(today_revs$cid))
  
  # Retention
  review_revs <- today_revs[today_revs$type == 1, ]
  retention <- if (nrow(review_revs) > 0) {
    round(sum(review_revs$ease > 1) / nrow(review_revs) * 100, 1)
  } else NA
  
  # Average time per card
  avg_time <- mean(today_revs$time) / 1000
  
  # Due remaining
  today_num <- as.numeric(today - as.Date("1970-01-01"))
  due_remaining <- sum(cards$queue == 2 & cards$due <= today_num) - 
    length(unique(today_revs$cid[today_revs$type == 1]))
  due_remaining <- max(0, due_remaining)
  
  list(
    date = today,
    total_reviews = nrow(today_revs),
    unique_cards = unique_cards,
    time_spent_minutes = round(time_spent_min, 1),
    avg_time_seconds = round(avg_time, 1),
    ease_breakdown = as.list(ease_breakdown),
    type_breakdown = as.list(type_breakdown),
    retention = retention,
    due_remaining = due_remaining,
    again_rate = round(ease_breakdown["Again"] / nrow(today_revs) * 100, 1),
    easy_rate = round(ease_breakdown["Easy"] / nrow(today_revs) * 100, 1)
  )
}

#' Collection Caching
#'
#' Enable or manage caching for expensive collection operations.
#'
#' @param col An anki_collection object or path
#' @param enable Whether to enable caching (default TRUE)
#' @param cache_dir Directory for cache files (default tempdir())
#' @return Invisibly returns the cache status
#' @export
#'
#' @details
#' Caching stores expensive join results (cards+notes+decks) for faster
#' subsequent access. Cache is invalidated when collection is modified.
#'
#' @examples
#' \dontrun{
#' anki_cache_enable()
#' # Subsequent calls will be faster
#' cards <- anki_cards_full()
#' }
anki_cache_enable <- function(col = NULL, enable = TRUE, cache_dir = tempdir()) {
  # Store in package environment
  if (!exists(".ankiR_cache", envir = .GlobalEnv)) {
    assign(".ankiR_cache", new.env(), envir = .GlobalEnv)
  }
  
  cache_env <- get(".ankiR_cache", envir = .GlobalEnv)
  cache_env$enabled <- enable
  cache_env$dir <- cache_dir
  cache_env$data <- list()
  cache_env$timestamps <- list()
  
  if (enable) {
    message("ankiR caching enabled. Cache directory: ", cache_dir)
  } else {
    message("ankiR caching disabled")
  }
  
  invisible(list(enabled = enable, dir = cache_dir))
}

#' Check if cache is valid
#' @noRd
cache_is_valid <- function(path, key) {
  if (!exists(".ankiR_cache", envir = .GlobalEnv)) return(FALSE)
  
  cache_env <- get(".ankiR_cache", envir = .GlobalEnv)
  if (!cache_env$enabled) return(FALSE)
  
  cache_key <- paste0(path, "_", key)
  
  if (!cache_key %in% names(cache_env$data)) return(FALSE)
  
  # Check if collection was modified
  col_mtime <- file.mtime(path)
  cached_mtime <- cache_env$timestamps[[cache_key]]
  
  !is.null(cached_mtime) && col_mtime <= cached_mtime
}

#' Get cached data
#' @noRd
cache_get <- function(path, key) {
  if (!cache_is_valid(path, key)) return(NULL)
  
  cache_env <- get(".ankiR_cache", envir = .GlobalEnv)
  cache_key <- paste0(path, "_", key)
  cache_env$data[[cache_key]]
}

#' Set cached data
#' @noRd
cache_set <- function(path, key, data) {
  if (!exists(".ankiR_cache", envir = .GlobalEnv)) return(invisible(NULL))
  
  cache_env <- get(".ankiR_cache", envir = .GlobalEnv)
  if (!cache_env$enabled) return(invisible(NULL))
  
  cache_key <- paste0(path, "_", key)
  cache_env$data[[cache_key]] <- data
  cache_env$timestamps[[cache_key]] <- Sys.time()
  
  invisible(NULL)
}

#' Clear cache
#'
#' Clear the ankiR cache.
#'
#' @param path If provided, only clear cache for this collection path
#' @return Invisibly returns TRUE
#' @export
anki_cache_clear <- function(path = NULL) {
  if (!exists(".ankiR_cache", envir = .GlobalEnv)) {
    return(invisible(TRUE))
  }
  
  cache_env <- get(".ankiR_cache", envir = .GlobalEnv)
  
  if (is.null(path)) {
    cache_env$data <- list()
    cache_env$timestamps <- list()
    message("Cache cleared")
  } else {
    # Clear only matching path
    keys <- names(cache_env$data)
    matching <- grep(paste0("^", path), keys)
    if (length(matching) > 0) {
      cache_env$data[keys[matching]] <- NULL
      cache_env$timestamps[keys[matching]] <- NULL
    }
  }
  
  invisible(TRUE)
}
