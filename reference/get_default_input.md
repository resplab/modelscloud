# Get the Default Input for a Model

Retrieves the default input values that the model uses when no custom
input is supplied to
[`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md).
Useful for discovering what parameters a model accepts and inspecting
their baseline values before customising a run.

All arguments fall back to the values stored by
[`connect_to_model()`](https://resplab.github.io/modelscloud/reference/connect_to_model.md)
when not explicitly supplied.

## Usage

``` r
get_default_input(model_path = NULL, access_key = NULL, server_url = NULL)
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

## Value

The default input object as returned by the model, with its original R
class preserved.

## See also

[`connect_to_model()`](https://resplab.github.io/modelscloud/reference/connect_to_model.md),
[`get_sample_input()`](https://resplab.github.io/modelscloud/reference/get_sample_input.md),
[`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md)

## Examples

``` r
if (FALSE) { # \dontrun{
connect_to_model("examples/toymodel2", access_key = "YOUR_KEY")
defaults <- get_default_input()
str(defaults)
} # }
```
