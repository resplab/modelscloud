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

# Decode a completed pexa_result into its native R object and attach a slim
# copy of the server response (rdsData stripped) so get_plots() can reach the
# executionId / extraData without doubling memory. Shared by the sync path in
# model_run() and the async-completion path in get_async_results().
.decode_result <- function(res) {
  out <- .from_rds(res)
  res_slim <- res
  res_slim$rdsData <- NULL
  attr(out, ".pexa_result") <- res_slim
  out
}

`%||%` <- function(x, y) if (!is.null(x)) x else y
