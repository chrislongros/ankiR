anki_collection <- function(path = NULL, profile = NULL) {
  if (is.null(path)) path <- anki_db_path(profile = profile)
  con <- DBI::dbConnect(RSQLite::SQLite(), path, flags = RSQLite::SQLITE_RO)
  structure(list(
    path = path, con = con,
    notes = function() read_notes(con),
    cards = function() read_cards(con),
    revlog = function() read_revlog(con),
    close = function() DBI::dbDisconnect(con),
    tables = function() DBI::dbListTables(con)
  ), class = c("anki_collection", "list"))
}

print.anki_collection <- function(x, ...) {
  cat("Anki Collection:", x$path, "\n")
  cat("Tables:", paste(x$tables(), collapse = ", "), "\n")
  invisible(x)
}

read_notes <- function(con) {
  n <- DBI::dbReadTable(con, "notes")
  tibble::tibble(nid = n$id, mid = n$mid, tags = n$tags, flds = n$flds, sfld = n$sfld)
}

read_cards <- function(con) {
  c <- DBI::dbReadTable(con, "cards")
  tibble::tibble(cid = c$id, nid = c$nid, did = c$did, type = c$type,
    queue = c$queue, due = c$due, ivl = c$ivl, reps = c$reps, lapses = c$lapses)
}

read_revlog <- function(con) {
  r <- DBI::dbReadTable(con, "revlog")
  tibble::tibble(rid = r$id, cid = r$cid, ease = r$ease, ivl = r$ivl,
    time = r$time, review_date = anki_timestamp_to_date(r$id))
}

anki_notes <- function(path = NULL, profile = NULL) {
 col <- anki_collection(path, profile); on.exit(col$close()); col$notes()
}
anki_cards <- function(path = NULL, profile = NULL) {
 col <- anki_collection(path, profile); on.exit(col$close()); col$cards()
}
anki_revlog <- function(path = NULL, profile = NULL) {
 col <- anki_collection(path, profile); on.exit(col$close()); col$revlog()
}
