#' Convert Anki timestamp to datetime
#'
#' @param x Numeric timestamp in milliseconds since epoch
#' @return POSIXct datetime object
#' @export
#' @examples
#' anki_timestamp_to_datetime(1368291917470)
anki_timestamp_to_datetime <- function(x) {
  as.POSIXct(x / 1000, origin = "1970-01-01")
}

#' Convert Anki timestamp to date
#'
#' @param x Numeric timestamp in milliseconds since epoch
#' @return Date object
#' @export
#' @examples
#' anki_timestamp_to_date(1368291917470)
anki_timestamp_to_date <- function(x) {
  as.Date(anki_timestamp_to_datetime(x))
}

#' @keywords internal
`%||%` <- function(a, b) if (is.null(a)) b else a
