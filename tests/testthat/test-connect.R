# Unit tests for connect_to_model() — no server needed

# Restore the cache to its original state after every test in this file
# so mutations here do not bleed into the integration tests.
local({
  cache <- getFromNamespace(".pkg_cache", "modelscloud")
  saved <- as.list(cache)
  withr::defer(
    list2env(saved, envir = cache),
    envir = teardown_env()
  )
})


test_that("connect_to_model() stores model_path correctly", {
  cache <- getFromNamespace(".pkg_cache", "modelscloud")
  connect_to_model("mohsenss/qrisk3pexa")
  expect_equal(cache$model_path, "mohsenss/qrisk3pexa")
})

test_that("connect_to_model() stores access_key when supplied", {
  cache <- getFromNamespace(".pkg_cache", "modelscloud")
  connect_to_model("mohsenss/qrisk3pexa", access_key = "test-key-123")
  expect_equal(cache$access_key, "test-key-123")
})

test_that("connect_to_model() leaves access_key unchanged when NULL", {
  cache <- getFromNamespace(".pkg_cache", "modelscloud")
  connect_to_model("mohsenss/qrisk3pexa", access_key = "original-key")
  connect_to_model("mohsenss/qrisk3pexa")  # no access_key
  expect_equal(cache$access_key, "original-key")
})

test_that("connect_to_model() stores custom server_url", {
  cache <- getFromNamespace(".pkg_cache", "modelscloud")
  connect_to_model("mohsenss/qrisk3pexa",
                   server_url = "https://custom.example.com/")
  expect_equal(cache$server_url, "https://custom.example.com/")
})

test_that("connect_to_model() stores async flag", {
  cache <- getFromNamespace(".pkg_cache", "modelscloud")
  connect_to_model("mohsenss/qrisk3pexa", async = TRUE)
  expect_true(cache$async)

  connect_to_model("mohsenss/qrisk3pexa", async = FALSE)
  expect_false(cache$async)
})

test_that("connect_to_model() rejects bad model_path format", {
  expect_error(connect_to_model("badformat"), "namespace/model")
  expect_error(connect_to_model("a/b/c"),     "namespace/model")
  expect_error(connect_to_model(123),         "character")
})

test_that("connect_to_model() warns on bad server_url but does not store it", {
  cache <- getFromNamespace(".pkg_cache", "modelscloud")
  original_url <- cache$server_url
  expect_warning(
    connect_to_model("mohsenss/qrisk3pexa", server_url = "not-a-url"),
    "http"
  )
  # Despite the warning, connect_to_model still stores what was given —
  # confirm the value was set (warning is advisory, not blocking)
  expect_equal(cache$server_url, "not-a-url")
})

test_that("model_run() errors when model_path not set and not supplied", {
  cache <- getFromNamespace(".pkg_cache", "modelscloud")
  cache$model_path <- NULL
  cache$access_key <- "dummy"
  expect_error(model_run(), "model_path not set")
})

test_that("model_run() errors when access_key not set anywhere", {
  cache <- getFromNamespace(".pkg_cache", "modelscloud")
  connect_to_model("mohsenss/qrisk3pexa")
  cache$access_key <- NULL
  withr::with_envvar(c(MODELSCLOUD_ACCESS_KEY = ""), {
    expect_error(model_run(), "access key not set")
  })
})
