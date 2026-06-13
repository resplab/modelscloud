# modelscloud <img src="https://img.shields.io/badge/lifecycle-experimental-orange.svg" align="right"/>

An R interface for accessing models hosted on the [ModelsCloud](https://modelscloud.resp.core.ubc.ca/) platform — a cloud repository of health decision and prediction models developed by the [RESP Lab](https://resp.core.ubc.ca/) at UBC.

`modelscloud` provides a clean, session-based workflow: supply your API key and model once (via `connect_to_model()`), then call the model repeatedly without repeating credentials. Results are returned as native R objects (data frames, lists, etc.), with class information fully preserved across the network.

---

## Installation

```r
# Install from GitHub
remotes::install_github("resplab/modelscloud")
```

`modelscloud` depends on [`pexaclient`](https://github.com/resplab/pexaclient), which is installed automatically.

---

## Quick start

The examples below use the public **`examples`** collection — two minimal toy
models you can call with the shared public test key, no signup required.

```r
library(modelscloud)

# Connect once — stores the model path and key for the rest of the session.
# (Public test key for the examples collection.)
connect_to_model("examples/toymodel1",
                 access_key = "23b7bab3-118e-4516-b53c-91bca8e0082d")

# Get a sample input, then run the model
sample <- get_sample_input()
result <- model_run(sample)
print(result)
#>   sex age marker_value    risk
#> 1   0  55          1.2 0.05787
#> 2   1  62          2.4 0.27289
#> 3   1  48          0.7 0.04565
```

`toymodel1` is a toy **prediction** model (predicts a risk from `sex`, `age`,
`marker_value`). For your own models, get an API key from the
[ModelsCloud platform](https://modelscloud.resp.core.ubc.ca/).

---

## Core functions

| Function | Description |
|---|---|
| `connect_to_model()` | **(Optional)** Store model path, API key, and connection settings for the session |
| `model_run()` | Execute the model and return results |
| `get_sample_input()` | Retrieve an example input dataset from the model |
| `get_default_input()` | Retrieve the model's built-in default inputs |
| `get_async_results()` | Retrieve the result of an asynchronous run |

`connect_to_model()` is optional but recommended — once called, all subsequent functions inherit the stored model path and API key so you don't have to repeat them.

---

## Two ways to supply credentials

**Pattern 1 — connect once, call freely (recommended).** Every later call picks up the stored values.

```r
connect_to_model("examples/toymodel1",
                 access_key = "23b7bab3-118e-4516-b53c-91bca8e0082d")

sample <- get_sample_input()
result <- model_run(sample)        # model_input is first — no keyword needed
```

**Pattern 2 — supply credentials on every call.** Skip `connect_to_model()` entirely.

```r
ak <- "23b7bab3-118e-4516-b53c-91bca8e0082d"
mp <- "examples/toymodel1"

sample <- get_sample_input(model_path = mp, access_key = ak)
result <- model_run(model_path = mp, model_input = sample, access_key = ak)
```

---

## Synchronous and asynchronous runs

Quick models run **synchronously** — `model_run()` blocks and returns the
result. Heavier models (large simulations) can run **asynchronously**:
`model_run(async = TRUE)` returns immediately with a job handle, and you fetch
the result later with `get_async_results()`.

```r
connect_to_model("examples/toymodel2",
                 access_key = "23b7bab3-118e-4516-b53c-91bca8e0082d")

input <- get_default_input()
input$n_agents <- 1e7            # a large run

job    <- model_run(input, async = TRUE)      # returns at once
result <- get_async_results(job, wait = TRUE) # block and poll until done
result$total_qaly
```

`toymodel2` is a toy **policy/economic** model. See the *"Synchronous and
asynchronous model runs"* vignette for the full async workflow (manual polling,
progress checks, timeouts).

---

## Vignettes

| Vignette | Topic |
|---|---|
| **Getting started** | The basics with the `examples` toy models |
| **Synchronous and asynchronous model runs** | Sync vs async, polling, progress |
| **Example: QRISK3** | A real cardiovascular risk prediction model |
| **Example: EPIC-R** | A real COPD policy model (async + plots) |

```r
browseVignettes("modelscloud")
```

---

## How it works

`modelscloud` is a thin wrapper around [`pexaclient`](https://github.com/resplab/pexaclient), which handles HTTP communication with the ModelsCloud API. Results travel over the wire as RDS (R's native binary format), so object classes are fully preserved — what the model returns on the server is exactly what you receive in your R session.

```
modelscloud          pexaclient           ModelsCloud API        model package
────────────         ──────────           ───────────────        ─────────────
model_run()    →   function_call()   →   POST /call/{model}  →  model_run()
                                    ←   RDS response        ←  result
               ←   raw bytes        ←
     result    ←   readRDS()
```

---

## Related packages

| Package | Role |
|---|---|
| [`pexaclient`](https://github.com/resplab/pexaclient) | Low-level HTTP client for the ModelsCloud API |
| [`toymodel1`](https://github.com/resplab/toymodel1) | Toy prediction model (examples collection) |
| [`toymodel2`](https://github.com/resplab/toymodel2) | Toy policy/economic model (examples collection) |
| [`qrisk3pexa`](https://github.com/resplab/qrisk3pexa) | QRISK3 cardiovascular risk model |
| [`epicrpexa`](https://github.com/resplab/epicrpexa) | EPIC-R COPD policy model |

---

## License

GPL-3 © [Mohsen Sadatsafavi](mailto:mohsen.sadatsafavi@ubc.ca), RESP Lab, UBC
