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

```r
library(modelscloud)

# Connect once — stores your key and the model path for the rest of the session
connect_to_model("mohsenss/qrisk3pexa", access_key = "YOUR_API_KEY")

# Get a sample input from the model
sample <- get_sample_input()

# Run the model — model_input is the first argument, so this just works
result <- model_run(sample)
print(result)
```

API keys can be obtained from the [ModelsCloud platform](https://modelscloud.resp.core.ubc.ca/).

---

## Core functions

| Function | Description |
|---|---|
| `connect_to_model()` | **(Optional)** Store model path, API key, and connection settings for the session |
| `model_run()` | Execute the model and return results |
| `get_sample_input()` | Retrieve an example input dataset from the model |
| `get_default_input()` | Retrieve the model's built-in default inputs |

`connect_to_model()` is optional but recommended — once called, all subsequent functions inherit the stored model path and API key so you don't have to repeat them.

---

## Usage patterns

### Pattern 1 — connect once, call freely (recommended)

Call `connect_to_model()` at the top of your script with your key and the model you want to use. Every subsequent call picks up those stored values automatically.

```r
connect_to_model("mohsenss/qrisk3pexa", access_key = "YOUR_API_KEY")

sample  <- get_sample_input()
default <- get_default_input()
result  <- model_run(sample)       # model_input is first — no keyword needed
```

### Pattern 2 — supply credentials on every call (no connect needed)

You can skip `connect_to_model()` entirely and pass `model_path` and `access_key` directly to each function. Useful for one-off calls or when you prefer explicit control.

```r
ak <- "YOUR_API_KEY"
mp <- "mohsenss/qrisk3pexa"

sample <- get_sample_input(model_path = mp, access_key = ak)
result <- model_run(model_path = mp, model_input = sample, access_key = ak)
```

---

## Example: QRISK3 cardiovascular risk model

[QRISK3](https://qrisk.org/) estimates an individual's 10-year risk of developing cardiovascular disease.

```r
library(modelscloud)

connect_to_model("mohsenss/qrisk3pexa", access_key = "YOUR_API_KEY")

# Get the full sample dataset
patients <- get_sample_input()
head(patients)
#>   patid gender age atrial_fibrillation weight height ...
#> 1     1      1  64                   0     80    178 ...

# Run on all patients
results <- model_run(patients)
head(results[, c("ID", "QRISK3_2017")])
#>   ID QRISK3_2017
#> 1  1    17.22985
#> 2  2    36.01234

# Run on a subset
results_5 <- model_run(get_sample_input(n = 5))
```

---

## How it works

`modelscloud` is a thin wrapper around [`pexaclient`](https://github.com/resplab/pexaclient), which handles HTTP communication with the ModelsCloud API. Results travel over the wire as RDS (R's native binary format), so object classes are fully preserved — what the model returns on the server is exactly what you receive in your R session.

```
modelscloud          pexaclient           ModelsCloud API        model package
────────────         ──────────           ───────────────        ─────────────
model_run()    →   function_call()   →   POST /call/{model}  →  model_run()
                                    ←   RDS response        ←  data.frame
               ←   raw bytes        ←
     result    ←   readRDS()
```

---

## Related packages

| Package | Role |
|---|---|
| [`pexaclient`](https://github.com/resplab/pexaclient) | Low-level HTTP client for the ModelsCloud API |
| [`qrisk3pexa`](https://github.com/resplab/qrisk3pexa) | QRISK3 model wrapper deployed on ModelsCloud |

---

## License

GPL-3 © [Mohsen Sadatsafavi](mailto:mohsen.sadatsafavi@ubc.ca), RESP Lab, UBC
