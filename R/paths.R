anki_base_path <- function() {
  os <- Sys.info()["sysname"]
  path <- if (os == "Linux") {
    file.path(Sys.getenv("HOME"), ".local", "share", "Anki2")
  } else if (os == "Darwin") {
    file.path(Sys.getenv("HOME"), "Library", "Application Support", "Anki2")
  } else {
    file.path(Sys.getenv("APPDATA"), "Anki2")
  }
  if (!dir.exists(path)) stop("Anki base path not found: ", path)
  path
}

anki_profiles <- function(base_path = NULL) {
  if (is.null(base_path)) base_path <- anki_base_path()
  dirs <- list.dirs(base_path, full.names = FALSE, recursive = FALSE)
  profiles <- dirs[sapply(dirs, function(d) {
    file.exists(file.path(base_path, d, "collection.anki2")) ||
    file.exists(file.path(base_path, d, "collection.anki21"))
  })]
  profiles[!profiles %in% c("addons", "addons21")]
}

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
