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
