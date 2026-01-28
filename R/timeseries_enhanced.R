#' Enhanced Time Series Forecasting
#'
#' Improved forecasting with ARIMA, seasonal patterns, and workload ceilings.
#'
#' @param path Path to collection.anki2 (auto-detected if NULL)
#' @param profile Profile name (first profile if NULL)
#' @param metric Metric to forecast: "reviews", "time", "retention", "cards_learned"
#' @param days_ahead Number of days to forecast (default 30)
#' @param method Forecasting method: "auto", "arima", "ets", "holt", "seasonal"
#' @param confidence Confidence level for prediction intervals (default 0.95)
#' @param workload_ceiling Maximum daily workload (NULL for none)
#' @return A tibble with forecast results
#' @export
#'
#' @examples
#' \dontrun{
#' fc <- anki_forecast_enhanced("reviews", days_ahead = 30)
#' plot(fc$date, fc$forecast, type = "l")
#' }
anki_forecast_enhanced <- function(path = NULL, profile = NULL,
                                   metric = "reviews",
                                   days_ahead = 30,
                                   method = "auto",
                                   confidence = 0.95,
                                   workload_ceiling = NULL) {
  col <- anki_collection(path, profile)
  on.exit(col$close())
  
  # Get historical data
  daily <- anki_stats_daily(path = col$path)
  
  if (nrow(daily) < 14) {
    stop("Need at least 14 days of data for forecasting")
  }
  
  # Select metric
  y <- switch(metric,
    "reviews" = daily$reviews,
    "time" = daily$time_minutes,
    "retention" = daily$retention,
    "cards_learned" = daily$learned,
    daily$reviews
  )
  
  dates <- daily$date
  
  # Remove missing values
  valid <- !is.na(y)
  y <- y[valid]
  dates <- dates[valid]
  
  if (length(y) < 14) {
    stop("Insufficient non-NA data points")
  }
  
  # Detect weekly seasonality
  has_weekly_pattern <- detect_weekly_pattern(y)
  
  # Choose method
  if (method == "auto") {
    method <- if (has_weekly_pattern && length(y) >= 21) "seasonal" else "holt"
  }
  
  # Fit model and forecast
  forecast_result <- switch(method,
    "arima" = forecast_arima(y, days_ahead, confidence),
    "ets" = forecast_ets(y, days_ahead, confidence),
    "holt" = forecast_holt(y, days_ahead, confidence),
    "seasonal" = forecast_seasonal(y, days_ahead, confidence),
    forecast_holt(y, days_ahead, confidence)
  )
  
  # Create future dates
  last_date <- max(dates)
  future_dates <- seq(last_date + 1, by = "day", length.out = days_ahead)
  
  # Apply workload ceiling
  if (!is.null(workload_ceiling)) {
    forecast_result$forecast <- pmin(forecast_result$forecast, workload_ceiling)
    forecast_result$upper <- pmin(forecast_result$upper, workload_ceiling)
  }
  
  # Combine historical and forecast
  historical <- tibble::tibble(
    date = dates,
    actual = y,
    forecast = NA_real_,
    lower = NA_real_,
    upper = NA_real_,
    type = "historical"
  )
  
  forecast_df <- tibble::tibble(
    date = future_dates,
    actual = NA_real_,
    forecast = forecast_result$forecast,
    lower = forecast_result$lower,
    upper = forecast_result$upper,
    type = "forecast"
  )
  
  result <- rbind(historical, forecast_df)
  
  # Add metadata
  attr(result, "method") <- method
  attr(result, "metric") <- metric
  attr(result, "confidence") <- confidence
  attr(result, "has_weekly_pattern") <- has_weekly_pattern
  
  # Add summary statistics
  attr(result, "summary") <- list(
    historical_mean = mean(y, na.rm = TRUE),
    historical_sd = sd(y, na.rm = TRUE),
    forecast_mean = mean(forecast_result$forecast),
    forecast_trend = forecast_result$forecast[days_ahead] - forecast_result$forecast[1],
    total_forecast = sum(forecast_result$forecast)
  )
  
  result
}

#' Detect weekly pattern in data
#' @noRd
detect_weekly_pattern <- function(y) {
  if (length(y) < 21) return(FALSE)
  
  # Simple test: check if variance by weekday differs
  n <- length(y)
  weekdays <- rep(1:7, length.out = n)
  
  by_weekday <- split(y, weekdays)
  means <- sapply(by_weekday, mean, na.rm = TRUE)
  
  # If weekday means vary by more than 20% from overall mean, there's a pattern
  overall_mean <- mean(y, na.rm = TRUE)
  max_deviation <- max(abs(means - overall_mean)) / overall_mean
  
  max_deviation > 0.2
}

#' ARIMA forecasting
#' @noRd
forecast_arima <- function(y, h, confidence) {
  # Simple ARIMA(1,1,1) implementation
  n <- length(y)
  
  # Difference the series
  dy <- diff(y)
  
  # Estimate AR(1) coefficient
  phi <- cor(dy[-length(dy)], dy[-1])
  if (is.na(phi)) phi <- 0
  phi <- max(-0.9, min(0.9, phi))
  
  # Estimate MA(1) coefficient (simplified)
  theta <- 0.3
  
  # Last values
  last_y <- y[n]
  last_dy <- dy[n - 1]
  
  # Forecast
  forecast <- numeric(h)
  sigma <- sd(dy, na.rm = TRUE)
  
  for (i in 1:h) {
    if (i == 1) {
      forecast[i] <- last_y + phi * last_dy
    } else {
      forecast[i] <- forecast[i - 1] + phi * (forecast[i - 1] - if (i > 2) forecast[i - 2] else last_y)
    }
  }
  
  # Prediction intervals widen with horizon
  z <- qnorm((1 + confidence) / 2)
  se <- sigma * sqrt(1:h)
  
  list(
    forecast = forecast,
    lower = forecast - z * se,
    upper = forecast + z * se
  )
}

#' Exponential smoothing forecasting
#' @noRd
forecast_ets <- function(y, h, confidence) {
  n <- length(y)
  
  # Estimate level smoothing parameter
  alpha <- 0.3
  
  # Initialize
  level <- y[1]
  
  # Fit
  for (i in 2:n) {
    level <- alpha * y[i] + (1 - alpha) * level
  }
  
  # Forecast (flat)
  forecast <- rep(level, h)
  
  # Variance estimation
  residuals <- numeric(n - 1)
  fitted_level <- y[1]
  for (i in 2:n) {
    residuals[i - 1] <- y[i] - fitted_level
    fitted_level <- alpha * y[i] + (1 - alpha) * fitted_level
  }
  
  sigma <- sd(residuals, na.rm = TRUE)
  z <- qnorm((1 + confidence) / 2)
  se <- sigma * sqrt(cumsum(rep(alpha^2, h)) + (1:h) * (1 - alpha)^2)
  
  list(
    forecast = forecast,
    lower = forecast - z * se,
    upper = forecast + z * se
  )
}

#' Holt's linear trend forecasting
#' @noRd
forecast_holt <- function(y, h, confidence) {
  n <- length(y)
  
  # Parameters
  alpha <- 0.3
  beta <- 0.1
  
  # Initialize
  level <- y[1]
  trend <- mean(diff(y[1:min(7, n)]))
  
  # Fit
  for (i in 2:n) {
    old_level <- level
    level <- alpha * y[i] + (1 - alpha) * (level + trend)
    trend <- beta * (level - old_level) + (1 - beta) * trend
  }
  
  # Forecast
  forecast <- level + (1:h) * trend
  
  # Variance
  residuals <- numeric(n - 1)
  fit_level <- y[1]
  fit_trend <- trend
  for (i in 2:n) {
    residuals[i - 1] <- y[i] - (fit_level + fit_trend)
    old_level <- fit_level
    fit_level <- alpha * y[i] + (1 - alpha) * (fit_level + fit_trend)
    fit_trend <- beta * (fit_level - old_level) + (1 - beta) * fit_trend
  }
  
  sigma <- sd(residuals, na.rm = TRUE)
  z <- qnorm((1 + confidence) / 2)
  se <- sigma * sqrt(1:h)
  
  list(
    forecast = pmax(0, forecast),
    lower = pmax(0, forecast - z * se),
    upper = forecast + z * se
  )
}

#' Seasonal forecasting (weekly pattern)
#' @noRd
forecast_seasonal <- function(y, h, confidence) {
  n <- length(y)
  
  # Calculate weekly seasonal factors
  weekdays <- rep(1:7, length.out = n)
  by_weekday <- split(y, weekdays)
  seasonal <- sapply(by_weekday, mean, na.rm = TRUE)
  overall_mean <- mean(y, na.rm = TRUE)
  seasonal_factors <- seasonal / overall_mean
  
  # Deseasonalize
  y_deseasonalized <- y / seasonal_factors[weekdays]
  
  # Fit Holt on deseasonalized
  alpha <- 0.3
  beta <- 0.05
  
  level <- y_deseasonalized[1]
  trend <- mean(diff(y_deseasonalized[1:min(7, n)]))
  
  for (i in 2:n) {
    old_level <- level
    level <- alpha * y_deseasonalized[i] + (1 - alpha) * (level + trend)
    trend <- beta * (level - old_level) + (1 - beta) * trend
  }
  
  # Forecast
  forecast_base <- level + (1:h) * trend
  
  # Apply seasonal factors
  last_weekday <- weekdays[n]
  future_weekdays <- ((last_weekday + 1:h - 1) %% 7) + 1
  forecast <- forecast_base * seasonal_factors[future_weekdays]
  
  # Variance
  sigma <- sd(y - fitted_seasonal(y, seasonal_factors, alpha, beta), na.rm = TRUE)
  z <- qnorm((1 + confidence) / 2)
  se <- sigma * sqrt(1:h)
  
  list(
    forecast = pmax(0, forecast),
    lower = pmax(0, forecast - z * se),
    upper = forecast + z * se
  )
}

#' Helper for seasonal fitting
#' @noRd
fitted_seasonal <- function(y, factors, alpha, beta) {
  n <- length(y)
  weekdays <- rep(1:7, length.out = n)
  y_ds <- y / factors[weekdays]
  
  level <- y_ds[1]
  trend <- 0
  fitted <- numeric(n)
  fitted[1] <- level * factors[1]
  
  for (i in 2:n) {
    old_level <- level
    level <- alpha * y_ds[i] + (1 - alpha) * (level + trend)
    trend <- beta * (level - old_level) + (1 - beta) * trend
    fitted[i] <- (level + trend) * factors[weekdays[i]]
  }
  
  fitted
}

#' Workload Projection
#'
#' Project future review workload with scenario analysis.
#'
#' @param path Path to collection.anki2 (auto-detected if NULL)
#' @param profile Profile name (first profile if NULL)
#' @param days Number of days to project (default 30)
#' @param scenarios List of scenario parameters
#' @return A tibble with workload projections for each scenario
#' @export
#'
#' @examples
#' \dontrun{
#' proj <- anki_workload_projection(days = 30)
#' }
anki_workload_projection <- function(path = NULL, profile = NULL,
                                     days = 30,
                                     scenarios = NULL) {
  col <- anki_collection(path, profile)
  on.exit(col$close())
  
  # Default scenarios
  if (is.null(scenarios)) {
    scenarios <- list(
      current = list(new_cards = 20, retention = 0.9, name = "Current Settings"),
      reduced = list(new_cards = 10, retention = 0.9, name = "Reduced New Cards"),
      intensive = list(new_cards = 40, retention = 0.9, name = "Intensive"),
      maintenance = list(new_cards = 0, retention = 0.9, name = "Maintenance Only")
    )
  }
  
  # Get baseline data
  cards <- col$cards()
  revlog <- col$revlog()
  
  # Calculate current workload patterns
  daily <- anki_stats_daily(path = col$path)
  avg_reviews <- mean(tail(daily$reviews, 30), na.rm = TRUE)
  
  # Current due load
  today_num <- as.numeric(Sys.Date() - as.Date("1970-01-01"))
  current_due <- sum(cards$queue == 2 & cards$due <= today_num)
  
  # New cards remaining
  new_remaining <- sum(cards$queue == 0)
  
  # Project for each scenario
  results <- lapply(names(scenarios), function(scenario_name) {
    sc <- scenarios[[scenario_name]]
    
    # Simple projection model
    daily_base <- current_due / 7  # spread current backlog
    daily_new_reviews <- sc$new_cards * 4  # new cards reviewed ~4x in learning
    daily_mature_reviews <- avg_reviews * 0.7  # mature cards
    
    daily_total <- daily_base + daily_new_reviews + daily_mature_reviews
    
    # Adjust for retention (lower retention = more reviews)
    retention_factor <- (1 - sc$retention) / 0.1 + 1
    daily_total <- daily_total * retention_factor
    
    # Time estimate (avg 10 seconds per review)
    daily_time <- daily_total * 10 / 60
    
    tibble::tibble(
      day = 1:days,
      date = Sys.Date() + 1:days,
      scenario = sc$name,
      reviews = round(daily_total),
      time_minutes = round(daily_time, 1),
      cumulative_reviews = cumsum(round(daily_total)),
      new_cards_added = cumsum(rep(sc$new_cards, days))
    )
  })
  
  do.call(rbind, results)
}

#' Retention Stability Analysis
#'
#' Analyze how stable your retention is over time.
#'
#' @param path Path to collection.anki2 (auto-detected if NULL)
#' @param profile Profile name (first profile if NULL)
#' @param window Rolling window size in days (default 7)
#' @return A tibble with retention stability metrics
#' @export
anki_retention_stability <- function(path = NULL, profile = NULL, window = 7) {
  col <- anki_collection(path, profile)
  on.exit(col$close())
  
  revlog <- col$revlog()
  
  # Filter to review type only
  reviews <- revlog[revlog$type == 1, ]
  
  if (nrow(reviews) < window * 2) {
    message("Insufficient review data")
    return(tibble::tibble())
  }
  
  # Calculate daily retention
  daily <- aggregate(
    cbind(correct = ease > 1, total = rep(1, nrow(reviews))) ~ review_date,
    data = reviews,
    FUN = sum
  )
  daily$retention <- daily$correct / daily$total
  daily <- daily[order(daily$review_date), ]
  
  # Rolling statistics
  n <- nrow(daily)
  if (n < window) {
    message("Insufficient days of data")
    return(tibble::as_tibble(daily))
  }
  
  rolling_mean <- numeric(n)
  rolling_sd <- numeric(n)
  rolling_min <- numeric(n)
  rolling_max <- numeric(n)
  
  for (i in window:n) {
    window_data <- daily$retention[(i - window + 1):i]
    rolling_mean[i] <- mean(window_data, na.rm = TRUE)
    rolling_sd[i] <- sd(window_data, na.rm = TRUE)
    rolling_min[i] <- min(window_data, na.rm = TRUE)
    rolling_max[i] <- max(window_data, na.rm = TRUE)
  }
  
  daily$rolling_mean <- rolling_mean
  daily$rolling_sd <- rolling_sd
  daily$rolling_min <- rolling_min
  daily$rolling_max <- rolling_max
  daily$rolling_range <- rolling_max - rolling_min
  
  # Stability score (lower SD = more stable)
  daily$stability_score <- 1 - pmin(1, rolling_sd * 5)
  
  # Trend detection
  if (n >= 30) {
    recent <- tail(daily$retention, 14)
    earlier <- daily$retention[(n - 27):(n - 14)]
    trend_change <- mean(recent, na.rm = TRUE) - mean(earlier, na.rm = TRUE)
    attr(daily, "trend") <- list(
      recent_mean = mean(recent, na.rm = TRUE),
      earlier_mean = mean(earlier, na.rm = TRUE),
      change = trend_change,
      direction = if (trend_change > 0.02) "improving" else if (trend_change < -0.02) "declining" else "stable"
    )
  }
  
  tibble::as_tibble(daily)
}
