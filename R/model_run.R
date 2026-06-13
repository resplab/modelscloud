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
#' @param model_input Named list (or data frame) of input parameters to pass to
#'   the model. This is the first positional argument, so
#'   `model_run(my_input)` works once [connect_to_model()] has been called. If
#'   `NULL` the model uses its own built-in defaults.
#' @param model_path Character. Model identifier in `"namespace/model"` format.
#'   Falls back to the value stored by [connect_to_model()].
#' @param func_name Character. The function within the model to invoke.
#'   Defaults to `"model_run"`.
#' @param access_key Character. API bearer token. Falls back to the stored key
#'   or the `MODELSCLOUD_ACCESS_KEY` environment variable.
#' @param server_url Character. Server base URL. Falls back to the stored URL.
#' @param async Logical. Run asynchronously? When `TRUE`, returns a job handle
#'   immediately; retrieve the result with [get_async_results()]. If left
#'   `NULL` (default), uses the session default set by [connect_to_model()]
#'   (itself `FALSE` unless changed).
#'
#' @return The model output with its original R class preserved (e.g. a data
#'   frame), deserialised from RDS format. The raw server response is attached
#'   as an invisible attribute, which [get_plots()] uses to retrieve any plots
#'   the model produced.
#'
#' @seealso [connect_to_model()], [get_plots()], [get_async_results()]
#'
#' @examples
#' \dontrun{
#' connect_to_model("examples/toymodel2", access_key = "YOUR_KEY")
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
  model_input = NULL,
  model_path = NULL,
  func_name = "model_run",
  access_key = NULL,
  server_url = NULL,
  async = NULL
) {
  model_path <- .resolve_arg(
    model_path,
    .pkg_cache$model_path,
    "model_path not set. Call connect_to_model() first or supply model_path."
  )

  access_key <- .resolve_key(access_key)
  server_url <- .resolve_arg(server_url, .pkg_cache$server_url, NULL)
  async <- if (!is.null(async)) isTRUE(async) else .pkg_cache$async

  # pexacloud calls do.call(server_func, funcInput), so funcInput must be a
  # named list whose keys are the server function's argument names. Wrap the
  # data under "model_input". Also convert any data frame to a column-oriented
  # list so it survives the JSON → as.data.frame() round-trip on the server.
  func_input <- if (!is.null(model_input)) {
    list(model_input = if (is.data.frame(model_input)) as.list(model_input) else model_input)
  } else {
    NULL
  }

  res <- pexaclient::function_call(
    model_path = model_path,
    func_input = func_input,
    func_name  = func_name,
    access_key = access_key,
    server_url = server_url,
    async      = async
  )

  # Async submit: the server returns a job handle ("running") with no rdsData
  # yet. Return it undecoded so the user can poll with get_async_results().
  if (inherits(res, "pexa_result_async")) {
    message(
      "Async job submitted (executionId: ", res$executionId, "). ",
      "Retrieve it with get_async_results()."
    )
    return(res)
  }

  .decode_result(res)
}
