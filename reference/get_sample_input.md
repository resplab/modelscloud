# Get a Sample Input for a Model

Retrieves a sample (example) set of inputs from the model on the server.
The result is deserialised from RDS format, so the original R object
class (e.g. data frame) is fully preserved.

All arguments fall back to the values stored by
[`connect_to_model()`](https://resplab.github.io/modelscloud/reference/connect_to_model.md)
when not explicitly supplied.

## Usage

``` r
get_sample_input(model_path = NULL, access_key = NULL, server_url = NULL, ...)
```

## Arguments

- model_path:

  Character. Model identifier in `"namespace/model"` format. Falls back
  to the value stored by
  [`connect_to_model()`](https://resplab.github.io/modelscloud/reference/connect_to_model.md).

- access_key:

  Character. API bearer token. Falls back to the stored key or the
  `MODELSCLOUD_ACCESS_KEY` environment variable.

- server_url:

  Character. Server base URL. Falls back to the stored URL.

- ...:

  Additional arguments passed to the model's `get_sample_input` function
  (e.g. `n = 5` to limit the number of rows returned).

## Value

The sample input object as returned by the model, with its original R
class preserved (typically a data frame).

## See also

[`connect_to_model()`](https://resplab.github.io/modelscloud/reference/connect_to_model.md),
[`get_default_input()`](https://resplab.github.io/modelscloud/reference/get_default_input.md),
[`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md)

## Examples

``` r
if (FALSE) { # \dontrun{
connect_to_model("examples/toymodel1", access_key = "YOUR_KEY")
sample <- get_sample_input()
result <- model_run(model_input = sample)
} # }
```
