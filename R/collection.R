#' Open an Anki collection
#'
#' @param path Path to collection.anki2 (auto-detected if NULL)
#' @param profile Profile name (first profile if NULL)
#' @return An anki_collection object with methods: notes(), cards(), revlog(), tables(), close()
#' @export
#' @examples
#' \dontrun{
#' col <- anki_collection()
#' col$notes()
#' col$close()
#' }
anki_collection <- function(path = NULL, profile = NULL) {
  if (is.null(path)) path <- anki_db_path(profile)
  con <- DBI::dbConnect(RSQLite::SQLite(), path, flags = RSQLite::SQLITE_RO)
  structure(list(
    path = path,
    con = con,
    notes = function() read_notes(con),
    cards = function() read_cards(con),
    revlog = function() read_revlog(con),
    tables = function() DBI::dbListTables(con),
    close = function() DBI::dbDisconnect(con)
  ), class = "anki_collection")
}

#' @export
print.anki_collection <- function(x, ...) {

  cat("Anki Collection:", x$path, "\n")
  cat("Tables:", paste(x$tables(), collapse = ", "), "\n")
  invisible(x)
}

#' @keywords internal
read_notes <- function(con) {
  n <- DBI::dbReadTable(con, "notes")
  tibble::tibble(nid = n$id, mid = n$mid, tags = n$tags, flds = n$flds, sfld = n$sfld)
}

#' @keywords internal
read_cards <- function(con) {
  c <- DBI::dbReadTable(con, "cards")
  tibble::tibble(cid = c$id, nid = c$nid, did = c$did, type = c$type,
    queue = c$queue, due = c$due, ivl = c$ivl, reps = c$reps, lapses = c$lapses)
}

#' @keywords internal
read_revlog <- function(con) {
  r <- DBI::dbReadTable(con, "revlog")
  tibble::tibble(rid = r$id, cid = r$cid, ease = r$ease, ivl = r$ivl,
    time = r$time, review_date = anki_timestamp_to_date(r$id))
}

#' Read notes from Anki collection
#'
#' @param path Path to collection.anki2 (auto-detected if NULL)
#' @param profile Profile name (first profile if NULL)
#' @return A tibble of notes
#' @export
#' @examples
#' \dontrun{
#' anki_notes()
#' }
anki_notes <- function(path = NULL, profile = NULL) {
  col <- anki_collection(path, profile); on.exit(col$close()); col$notes()
}

#' Read cards from Anki collection
#'
#' @param path Path to collection.anki2 (auto-detected if NULL)
#' @param profile Profile name (first profile if NULL)
#' @return A tibble of cards
#' @export
#' @examples
#' \dontrun{
#' anki_cards()
#' }
anki_cards <- function(path = NULL, profile = NULL) {
  col <- anki_collection(path, profile); on.exit(col$close()); col$cards()
}

#' Read review log from Anki collection
#'
#' @param path Path to collection.anki2 (auto-detected if NULL)
#' @param profile Profile name (first profile if NULL)
#' @return A tibble of review log entries
#' @export
#' @examples
#' \dontrun{
#' anki_revlog()
#' }
anki_revlog <- function(path = NULL, profile = NULL) {
  col <- anki_collection(path, profile); on.exit(col$close()); col$revlog()
}

#' Read cards with FSRS parameters
#'
#' @param path Path to collection.anki2 (auto-detected if NULL)
#' @param profile Profile name (first profile if NULL)
#' @return A tibble of cards with FSRS parameters (stability, difficulty, retention)
#' @importFrom jsonlite fromJSON
#' @export
#' @examples
#' \dontrun{
#' anki_cards_fsrs()
#' }
anki_cards_fsrs <- function(path = NULL, profile = NULL) {
  col <- anki_collection(path, profile)
  on.exit(col$close())
  
  c <- DBI::dbReadTable(col$con, "cards")
  
  # Parse FSRS JSON data
  fsrs <- lapply(c$data, function(x) {
    if (is.na(x) || x == "" || x == "{}") {
      return(list(s = NA_real_, d = NA_real_, dr = NA_real_, decay = NA_real_))
    }
    j <- tryCatch(jsonlite::fromJSON(x), error = function(e) list())
    list(
      s = j$s %||% NA_real_,
      d = j$d %||% NA_real_,
      dr = j$dr %||% NA_real_,
      decay = j$decay %||% NA_real_
    )
  })
  
  tibble::tibble(
    cid = c$id,
    nid = c$nid,
    did = c$did,
    type = c$type,
    queue = c$queue,
    due = c$due,
    ivl = c$ivl,
    reps = c$reps,
    lapses = c$lapses,
    stability = sapply(fsrs, `[[`, "s"),
    difficulty = sapply(fsrs, `[[`, "d"),
    retention = sapply(fsrs, `[[`, "dr"),
    decay = sapply(fsrs, `[[`, "decay")
  )
}

#' Calculate current retrievability for FSRS cards
#'
#' @param stability Stability in days
#' @param days_since_review Days since last review
#' @param decay Decay parameter (default 0.256)
#' @return Retrievability (0-1)
#' @export
fsrs_retrievability <- function(stability, days_since_review, decay = 0.256) {
  (1 + days_since_review / (9 * stability))^(-1 / decay)
}

