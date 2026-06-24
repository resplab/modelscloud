# Example: QRISK3 cardiovascular risk model

This vignette shows `modelscloud` against a **real** deployed model:
[QRISK3](https://qrisk.org/), which estimates an individual’s 10-year
risk of developing cardiovascular disease. It is served as
`resplab/qrisk3`, a wrapper around the
[`QRISK3`](https://cran.r-project.org/package=QRISK3) R package.

Unlike the toy models in the *Getting started* vignette, this model
lives outside the public `examples` collection, so you’ll need your own
API key.

``` r

library(modelscloud)

connect_to_model("resplab/qrisk3", access_key = "YOUR_API_KEY")
```

## Sample input

QRISK3 takes a table of patients.
[`get_sample_input()`](https://resplab.github.io/modelscloud/reference/get_sample_input.md)
returns a ready-to-use example dataset (the `QRISK3` package’s bundled
test patients, with column names matching the model’s API):

``` r

patients <- get_sample_input()
head(patients)
#>   patid gender age atrial_fibrillation weight height ethiniciy ...
#> 1     1      1  64                   0     80    178         1 ...
#> 2     2      0  58                   1     72    165         1 ...

nrow(patients)
#> [1] 19
```

Pass `n` to get just the first few rows:

``` r

get_sample_input(n = 3)    # first 3 patients
```

## Running the model

[`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md)
predicts every patient in the input and returns a data frame with the
QRISK3 score columns added:

``` r

results <- model_run(patients)
head(results[, c("ID", "QRISK3_2017")])
#>   ID QRISK3_2017
#> 1  1    17.22985
#> 2  2    36.01234
#> 3  3     9.84512
```

Because the result is a native R data frame, you can summarise or plot
it locally as usual:

``` r

summary(results$QRISK3_2017)
hist(results$QRISK3_2017,
     main = "Predicted 10-year CVD risk", xlab = "QRISK3 score (%)")
```

## One-liner

[`get_sample_input()`](https://resplab.github.io/modelscloud/reference/get_sample_input.md)
feeds straight into
[`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md):

``` r

results <- model_run(get_sample_input())
```

QRISK3 is a prediction model: every call is **synchronous** —
[`model_run()`](https://resplab.github.io/modelscloud/reference/model_run.md)
returns the predictions directly. For a model that supports asynchronous
execution, see the *Example: EPIC-R* vignette.
