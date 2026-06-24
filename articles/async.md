# Synchronous and asynchronous model runs

``` r

library(modelscloud)

# Public test key for the `examples` collection
KEY <- "23b7bab3-118e-4516-b53c-91bca8e0082d"
```

## Two ways to run a model

Some ModelsCloud models can be executed in either of two modes:

- **Synchronous** (the default): you call
  [`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md)
  and R **blocks** until the server finishes, then hands you the result.
  Simple, and ideal for quick models.
- **Asynchronous**: `model_run(async = TRUE)` **returns immediately**
  with a lightweight *job handle*. The model keeps running on the server
  while your R session is free to do other things. You fetch the result
  later with
  [`get_async_results()`](https://resplab.github.io/modelscloud/reference/get_async_results.md).

Async exists for long-running models — policy simulations, large agent
counts, anything that might take minutes. Blocking an interactive
session (or hitting an HTTP timeout) on such a run is painful;
submitting it as a job is not.

This vignette uses `examples/toymodel2`, a toy policy/economic
microsimulation whose runtime scales with the number of simulated agents
— so it can be run either way.

``` r

connect_to_model("examples/toymodel2", access_key = KEY)
```

## Synchronous: the baseline

Nothing special is required. With the default (small) agent count the
model returns quickly, so a plain blocking call is all you need:

``` r

input  <- get_default_input()    # n_agents = 1000
result <- model_run(input)       # blocks until the server is done
result$total_qaly
```

This is fine when the model returns in a few seconds. For a much larger
run it won’t be — which is where async comes in.

## Asynchronous: submit, then retrieve

Set `async = TRUE`.
[`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md)
returns a **job handle** right away:

``` r

input <- get_default_input()
input$n_agents <- 1e7            # ten million agents — a long run

job <- model_run(input, async = TRUE)
#> Async job submitted (executionId: 6a2a...). Retrieve it with get_async_results().

class(job)
#> [1] "pexa_result_async" "pexa_result"
```

`job` is *not* your result — it is a receipt. Pass it to
[`get_async_results()`](https://resplab.github.io/modelscloud/reference/get_async_results.md)
to fetch the actual output once the server has finished.

### Option A — block until it’s done (`wait = TRUE`)

The simplest pattern.
[`get_async_results()`](https://resplab.github.io/modelscloud/reference/get_async_results.md)
polls the server for you and returns only when the job is complete:

``` r

result <- get_async_results(job, wait = TRUE)
result$total_qaly
```

You can do the whole thing in one line:

``` r

result <- get_async_results(model_run(input, async = TRUE), wait = TRUE)
```

`wait = TRUE` polls every `interval` seconds (default 2) up to `timeout`
seconds (default 300). If the timeout is reached the job handle is
returned with a warning, so you can keep polling rather than losing the
job:

``` r

# Wait up to an hour, checking every 10 seconds
result <- get_async_results(job, wait = TRUE, interval = 10, timeout = 3600)
```

### Option B — check once, poll manually

By default (`wait = FALSE`)
[`get_async_results()`](https://resplab.github.io/modelscloud/reference/get_async_results.md)
checks **once** and returns immediately:

- if the job has finished, you get the decoded result;
- if it is still running, you get the job handle back, unchanged.

This is how you **check progress** without blocking — do other work
between checks, or drive your own polling loop:

``` r

result <- get_async_results(job)            # one check

while (inherits(result, "pexa_result_async")) {
  message("still running...")
  Sys.sleep(5)
  result <- get_async_results(job)          # check again
}

result$total_qaly                           # finished
```

The test `inherits(result, "pexa_result_async")` is how you tell “still
a job handle” from “this is the finished result”.

## Choosing the mode per call vs. for the session

`async` is decided **per call** on
[`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md).
You do not need to reconnect to switch modes:

``` r

quick <- model_run(get_default_input())                       # sync
job   <- model_run(within(get_default_input(),
                          { n_agents <- 1e7 }), async = TRUE)  # async
```

If most of your runs are long, set async as the **session default** with
[`connect_to_model()`](https://resplab.github.io/modelscloud/reference/connect_to_model.md),
and a bare
[`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md)
becomes asynchronous:

``` r

connect_to_model("examples/toymodel2", access_key = KEY, async = TRUE)

job <- model_run(input)             # async, because that's the session default
```

`connect_to_model(async = ...)` only sets the *default*. An explicit
argument on
[`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md)
always wins, so you can still force a single call back to sync:

``` r

result <- model_run(input, async = FALSE)   # sync, despite the async default
```

The resolution order is:
**[`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md)’s
`async` argument → session default from
[`connect_to_model()`](https://resplab.github.io/modelscloud/reference/connect_to_model.md)
→ `FALSE`**.

## Cheat sheet

| Task                           | Call                                  |
|--------------------------------|---------------------------------------|
| Run and wait                   | `model_run(x)`                        |
| Submit a job                   | `job <- model_run(x, async = TRUE)`   |
| Block until done               | `get_async_results(job, wait = TRUE)` |
| Check once (non-blocking)      | `get_async_results(job)`              |
| Is it still running?           | `inherits(res, "pexa_result_async")`  |
| Make async the session default | `connect_to_model(..., async = TRUE)` |
| Force one call back to sync    | `model_run(x, async = FALSE)`         |

## See also

- [`?model_run`](https://resplab.github.io/modelscloud/reference/model_run.md)
- [`?get_async_results`](https://resplab.github.io/modelscloud/reference/get_async_results.md)
- [`?connect_to_model`](https://resplab.github.io/modelscloud/reference/connect_to_model.md)
- The **Example: EPIC-R** vignette — async on a real COPD policy model.
