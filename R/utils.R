anki_timestamp_to_datetime <- function(ts) {
  as.POSIXct(ts / 1000, origin = "1970-01-01", tz = "UTC")
}

anki_timestamp_to_date <- function(ts) {
  as.Date(anki_timestamp_to_datetime(ts))
}

`%||%` <- function(x, y) if (is.null(x)) y else x
