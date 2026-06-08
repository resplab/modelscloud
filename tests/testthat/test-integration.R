# Integration tests — require a live server and valid token.
# Set MODELSCLOUD_ACCESS_KEY in .Renviron to run these.

# Reset cache to a known clean state — unit tests in test-connect.R may have
# left it with bad values (e.g. server_url = "not-a-url").
local({
  cache <- getFromNamespace(".pkg_cache", "modelscloud")
  cache$server_url <- "https://api.modelscloud.resp.core.ubc.ca/"
  cache$model_path <- NULL
  cache$access_key <- NULL
  cache$async      <- FALSE
})

MODEL_PATH <- "mohsenss/qrisk3pexa"

skip_if_no_token <- function() {
  skip_if(
    Sys.getenv("MODELSCLOUD_ACCESS_KEY") == "",
    "MODELSCLOUD_ACCESS_KEY not set — skipping integration tests"
  )
}


# ── Approach 1: connect_to_model() first, then bare calls ────────────────────

test_that("get_sample_input() works after connect_to_model()", {
  skip_if_no_token()

  connect_to_model(MODEL_PATH)
  result <- get_sample_input()

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_sample_input(n=) returns correct number of rows", {
  skip_if_no_token()

  connect_to_model(MODEL_PATH)
  result <- get_sample_input(n = 3)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 3)
})

test_that("model_run() works after connect_to_model()", {
  skip_if_no_token()

  connect_to_model(MODEL_PATH)
  sample <- get_sample_input(n = 1)
  result <- model_run(model_input = sample)

  expect_s3_class(result, "data.frame")
  expect_true("QRISK3_2017" %in% names(result))
})

test_that("get_default_input() works after connect_to_model()", {
  skip_if_no_token()
  skip("requires qrisk3pexa redeployment — get_default_input() not yet on server")

  connect_to_model(MODEL_PATH)
  result <- get_default_input()

  expect_false(is.null(result))
})


# ── Approach 2: supply model_path and access_key directly (no connect) ────────

test_that("get_sample_input() works with explicit arguments", {
  skip_if_no_token()

  result <- get_sample_input(
    model_path = MODEL_PATH,
    access_key = Sys.getenv("MODELSCLOUD_ACCESS_KEY")
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("model_run() works with explicit arguments", {
  skip_if_no_token()

  ak <- Sys.getenv("MODELSCLOUD_ACCESS_KEY")

  sample <- get_sample_input(model_path = MODEL_PATH, access_key = ak, n = 1)
  result <- model_run(model_path = MODEL_PATH, model_input = sample,
                      access_key = ak)

  expect_s3_class(result, "data.frame")
  expect_true("QRISK3_2017" %in% names(result))
})


# ── Approach 3: connect_to_model() for credentials, override model_path ───────

test_that("model_run() honours model_path override over stored value", {
  skip_if_no_token()

  # Connect to a dummy path — model_path arg should override it
  connect_to_model("dummy/model",
                   access_key = Sys.getenv("MODELSCLOUD_ACCESS_KEY"))

  sample <- get_sample_input(model_path = MODEL_PATH)
  result <- model_run(model_path = MODEL_PATH, model_input = sample)

  expect_s3_class(result, "data.frame")
})


# ── Full round-trip: get_sample_input |> model_run ───────────────────────────

test_that("model_run(get_sample_input()) round-trip works", {
  skip_if_no_token()

  connect_to_model(MODEL_PATH)
  result <- model_run(get_sample_input())   # positional — the intended usage

  expect_s3_class(result, "data.frame")
  expect_true("QRISK3_2017" %in% names(result))
  expect_true(all(result$QRISK3_2017 >= 0 & result$QRISK3_2017 <= 100))
})
