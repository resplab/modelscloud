#' Run a ModelsCloud Model
#'
#' @description
#' Executes a model on the ModelsCloud platform and returns its result. All
#' arguments fall back to the values stored by [connect_to_model()] when not
#' explicitly supplied, so in a typical session you only need to call
#' `model_run()` with no arguments (or just `model_input`).
#'
#' For asynchronous jobs the function returns immediately with a
#' `pexa_result_async` object. Use [get_async_results()] to poll for
#' completion.
#'
#' @param model_path Character. Model identifier in `"namespace/model"` format.
#'   Falls back to the value stored by [connect_to_model()].
#' @param model_input Named list of input parameters to pass to the model. If
#'   `NULL` the model uses its own built-in defaults.
#' @param func_name Character. The function within the model to invoke. If
#'   `NULL` the model's default function is called.
#' @param access_key Character. API bearer token. Falls back to the stored key
#'   or the `MODELSCLOUD_ACCESS_KEY` environment variable.
#' @param server_url Character. Server base URL. Falls back to the stored URL.
#' @param async Logical. Run asynchronously? Falls back to the value from
#'   [connect_to_model()] (default `FALSE`).
#'
#' @return For synchronous calls a `pexa_result` object. For asynchronous
#'   calls a `pexa_result_async` object — call [get_async_results()] to poll
#'   until the job completes.
#'
#' @seealso [connect_to_model()], [get_async_results()],
#'   [list_extra_output()], [get_extra_output()]
#'
#' @examples
#' \dontrun{
#' connect_to_model("resp/epicr", access_key = "YOUR_KEY")
#'
#' # Run with model defaults
#' result <- model_run()
#'
#' # Run with custom inputs
#' result <- model_run(model_input = list(time_horizon = 15, discount_rate = 0.03))
#'
#' # Override async for a single call
#' job <- model_run(async = TRUE)
#' result <- get_async_results(job)
#' }
#' @export
model_run <- function(
  model_path  = NULL,
  model_input = NULL,
  func_name   = NULL,
  access_key  = NULL,
  server_url  = NULL,
  async       = NULL
) {
  model_path <- .resolve_arg(model_path, .pkg_cache$model_path,
    "model_path not set. Call connect_to_model() first or supply model_path.")

  access_key <- .resolve_key(access_key)
  server_url <- .resolve_arg(server_url, .pkg_cache$server_url, NULL)
  async      <- if (!is.null(async)) isTRUE(async) else .pkg_cache$async

  pexaclient::function_call(
    model_path = model_path,
    func_input = model_input,
    func_name  = func_name,
    access_key = access_key,
    server_url = server_url,
    async      = async
  )
}


# --- internal helpers --------------------------------------------------------

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

`%||%` <- function(x, y) if (!is.null(x)) x else y
