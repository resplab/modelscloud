#' Get a Sample Input for a Model
#'
#' @description
#' Retrieves a sample (example) set of inputs from the model on the server.
#' The result is deserialised from RDS format, so the original R object class
#' (e.g. data frame) is fully preserved.
#'
#' All arguments fall back to the values stored by [connect_to_model()] when
#' not explicitly supplied.
#'
#' @param model_path Character. Model identifier in `"namespace/model"` format.
#'   Falls back to the value stored by [connect_to_model()].
#' @param access_key Character. API bearer token. Falls back to the stored key
#'   or the `MODELSCLOUD_ACCESS_KEY` environment variable.
#' @param server_url Character. Server base URL. Falls back to the stored URL.
#' @param ... Additional arguments passed to the model's `get_sample_input`
#'   function (e.g. `n = 5` to limit the number of rows returned).
#'
#' @return The sample input object as returned by the model, with its original
#'   R class preserved (typically a data frame).
#'
#' @seealso [connect_to_model()], [get_default_input()], [model_run()]
#'
#' @examples
#' \dontrun{
#' connect_to_model("mohsenss/qrisk3pexa", access_key = "YOUR_KEY")
#' sample <- get_sample_input()
#' result <- model_run(model_input = sample)
#' }
#' @export
get_sample_input <- function(
  model_path = NULL,
  access_key = NULL,
  server_url = NULL,
  ...
) {
  func_input <- list(...)

  model_path <- .resolve_arg(
    model_path,
    .pkg_cache$model_path,
    "model_path not set. Call connect_to_model() first or supply model_path."
  )
  access_key <- .resolve_key(access_key)
  server_url <- .resolve_arg(server_url, .pkg_cache$server_url, NULL)

  res <- pexaclient::function_call(
    model_path = model_path,
    func_input = func_input,
    func_name  = "get_sample_input",
    access_key = access_key,
    server_url = server_url,
    async      = FALSE
  )

  .from_rds(res)
}
