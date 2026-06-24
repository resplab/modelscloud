# Retrieve Plots Produced by a Model Run

Models hosted on ModelsCloud can generate plots as side-outputs during a
run (e.g. a barplot of predicted risks). `get_plots()` *retrieves* those
plots from the server; it does not draw them. To display a retrieved
plot, call [`plot()`](https://rdrr.io/r/graphics/plot.default.html) on
it (an S3 `plot` method renders the image).

Pass the object returned by
[`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md)
directly — the server connection details are carried along
automatically.

Called with no `id`, `get_plots()` lists all available plots and returns
a summary data frame. Called with an `id`, it returns that plot's image.

## Usage

``` r
get_plots(result, id = NULL, access_key = NULL, server_url = NULL)
```

## Arguments

- result:

  The object returned by
  [`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md).

- id:

  Integer or character. Which plot to retrieve. Use the `id` column from
  the listing (no-argument) call to find valid values. If `NULL`
  (default), returns a data frame listing all available plots.

- access_key:

  Character. API bearer token. Falls back to the stored key or the
  `MODELSCLOUD_ACCESS_KEY` environment variable.

- server_url:

  Character. Server base URL. Falls back to the stored URL.

## Value

If `id = NULL`: a data frame summarising available plots (one row per
plot). If `id` is supplied: the plot image object, which you display
with [`plot()`](https://rdrr.io/r/graphics/plot.default.html).

## See also

[`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# toymodel1's model_run() draws a barplot, captured server-side by OpenCPU.
connect_to_model("examples/toymodel1", access_key = "YOUR_KEY")
result <- model_run(get_sample_input())

# See what plots are available
get_plots(result)

# Retrieve the first plot, then display it
img <- get_plots(result, id = 1)
plot(img)
} # }
```
