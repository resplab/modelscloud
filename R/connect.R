#' Connect to a ModelsCloud Model
#'
#' @description
#' Stores connection settings for the current R session. After calling this
#' function, [model_run()], [get_default_input()], and [get_sample_input()]
#' will use these stored values whenever their own arguments are not explicitly
#' supplied.
#'
#' You only need to call this once per session. All settings are optional
#' except `model_path`.
#'
#' @param model_path Character. Model identifier in `"namespace/model"` format
#'   (e.g., `"resp/epicr"`).
#' @param access_key Character. API bearer token. If `NULL`, the previously
#'   stored key (if any) is left unchanged. You can also set the
#'   `MODELSCLOUD_ACCESS_KEY` environment variable in your `.Renviron` to avoid
#'   passing this in scripts.
#' @param server_url Character. Base URL of the ModelsCloud server. Defaults to
#'   `"https://api.modelscloud.resp.core.ubc.ca/"` if never overridden.
#' @param async Logical. Sets only the *default* execution mode for the
#'   session. The actual choice is made per call by [model_run()]'s own `async`
#'   argument; this just determines what `model_run()` does when its `async` is
#'   left unspecified. Default is `FALSE`.
#'
#' @return Invisibly returns the stored `model_path`.
#'
#' @seealso [model_run()], [get_default_input()], [get_sample_input()]
#'
#' @examples
#' \dontrun{
#' connect_to_model(
#'   model_path = "resp/epicr",
#'   access_key = "YOUR_API_KEY"
#' )
#'
#' # Async by default, custom server
#' connect_to_model(
#'   model_path = "resp/epicr",
#'   access_key = "YOUR_API_KEY",
#'   server_url = "https://myserver.example.com/",
#'   async      = TRUE
#' )
#' }
#' @export
connect_to_model <- function(
  model_path,
  access_key = NULL,
  server_url = NULL,
  async      = FALSE
) {
  if (!is.character(model_path) || length(model_path) != 1L) {
    stop("model_path must be a single character string.", call. = FALSE)
  }
  if (!grepl("^[^/]+/[^/]+$", model_path)) {
    stop(
      "model_path must be in 'namespace/model' format (e.g., 'resp/epicr').",
      call. = FALSE
    )
  }

  .pkg_cache$model_path <- model_path

  if (!is.null(access_key)) {
    if (!is.character(access_key) || length(access_key) != 1L) {
      stop("access_key must be a single character string.", call. = FALSE)
    }
    .pkg_cache$access_key <- access_key
  }

  if (!is.null(server_url)) {
    if (!is.character(server_url) || length(server_url) != 1L) {
      stop("server_url must be a single character string.", call. = FALSE)
    }
    if (!grepl("^https?://", server_url)) {
      warning("server_url does not start with http:// or https://")
    }
    .pkg_cache$server_url <- server_url
  }

  .pkg_cache$async <- isTRUE(async)

  message("Connected to model: ", model_path)
  invisible(model_path)
}
