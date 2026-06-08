# Private session cache — one environment per loaded package namespace
.pkg_cache <- new.env(parent = emptyenv())

.pkg_cache$model_path <- NULL
.pkg_cache$access_key <- NULL
.pkg_cache$server_url <- "https://api.modelscloud.resp.core.ubc.ca/"
.pkg_cache$async      <- FALSE
