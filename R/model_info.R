#' Get the Default Input for a Model
#'
#' @description
#' Retrieves the default input values that the model uses when no custom input
#' is supplied to [model_run()]. Useful for discovering what parameters a model
#' accepts and inspecting their baseline values before customising a run.
#'
#' All arguments fall back to the values stored by [connect_to_model()] when
#' not explicitly supplied.
#'
#' @param model_path Character. Model identifier in `"namespace/model"` format.
#'   Falls back to the value stored by [connect_to_model()].
#' @param access_key Character. API bearer token. Falls back to the stored key
#'   or the `MODELSCLOUD_ACCESS_KEY` environment variable.
#' @param server_url Character. Server base URL. Falls back to the stored URL.
#'
#' @return A named list of default input parameters as returned by the model.
#'
#' @seealso [connect_to_model()], [get_sample_input()], [model_run()]
#'
#' @examples
#' \dontrun{
#' connect_to_model("resp/epicr", access_key = "YOUR_KEY")
#' defaults <- get_default_input()
#' str(defaults)
#' }
#' @export
get_default_input <- function(
  model_path = NULL,
  access_key = NULL,
  server_url = NULL
) {
  model_path <- .resolve_arg(model_path, .pkg_cache$model_path,
    "model_path not set. Call connect_to_model() first or supply model_path.")
  access_key <- .resolve_key(access_key)
  server_url <- .resolve_arg(server_url, .pkg_cache$server_url, NULL)

  res <- pexaclient::function_call(
    model_path = model_path,
    func_name  = "getDefaultInput",
    access_key = access_key,
    server_url = server_url,
    async      = FALSE
  )

  res$output
}


#' Get a Sample Input for a Model
#'
#' @description
#' Retrieves a sample (example) set of inputs for the model — a concrete,
#' filled-in set of parameters that can be used as a starting point for
#' customisation or for testing a [model_run()] call.
#'
#' All arguments fall back to the values stored by [connect_to_model()] when
#' not explicitly supplied.
#'
#' @param model_path Character. Model identifier in `"namespace/model"` format.
#'   Falls back to the value stored by [connect_to_model()].
#' @param access_key Character. API bearer token. Falls back to the stored key
#'   or the `MODELSCLOUD_ACCESS_KEY` environment variable.
#' @param server_url Character. Server base URL. Falls back to the stored URL.
#'
#' @return A named list of sample input parameters as returned by the model.
#'
#' @seealso [connect_to_model()], [get_default_input()], [model_run()]
#'
#' @examples
#' \dontrun{
#' connect_to_model("resp/epicr", access_key = "YOUR_KEY")
#' sample_in <- get_sample_input()
#'
#' # Tweak and run
#' sample_in$time_horizon <- 20
#' result <- model_run(model_input = sample_in)
#' }
#' @export
get_sample_input <- function(
  model_path = NULL,
  access_key = NULL,
  server_url = NULL
) {
  model_path <- .resolve_arg(model_path, .pkg_cache$model_path,
    "model_path not set. Call connect_to_model() first or supply model_path.")
  access_key <- .resolve_key(access_key)
  server_url <- .resolve_arg(server_url, .pkg_cache$server_url, NULL)

  res <- pexaclient::function_call(
    model_path = model_path,
    func_name  = "getSampleInput",
    access_key = access_key,
    server_url = server_url,
    async      = FALSE
  )

  res$output
}
