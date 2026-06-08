# Internal helpers — not exported

.resolve_arg <- function(arg, cached, error_msg) {
  val <- if (!is.null(arg)) arg else cached
  if (is.null(val) && !is.null(error_msg)) {
    stop(error_msg, call. = FALSE)
  }
  val
}

.resolve_key <- function(access_key) {
  val <- access_key %||% .pkg_cache$access_key
  if (is.null(val)) {
    val <- Sys.getenv("MODELSCLOUD_ACCESS_KEY", unset = "")
  }
  if (identical(val, "")) {
    stop(
      "API access key not set. Supply access_key, call connect_to_model(), ",
      "or set MODELSCLOUD_ACCESS_KEY in .Renviron.",
      call. = FALSE
    )
  }
  val
}

.from_rds <- function(res) {
  raw_data <- base64enc::base64decode(res$rdsData$content)
  con <- rawConnection(raw_data, "rb")
  on.exit(close(con))
  readRDS(con)
}

`%||%` <- function(x, y) if (!is.null(x)) x else y
