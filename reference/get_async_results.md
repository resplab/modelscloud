# Retrieve the Result of an Asynchronous Model Run

Fetches the result of a job submitted with `model_run(async = TRUE)`.
Pass the job handle returned by
[`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md)
directly.

By default this checks once: if the job is finished it returns the
decoded result (with its original R class preserved, exactly like a
synchronous
[`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md));
if the job is still running it returns the job handle unchanged, so you
can call `get_async_results()` again later to poll.

Set `wait = TRUE` to block and poll automatically until the job
completes (or `timeout` is reached).

## Usage

``` r
get_async_results(
  job,
  wait = FALSE,
  interval = 2,
  timeout = 300,
  access_key = NULL,
  server_url = NULL
)
```

## Arguments

- job:

  The job handle returned by `model_run(async = TRUE)` (an object of
  class `pexa_result_async`).

- wait:

  Logical. If `FALSE` (default), check once and return either the
  decoded result or the unchanged job handle. If `TRUE`, poll until the
  job finishes or `timeout` is reached.

- interval:

  Numeric. Seconds between polls when `wait = TRUE`. Default `2`.

- timeout:

  Numeric. Maximum seconds to wait when `wait = TRUE`. Default `300`.
  Set to `Inf` to wait indefinitely. On timeout the job handle is
  returned (with a warning) so you can keep polling.

- access_key:

  Character. API bearer token. Falls back to the stored key or the
  `MODELSCLOUD_ACCESS_KEY` environment variable.

- server_url:

  Character. Server base URL. Falls back to the stored URL.

## Value

If the job is finished: the model output with its original R class
preserved (the raw server response is attached as an invisible attribute
for
[`get_plots()`](https://resplab.github.io/modelscloud/reference/get_plots.md)).
If still running: the job handle, unchanged.

## See also

[`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md),
[`connect_to_model()`](https://resplab.github.io/modelscloud/reference/connect_to_model.md),
[`get_plots()`](https://resplab.github.io/modelscloud/reference/get_plots.md)

## Examples

``` r
if (FALSE) { # \dontrun{
connect_to_model("examples/toymodel2", access_key = "YOUR_KEY")

# Submit asynchronously per call, then poll manually
job <- model_run(async = TRUE)
result <- get_async_results(job)
if (inherits(result, "pexa_result_async")) {
  Sys.sleep(5)
  result <- get_async_results(job)
}

# Or block until done
result <- get_async_results(model_run(async = TRUE), wait = TRUE)
} # }
```
