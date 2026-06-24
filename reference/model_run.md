# Run a ModelsCloud Model

Executes a model on the ModelsCloud platform and returns its result. All
arguments fall back to the values stored by
[`connect_to_model()`](https://resplab.github.io/modelscloud/reference/connect_to_model.md)
when not explicitly supplied, so in a typical session you only need to
call `model_run()` with no arguments (or just `model_input`).

For asynchronous jobs the function returns immediately with a
`pexa_result_async` object. Use
[`get_async_results()`](https://resplab.github.io/modelscloud/reference/get_async_results.md)
to poll for completion.

## Usage

``` r
model_run(
  model_input = NULL,
  model_path = NULL,
  func_name = "model_run",
  access_key = NULL,
  server_url = NULL,
  async = NULL
)
```

## Arguments

- model_input:

  Named list (or data frame) of input parameters to pass to the model.
  This is the first positional argument, so `model_run(my_input)` works
  once
  [`connect_to_model()`](https://resplab.github.io/modelscloud/reference/connect_to_model.md)
  has been called. If `NULL` the model uses its own built-in defaults.

- model_path:

  Character. Model identifier in `"namespace/model"` format. Falls back
  to the value stored by
  [`connect_to_model()`](https://resplab.github.io/modelscloud/reference/connect_to_model.md).

- func_name:

  Character. The function within the model to invoke. Defaults to
  `"model_run"`.

- access_key:

  Character. API bearer token. Falls back to the stored key or the
  `MODELSCLOUD_ACCESS_KEY` environment variable.

- server_url:

  Character. Server base URL. Falls back to the stored URL.

- async:

  Logical. Run asynchronously? When `TRUE`, returns a job handle
  immediately; retrieve the result with
  [`get_async_results()`](https://resplab.github.io/modelscloud/reference/get_async_results.md).
  If left `NULL` (default), uses the session default set by
  [`connect_to_model()`](https://resplab.github.io/modelscloud/reference/connect_to_model.md)
  (itself `FALSE` unless changed).

## Value

The model output with its original R class preserved (e.g. a data
frame), deserialised from RDS format. The raw server response is
attached as an invisible attribute, which
[`get_plots()`](https://resplab.github.io/modelscloud/reference/get_plots.md)
uses to retrieve any plots the model produced.

## See also

[`connect_to_model()`](https://resplab.github.io/modelscloud/reference/connect_to_model.md),
[`get_plots()`](https://resplab.github.io/modelscloud/reference/get_plots.md),
[`get_async_results()`](https://resplab.github.io/modelscloud/reference/get_async_results.md)

## Examples

``` r
if (FALSE) { # \dontrun{
connect_to_model("examples/toymodel2", access_key = "YOUR_KEY")

# Run with model defaults
result <- model_run()

# Run with custom inputs
result <- model_run(model_input = list(time_horizon = 15, discount_rate = 0.03))

# Override async for a single call
job <- model_run(async = TRUE)
result <- get_async_results(job)
} # }
```
