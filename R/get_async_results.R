#' Retrieve the Result of an Asynchronous Model Run
#'
#' @description
#' Fetches the result of a job submitted with `model_run(async = TRUE)`. Pass
#' the job handle returned by [model_run()] directly.
#'
#' By default this checks once: if the job is finished it returns the decoded
#' result (with its original R class preserved, exactly like a synchronous
#' [model_run()]); if the job is still running it returns the job handle
#' unchanged, so you can call `get_async_results()` again later to poll.
#'
#' Set `wait = TRUE` to block and poll automatically until the job completes
#' (or `timeout` is reached).
#'
#' @param job The job handle returned by `model_run(async = TRUE)` (an object
#'   of class `pexa_result_async`).
#' @param wait Logical. If `FALSE` (default), check once and return either the
#'   decoded result or the unchanged job handle. If `TRUE`, poll until the job
#'   finishes or `timeout` is reached.
#' @param interval Numeric. Seconds between polls when `wait = TRUE`.
#'   Default `2`.
#' @param timeout Numeric. Maximum seconds to wait when `wait = TRUE`. Default
#'   `300`. Set to `Inf` to wait indefinitely. On timeout the job handle is
#'   returned (with a warning) so you can keep polling.
#' @param access_key Character. API bearer token. Falls back to the stored key
#'   or the `MODELSCLOUD_ACCESS_KEY` environment variable.
#' @param server_url Character. Server base URL. Falls back to the stored URL.
#'
#' @return If the job is finished: the model output with its original R class
#'   preserved (the raw server response is attached as an invisible attribute
#'   for [get_plots()]). If still running: the job handle, unchanged.
#'
#' @seealso [model_run()], [connect_to_model()], [get_plots()]
#'
#' @examples
#' \dontrun{
#' connect_to_model("examples/toymodel2", access_key = "YOUR_KEY")
#'
#' # Submit asynchronously per call, then poll manually
#' job <- model_run(async = TRUE)
#' result <- get_async_results(job)
#' if (inherits(result, "pexa_result_async")) {
#'   Sys.sleep(5)
#'   result <- get_async_results(job)
#' }
#'
#' # Or block until done
#' result <- get_async_results(model_run(async = TRUE), wait = TRUE)
#' }
#' @export
get_async_results <- function(
  job,
  wait       = FALSE,
  interval   = 2,
  timeout    = 300,
  access_key = NULL,
  server_url = NULL
) {
  if (!inherits(job, "pexa_result_async")) {
    stop(
      "`job` is not a running async job. Submit one with ",
      "model_run(async = TRUE) and pass the value it returns.",
      call. = FALSE
    )
  }

  access_key <- .resolve_key(access_key)
  server_url <- .resolve_arg(server_url, .pkg_cache$server_url, NULL)

  poll_once <- function() {
    pexaclient::get_async_results(
      pexa_object = job,
      access_key  = access_key,
      server_url  = server_url
    )
  }

  res <- poll_once()

  if (wait) {
    waited <- 0
    while (inherits(res, "pexa_result_async") && waited < timeout) {
      Sys.sleep(interval)
      waited <- waited + interval
      res <- poll_once()
    }
    if (inherits(res, "pexa_result_async")) {
      warning(
        "Job still running after ", timeout, "s timeout. Returning the job ",
        "handle — call get_async_results() again to keep polling.",
        call. = FALSE
      )
      return(res)
    }
  }

  # Still running (wait = FALSE): hand back the job handle for the next poll.
  if (inherits(res, "pexa_result_async")) {
    return(res)
  }

  # Finished: decode exactly like a synchronous model_run().
  .decode_result(res)
}
