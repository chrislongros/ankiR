#' Estimate time to mastery for a deck
#'
#' Predicts when a deck will reach a target maturity level.
#'
#' @param path Path to collection.anki2 (auto-detected if NULL)
#' @param profile Profile name (first profile if NULL)
#' @param deck Deck name (NULL for all)
#' @param target_mature_pct Target percentage of mature cards (default 90)
#' @param new_cards_per_day Assumed new cards per day (default 20)
#' @return A tibble with mastery predictions
#' @export
#' @examples
#' \dontrun{
#' fsrs_time_to_mastery()
#' fsrs_time_to_mastery(deck = "Medical", target_mature_pct = 95)
#' }
fsrs_time_to_mastery <- function(path = NULL, profile = NULL, deck = NULL,
                                 target_mature_pct = 90, new_cards_per_day = 20) {
  col <- anki_collection(path, profile)
  on.exit(col$close())
 
  cards <- col$cards()
  decks <- col$decks()
 
  if (!is.null(deck)) {
    deck_ids <- decks$did[grepl(deck, decks$name, ignore.case = TRUE)]
    cards <- cards[cards$did %in% deck_ids, ]
  }
 
  if (nrow(cards) == 0) {
    message("No cards found")
    return(tibble::tibble())
  }
 
  # Current state
  total_cards <- nrow(cards)
  new_cards <- sum(cards$type == 0)
  learning_cards <- sum(cards$type == 1 | cards$type == 3)
  review_cards <- sum(cards$type == 2)
  mature_cards <- sum(cards$ivl >= 21)
 
  current_mature_pct <- mature_cards / total_cards * 100
 
  if (current_mature_pct >= target_mature_pct) {
    return(tibble::tibble(
      status = "Already at target",
      current_mature_pct = round(current_mature_pct, 1),
      target_mature_pct = target_mature_pct,
      days_to_target = 0
    ))
  }
 
  # Estimate time to mature (simplified model)
  # Assume: new cards take ~30 days to mature on average with good retention
  avg_days_to_mature <- 30
 
  # Cards that need to mature
  cards_to_mature <- ceiling(total_cards * target_mature_pct / 100) - mature_cards
 
  # Time to introduce all new cards
  days_to_introduce <- ceiling(new_cards / new_cards_per_day)
 
  # Time for last introduced cards to mature
  days_for_maturing <- avg_days_to_mature
 
  # Also consider young cards
  young_cards <- sum(cards$type == 2 & cards$ivl < 21)
  avg_days_remaining <- mean(21 - cards$ivl[cards$type == 2 & cards$ivl < 21 & cards$ivl > 0])
  if (is.na(avg_days_remaining)) avg_days_remaining <- 15
 
  estimated_days <- max(days_to_introduce + days_for_maturing,
                        round(avg_days_remaining))
 
  tibble::tibble(
    total_cards = total_cards,
    current_mature = mature_cards,
    current_mature_pct = round(current_mature_pct, 1),
    target_mature_pct = target_mature_pct,
    cards_to_mature = cards_to_mature,
    new_cards_remaining = new_cards,
    days_to_introduce = days_to_introduce,
    estimated_days_to_target = estimated_days,
    estimated_date = Sys.Date() + estimated_days
  )
}

#' Calculate forgetting index
#'
#' Estimates the percentage of cards currently below target retention.
#'
#' @param path Path to collection.anki2 (auto-detected if NULL)
#' @param profile Profile name (first profile if NULL)
#' @param target_retention Target retention (default 0.9)
#' @return A list with forgetting analysis
#' @export
#' @examples
#' \dontrun{
#' fsrs_forgetting_index()
#' }
fsrs_forgetting_index <- function(path = NULL, profile = NULL, target_retention = 0.9) {
  cards <- fsrs_current_retrievability(path, profile)
 
  if (nrow(cards) == 0 || all(is.na(cards$retrievability))) {
    message("No FSRS data available")
    return(list(forgetting_index = NA))
  }
 
  cards <- cards[!is.na(cards$retrievability), ]
 
  # Calculate forgetting index
  below_target <- sum(cards$retrievability < target_retention)
  total <- nrow(cards)
  forgetting_index <- below_target / total * 100
 
  # Distribution
  dist <- list(
    below_70 = sum(cards$retrievability < 0.7) / total * 100,
    r70_80 = sum(cards$retrievability >= 0.7 & cards$retrievability < 0.8) / total * 100,
    r80_90 = sum(cards$retrievability >= 0.8 & cards$retrievability < 0.9) / total * 100,
    above_90 = sum(cards$retrievability >= 0.9) / total * 100
  )
 
  # Urgency analysis
  urgent_cards <- cards[cards$retrievability < 0.7, ]
 
  list(
    forgetting_index = round(forgetting_index, 1),
    target_retention = target_retention,
    cards_analyzed = total,
    cards_below_target = below_target,
    distribution = tibble::tibble(
      range = c("< 70%", "70-80%", "80-90%", "> 90%"),
      percentage = round(c(dist$below_70, dist$r70_80, dist$r80_90, dist$above_90), 1)
    ),
    avg_retrievability = round(mean(cards$retrievability), 3),
    min_retrievability = round(min(cards$retrievability), 3),
    urgent_cards_count = nrow(urgent_cards)
  )
}

#' Estimate long-term review burden
#'
#' Predicts daily review workload in the long term based on current collection.
#'
#' @param path Path to collection.anki2 (auto-detected if NULL)
#' @param profile Profile name (first profile if NULL)
#' @param desired_retention Target retention (default 0.9)
#' @return A list with workload predictions
#' @export
#' @examples
#' \dontrun{
#' fsrs_review_burden()
#' }
fsrs_review_burden <- function(path = NULL, profile = NULL, desired_retention = 0.9) {
  col <- anki_collection(path, profile)
  on.exit(col$close())
 
  cards <- col$cards()
  cards_fsrs <- anki_cards_fsrs(path = col$path)
  revlog <- col$revlog()
 
  # Current collection stats
  total_cards <- nrow(cards)
  review_cards <- sum(cards$type == 2)
  new_cards <- sum(cards$type == 0)
 
  # Get average stability
  cards_fsrs <- cards_fsrs[!is.na(cards_fsrs$stability) & cards_fsrs$stability > 0, ]
  avg_stability <- if (nrow(cards_fsrs) > 0) mean(cards_fsrs$stability) else 30
  avg_decay <- if (nrow(cards_fsrs) > 0 && any(!is.na(cards_fsrs$decay))) {
    mean(cards_fsrs$decay, na.rm = TRUE)
  } else {
    0.5
  }
 
  # Calculate average interval at target retention
  avg_interval <- fsrs_interval(avg_stability, desired_retention, avg_decay)
 
  # Steady-state review burden (reviews per day)
  # At equilibrium: each card reviewed once per interval on average
  steady_state_reviews <- review_cards / avg_interval
 
  # Historical average for comparison
  recent_reviews <- revlog[revlog$review_date >= Sys.Date() - 30, ]
  current_avg <- nrow(recent_reviews) / 30
 
  # Time spent
  avg_time_per_review <- mean(revlog$time, na.rm = TRUE) / 1000  # seconds
 
  list(
    current_state = tibble::tibble(
      metric = c("Total Cards", "Review Cards", "New Cards", "Avg Stability (days)",
                 "Avg Interval at Target", "Current Daily Reviews (30d avg)"),
      value = c(total_cards, review_cards, new_cards, round(avg_stability, 1),
                round(avg_interval, 1), round(current_avg, 1))
    ),
    predictions = tibble::tibble(
      scenario = c("Current Collection", "If All Cards Mature", "With 1000 More Cards"),
      daily_reviews = c(
        round(steady_state_reviews, 1),
        round(total_cards / avg_interval, 1),
        round((total_cards + 1000) / avg_interval, 1)
      ),
      daily_time_min = c(
        round(steady_state_reviews * avg_time_per_review / 60, 1),
        round(total_cards / avg_interval * avg_time_per_review / 60, 1),
        round((total_cards + 1000) / avg_interval * avg_time_per_review / 60, 1)
      )
    ),
    parameters = list(
      desired_retention = desired_retention,
      avg_stability = round(avg_stability, 1),
      avg_decay = round(avg_decay, 3),
      avg_interval = round(avg_interval, 1),
      avg_time_per_review_sec = round(avg_time_per_review, 1)
    )
  )
}

#' Predict optimal new card rate
#'
#' Calculates the sustainable new card rate based on desired workload.
#'
#' @param path Path to collection.anki2 (auto-detected if NULL)
#' @param profile Profile name (first profile if NULL)
#' @param max_daily_reviews Maximum desired daily reviews
#' @param desired_retention Target retention
#' @return A tibble with new card rate recommendations
#' @export
#' @examples
#' \dontrun{
#' fsrs_optimal_new_rate(max_daily_reviews = 100)
#' }
fsrs_optimal_new_rate <- function(path = NULL, profile = NULL,
                                  max_daily_reviews = 100, desired_retention = 0.9) {
  burden <- fsrs_review_burden(path, profile, desired_retention)
 
  avg_interval <- burden$parameters$avg_interval
  current_reviews <- burden$current_state$value[6]
 
  # At steady state, new cards become reviews
  # Each new card adds 1/interval reviews per day in steady state
  reviews_per_new_card <- 1 / avg_interval
 
  # Available capacity
  available_reviews <- max_daily_reviews - current_reviews
 
  if (available_reviews <= 0) {
    sustainable_new <- 0
    message("Already at or above max daily reviews")
  } else {
    # But new cards also need learning reviews (~5 reviews in first week)
    learning_factor <- 5 / 7  # Learning reviews per new card per day
    effective_cost <- reviews_per_new_card + learning_factor
   
    sustainable_new <- floor(available_reviews / effective_cost)
  }
 
  tibble::tibble(
    scenario = c("Conservative", "Moderate", "Aggressive"),
    new_cards_per_day = c(
      floor(sustainable_new * 0.5),
      sustainable_new,
      floor(sustainable_new * 1.5)
    ),
    projected_daily_reviews = c(
      round(current_reviews + floor(sustainable_new * 0.5) * (reviews_per_new_card + 0.7), 1),
      round(current_reviews + sustainable_new * (reviews_per_new_card + 0.7), 1),
      round(current_reviews + floor(sustainable_new * 1.5) * (reviews_per_new_card + 0.7), 1)
    ),
    notes = c(
      "Comfortable, leaves room for variation",
      "Balanced approach",
      "May exceed target on some days"
    )
  )
}

#' Simulate learning a new deck
#'
#' Projects workload when adding a new deck of cards.
#'
#' @param new_cards Number of new cards to add
#' @param new_cards_per_day Daily new card limit
#' @param path Path to collection.anki2 (auto-detected if NULL)
#' @param profile Profile name (first profile if NULL)
#' @param days Number of days to simulate
#' @return A tibble with daily projections
#' @export
#' @examples
#' \dontrun{
#' sim <- fsrs_simulate_new_deck(new_cards = 500, new_cards_per_day = 20)
#' }
fsrs_simulate_new_deck <- function(new_cards, new_cards_per_day = 20,
                                   path = NULL, profile = NULL, days = 90) {
  # Get current baseline
  if (!is.null(path) || !is.null(profile)) {
    daily <- anki_stats_daily(path, profile, from = Sys.Date() - 30)
    baseline_reviews <- if (nrow(daily) > 0) mean(daily$reviews) else 0
  } else {
    baseline_reviews <- 0
  }
 
  # Simplified simulation
  # Learning phase: ~5 reviews per new card in first week
  # Graduation: cards become review cards
  # Review phase: interval depends on retention (use avg ~14 days early, grows)
 
  results <- tibble::tibble(
    day = 1:days,
    new_introduced = pmin(cumsum(rep(new_cards_per_day, days)), new_cards),
    learning_reviews = 0,
    review_reviews = 0,
    total_new_reviews = 0
  )
 
  learning_queue <- rep(0, 7)  # 7-day learning queue
  review_queue <- numeric(days)
 
  for (d in 1:days) {
    # Introduce new cards
    new_today <- if (results$new_introduced[d] > (if (d > 1) results$new_introduced[d-1] else 0)) {
      new_cards_per_day
    } else {
      0
    }
   
    # Learning reviews (cards seen in last 7 days)
    learning_reviews <- sum(learning_queue) * 0.7  # ~70% come back each day
   
    # Update learning queue
    learning_queue <- c(new_today, learning_queue[1:6])
   
    # Cards graduate after ~7 days
    graduating <- learning_queue[7]
   
    # Review cards (simplified: average interval 14 days early, 30 days later)
    avg_interval <- if (d < 30) 14 else 21
    review_reviews <- sum(review_queue[max(1, d - avg_interval):d] / avg_interval)
   
    # Add graduating cards to review pool
    review_queue[d] <- graduating
   
    results$learning_reviews[d] <- round(learning_reviews)
    results$review_reviews[d] <- round(review_reviews)
    results$total_new_reviews[d] <- round(learning_reviews + review_reviews)
  }
 
  results$baseline_reviews <- round(baseline_reviews)
  results$total_reviews <- results$baseline_reviews + results$total_new_reviews
  results$date <- Sys.Date() + results$day - 1
 
  tibble::as_tibble(results[, c("date", "day", "new_introduced", "learning_reviews",
                                "review_reviews", "total_new_reviews", "baseline_reviews",
                                "total_reviews")])
}
