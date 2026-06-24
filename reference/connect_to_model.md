# Connect to a ModelsCloud Model

Stores connection settings for the current R session. After calling this
function,
[`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md),
[`get_default_input()`](https://resplab.github.io/modelscloud/reference/get_default_input.md),
and
[`get_sample_input()`](https://resplab.github.io/modelscloud/reference/get_sample_input.md)
will use these stored values whenever their own arguments are not
explicitly supplied.

You only need to call this once per session. All settings are optional
except `model_path`.

## Usage

``` r
connect_to_model(
  model_path,
  access_key = NULL,
  server_url = NULL,
  async = FALSE
)
```

## Arguments

- model_path:

  Character. Model identifier in `"namespace/model"` format (e.g.,
  `"resp/epicr"`).

- access_key:

  Character. API bearer token. If `NULL`, the previously stored key (if
  any) is left unchanged. You can also set the `MODELSCLOUD_ACCESS_KEY`
  environment variable in your `.Renviron` to avoid passing this in
  scripts.

- server_url:

  Character. Base URL of the ModelsCloud server. Defaults to
  `"https://api.modelscloud.resp.core.ubc.ca/"` if never overridden.

- async:

  Logical. Sets only the *default* execution mode for the session. The
  actual choice is made per call by
  [`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md)'s
  own `async` argument; this just determines what
  [`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md)
  does when its `async` is left unspecified. Default is `FALSE`.

## Value

Invisibly returns the stored `model_path`.

## See also

[`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md),
[`get_default_input()`](https://resplab.github.io/modelscloud/reference/get_default_input.md),
[`get_sample_input()`](https://resplab.github.io/modelscloud/reference/get_sample_input.md)

## Examples

``` r
if (FALSE) { # \dontrun{
connect_to_model(
  model_path = "examples/toymodel1",
  access_key = "YOUR_API_KEY"
)

# Async by default, custom server
connect_to_model(
  model_path = "examples/toymodel2",
  access_key = "YOUR_API_KEY",
  server_url = "https://myserver.example.com/",
  async      = TRUE
)
} # }
```
