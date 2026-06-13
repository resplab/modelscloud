#' Retrieve Plots Produced by a Model Run
#'
#' @description
#' Models hosted on ModelsCloud can generate plots as side-outputs during a
#' run (e.g. a barplot of predicted risks). `get_plots()` *retrieves* those
#' plots from the server; it does not draw them. To display a retrieved plot,
#' call `plot()` on it (an S3 `plot` method renders the image).
#'
#' Pass the object returned by [model_run()] directly — the server connection
#' details are carried along automatically.
#'
#' Called with no `id`, `get_plots()` lists all available plots and returns a
#' summary data frame. Called with an `id`, it returns that plot's image.
#'
#' @param result The object returned by [model_run()].
#' @param id Integer or character. Which plot to retrieve. Use the `id` column
#'   from the listing (no-argument) call to find valid values. If `NULL`
#'   (default), returns a data frame listing all available plots.
#' @param access_key Character. API bearer token. Falls back to the stored key
#'   or the `MODELSCLOUD_ACCESS_KEY` environment variable.
#' @param server_url Character. Server base URL. Falls back to the stored URL.
#'
#' @return If `id = NULL`: a data frame summarising available plots (one row
#'   per plot). If `id` is supplied: the plot image object, which you display
#'   with `plot()`.
#'
#' @seealso [model_run()]
#'
#' @examples
#' \dontrun{
#' # toymodel1's model_run() draws a barplot, captured server-side by OpenCPU.
#' connect_to_model("examples/toymodel1", access_key = "YOUR_KEY")
#' result <- model_run(get_sample_input())
#'
#' # See what plots are available
#' get_plots(result)
#'
#' # Retrieve the first plot, then display it
#' img <- get_plots(result, id = 1)
#' plot(img)
#' }
#' @export
get_plots <- function(result, id = NULL, access_key = NULL, server_url = NULL) {

  pexa_res <- attr(result, ".pexa_result")
  if (is.null(pexa_res)) {
    stop(
      "No plot data found. `result` must be the value returned by model_run().",
      call. = FALSE
    )
  }

  access_key <- .resolve_key(access_key)
  server_url <- .resolve_arg(server_url, .pkg_cache$server_url, NULL)

  # No registered extra outputs → nothing to list or fetch (covers both paths
  # cleanly, instead of get_extra_output() failing with a subscript error).
  extra <- pexa_res$extraData
  if (is.null(extra) || length(extra) == 0) {
    message("No plots available for this model run.")
    return(invisible(NULL))
  }

  if (is.null(id)) {
    # List available plots
    return(pexaclient::list_extra_output(pexa_res))
  }

  # Retrieve a specific plot. Display it separately with plot() — the
  # pexa_image S3 plot method (from pexaclient) renders it.
  pexaclient::get_extra_output(
    pexa_object = pexa_res,
    output_id   = id,
    access_key  = access_key,
    server_url  = server_url
  )
}
