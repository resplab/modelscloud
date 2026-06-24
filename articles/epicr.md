# Example: EPIC-R COPD policy model

This vignette shows `modelscloud` against a **real** policy model:
[EPIC](https://www.ubcresplab.ca/epic), a whole-disease microsimulation
of chronic obstructive pulmonary disease (COPD). It is served as
`resplab/epicr`, a wrapper around the `epicR` package.

Where QRISK3 (see the other example vignette) is a quick prediction
model, EPIC is a simulation whose runtime grows with the number of
simulated agents — so it is a natural fit for **asynchronous**
execution.

This model is outside the public `examples` collection, so you’ll need
your own API key.

``` r

library(modelscloud)

connect_to_model("resplab/epicr", access_key = "YOUR_API_KEY")
```

## Default input

Policy models don’t take a patient dataset; they take a set of
parameters.
[`get_default_input()`](https://resplab.github.io/modelscloud/reference/get_default_input.md)
returns a ready-to-use `model_input` — a named list whose `input`
element holds EPIC’s default parameter set:

``` r

mi <- get_default_input()
names(mi)
#> [1] "input"

mi$input$global_parameters$time_horizon
#> [1] 20
```

You adjust this list and pass it to
[`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md).
Scalar controls of the underlying simulation — such as `n_agents`,
`seed`, `time_horizon` — are set as top-level elements of `model_input`;
the server expands them onto the simulator.

## A light run (synchronous)

With a modest agent count the model returns quickly, so a plain call
works:

``` r

mi <- get_default_input()
mi$n_agents <- 1000

result <- model_run(mi)
result$basic$total_qaly
```

[`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md)
returns a list with a `$basic` summary (and `$extended` if you request
it by setting `mi$extended_results <- TRUE`).

## A large run (asynchronous)

For a realistic policy run — say ten million agents — submit the job
with `async = TRUE` and retrieve it when it finishes:

``` r

mi <- get_default_input()
mi$n_agents <- 1e7

job    <- model_run(mi, async = TRUE)            # returns immediately
result <- get_async_results(job, wait = TRUE,    # block & poll until done
                            timeout = 3600)
result$basic$total_qaly
```

To **check progress** without blocking, call `get_async_results(job)` on
its own: it returns the finished result if the run is done, or the job
handle unchanged if it is still running.

``` r

res <- get_async_results(job)
if (inherits(res, "pexa_result_async")) message("still running")
```

See the *Synchronous and asynchronous model runs* vignette for the full
async workflow (manual polling loops, timeouts, session defaults).
