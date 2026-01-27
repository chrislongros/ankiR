#' Get Anki base path
#'
#' Returns the default Anki2 directory for the current platform.
#'
#' @return Character string path to Anki2 directory
#' @export
#' @examples
#' \dontrun{
#' anki_base_path()
#' }
anki_base_path <- function() {
  if (.Platform$OS.type == "windows") {
    file.path(Sys.getenv("APPDATA"), "Anki2")
  } else if (Sys.info()["sysname"] == "Darwin") {
    path.expand("~/Library/Application Support/Anki2")
  } else {
    path.expand("~/.local/share/Anki2")
  }
}

#' List Anki profiles
#'
#' @param base_path Path to Anki2 directory (auto-detected if NULL)
#' @return Character vector of profile names
#' @export
#' @examples
#' \dontrun{
#' anki_profiles()
#' }
anki_profiles <- function(base_path = NULL) {
  if (is.null(base_path)) base_path <- anki_base_path()
  dirs <- list.dirs(base_path, full.names = FALSE, recursive = FALSE)
  profiles <- dirs[sapply(dirs, function(d) {
    file.exists(file.path(base_path, d, "collection.anki2")) ||
    file.exists(file.path(base_path, d, "collection.anki21"))
  })]
  profiles[!profiles %in% c("addons", "addons21")]
}

#' Get path to Anki database
#'
#' @param profile Profile name (first profile if NULL)
#' @param base_path Path to Anki2 directory (auto-detected if NULL)
#' @return Character string path to collection.anki2
#' @export
#' @examples
#' \dontrun{
#' anki_db_path()
#' }
anki_db_path <- function(profile = NULL, base_path = NULL) {
  if (is.null(base_path)) base_path <- anki_base_path()
  if (is.null(profile)) {
    profile <- anki_profiles(base_path)[1]
    message("Using profile: ", profile)
  }
  db <- file.path(base_path, profile, "collection.anki2")
  if (!file.exists(db)) db <- file.path(base_path, profile, "collection.anki21")
  if (!file.exists(db)) stop("Database not found for profile: ", profile)
  db
}
