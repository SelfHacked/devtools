find_active_file <- function(arg = "file") {
  if (!rstudioapi::isAvailable()) {
    stop("Argument `", arg, "` is missing, with no default", call. = FALSE)
  }
  rstudioapi::getSourceEditorContext()$path
}

find_test_file <- function(path) {
  type <- test_file_type(path)
  if (any(is.na(type))) {
    rlang::abort(c("Don't know how to find tests for: ", path[is.na(type)]))
  }

  is_test <- type == "test"
  path[!is_test] <- paste0("tests/testthat/test-", name_source(path[!is_test]), ".R")
  path <- unique(path[file.exists(path)])

  if (length(path) == 0) {
    rlang::abort("No test files found")
  }
  path
}

test_file_type <- function(path) {
  dir <- basename(dirname(path))
  name <- basename(path)
  ext <- tolower(tools::file_ext(path))

  src_ext <- c("c", "cc", "cpp", "cxx", "h", "hpp", "hxx")

  type <- rep(NA_character_, length(path))
  type[dir == "R" & ext == "r"] <- "R"
  type[dir == "testthat" & ext == "r" & grepl("^test", name)] <- "test"
  type[dir == "src" & ext %in% src_ext] <- "src"
  type
}

# Figure out "name" of a test or source file
name_test <- function(path) {
  gsub("^test[-_]", "", name_source(path))
}
name_source <- function(path) {
  tools::file_path_sans_ext(basename(path))
}
