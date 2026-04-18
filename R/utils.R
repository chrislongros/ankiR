#' Convert Anki timestamp to datetime
#'
#' Converts Anki's millisecond-epoch timestamps to POSIXct datetime objects.
#'
#' @param x Numeric timestamp in milliseconds since Unix epoch (1970-01-01)
#' @return POSIXct datetime object in local timezone
#' @export
#' @examples
#' # Convert a typical Anki timestamp
#' anki_timestamp_to_datetime(1368291917470)
anki_timestamp_to_datetime <- function(x) {
  as.POSIXct(x / 1000, origin = "1970-01-01")
}

#' Convert Anki timestamp to date
#'
#' Converts Anki's millisecond-epoch timestamps to Date objects.
#'
#' @param x Numeric timestamp in milliseconds since Unix epoch (1970-01-01)
#' @return Date object
#' @export
#' @examples
#' # Convert a typical Anki timestamp
#' anki_timestamp_to_date(1368291917470)
anki_timestamp_to_date <- function(x) {
  as.Date(anki_timestamp_to_datetime(x))
}

#' Convert date to Anki timestamp
#'
#' Converts a Date or POSIXct to Anki's millisecond-epoch format.
#'
#' @param x Date or POSIXct object
#' @return Numeric timestamp in milliseconds since Unix epoch
#' @export
#' @examples
#' date_to_anki_timestamp(Sys.Date())
date_to_anki_timestamp <- function(x) {
 as.numeric(as.POSIXct(x)) * 1000
}

#' Today expressed as days since collection creation
#'
#' Queue-2 cards store \code{due} as integer days since the collection was
#' created (\code{col.crt}), not since the Unix epoch. Use this helper to
#' compute a directly comparable "today" value.
#'
#' @param crt Collection creation timestamp in seconds (from \code{col$crt})
#' @return Numeric, integer days since collection creation
#' @keywords internal
col_today_days <- function(crt) {
  if (is.null(crt) || is.na(crt)) {
    return(as.numeric(Sys.Date() - as.Date("1970-01-01")))
  }
  floor((as.numeric(Sys.time()) - crt) / 86400)
}

#' Convert Anki queue-2 due value to a Date
#'
#' @param due Numeric due value from the cards table (days since crt for
#'   queue 2; absolute seconds for queue 1; position for queue 0)
#' @param crt Collection creation timestamp in seconds
#' @return Date, or NA if crt is missing
#' @keywords internal
due_to_date <- function(due, crt) {
  if (is.null(crt) || is.na(crt)) {
    return(as.Date(rep(NA, length(due))))
  }
  as.Date(as.POSIXct(crt + due * 86400, origin = "1970-01-01"))
}

#' Null coalescing operator
#'
#' Returns the left-hand side if not NULL, otherwise returns the right-hand side.
#' @param a Value to check
#' @param b Default value if a is NULL
#' @return a if not NULL, otherwise b
#' @keywords internal
#' @noRd
`%||%` <- function(a, b) {
  if (is.null(a)) b else a
}

# Declare global variables to avoid R CMD check notes
# These are column names used in ggplot2 aes() and data.frame operations
utils::globalVariables(c(".data",
  "difficulty", "hour", "ivl", "name", "new_due",
  "retention", "reviews", "rolling_retention",
  "stability", "total", "week", "weekday", "date", "value",
  "component", "cid", "did", "nid", "ease", "time", "review_date",
  "mid", "sfld", "flds", "tags", "lapses", "type", "queue",
  "retrievability", "decay", "last_review", "period", "age_group"
))

# Import .data from rlang for ggplot2 tidy evaluation
#' @importFrom rlang .data
NULL
