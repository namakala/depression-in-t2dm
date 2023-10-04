# Functions to parse and manipulate the data

readData <- function(path, ...) {
  #' Read Data
  #'
  #' Read the file as tibble data frame
  #'
  #' @param path Relative path of the file
  #' @inheritDotParams readr::read_csv()
  #' @return A tibble data frame
  tbl <- readr::read_csv(file = path, ...) %>%
    cleanData() %>%
    subset(!is.na(.$incl_year)) %>%
    inset2("author_year", value = sprintf(
      "%s (%s)", gsub(x = .$author, "^(\\w+).*", "\\1"), .$year
    )) %>%
    inset2("incl_author_year", value = sprintf(
      "%s (%s)", gsub(x = .$incl_author, "^(\\w+).*", "\\1"), .$incl_year
    ))

  return(tbl)
}

cleanData <- function(tbl) {
  #' Clean Data
  #'
  #' Clean the provided tibble of extracted studies
  #'
  #' @param tbl A data frame object containing extracted studies
  #' @return A table with clean variables
  tbl_clean <- tbl %>%
    inset2("incl_year", value = as.numeric(.$incl_year)) %>%
    inset2("clean_criteria", value = .$criteria %>% {ifelse(
      grepl(x = ., "(interview|diagnosis|history|medical)"),
      "Clinical Diagnosis",
      "Self Report"
    )}) %>%
    inset2("clean_country", value = {
      .$country %>%
        ifelse(grepl(x = ., "(^US|Carolin|Califor|Maryland|Chicago)", ignore.case = TRUE), "USA", .) %>%
        ifelse(is.na(.) | grepl(x = ., "-|report|multic|unavail", ignore.case = TRUE), "Global", .) %>%
        ifelse(grepl(x = ., "Netherlands", ignore.case = TRUE), "Netherlands", .) %>%
        ifelse(grepl(x = ., "UK|England"), "UK", .) %>%
        ifelse(grepl(x = ., "China"), "China", .) %>%
        ifelse(grepl(x = ., "Saudi"), "Saudi Arabia", .) %>%
        ifelse(grepl(x = ., "Korea"), "South Korea", .) %>%
        ifelse(grepl(x = ., "Malaysia"), "Malaysia", .)
    }) %>%
    inset2("clean_instrument", value = {
      gsub(x = .$instrument, "\\s+([<>].*|&.*|\\n)", "") %>%
        ifelse(grepl(x = ., "Zung|ZSDS", ignore.case = TRUE), "ZRDS", .) %>%
        ifelse(grepl(x = ., "MR|History|Record|Note|diag|prescrip|schedule", ignore.case = TRUE), "Medical Records", .) %>%
        ifelse(is.na(.) | grepl(x = ., "not|specified|N/A", ignore.case = TRUE), "Not Reported", .)
    })

  return(tbl_clean)
}

deduplicate <- function(tbl) {
  #' Deduplicate Extracted Data
  #'
  #' Remove duplicated primary studies from the included systematic reviews
  #'
  #' @param tbl A data frame object containing extracted studies
  tbl %<>% inset2("id", value = paste(
    stringr::str_to_upper(.$incl_author_year),
    .$n_total,
    round(as.numeric(.$prev_diabet), 2)
  )) %>%
    inset2("anomaly", value = isAnomaly(., colyear = "incl_year", numyear = 5))

  tbl_clean <- tbl %>% subset(!duplicated(.$id))

  return(tbl_clean)
}

isAnomaly <- function(tbl, colyear, numyear = 5, varname = "prev_diabet") {
  #' Detect Anomalous Entry
  #'
  #' Detect anomaly based on year-based rolling window and IQR. This function
  #' will first create a time-based rolling window, then calculate the lower
  #' and upper 25 percentile. Values outside this range is regarded as an
  #' anomaly.
  #'
  #' @param tbl A data frame object containing extracted studies
  #' @param colyear Column name from `tbl` signifying the published year
  #' @param numyear An integer specifying the time frame of a rolling window
  #' @param varname Column name to check for anomalies
  #' @return A vector signifying entries with anomaly

  # Set start and stop values for the rolling window
  years <- tbl[[colyear]] |>
    unique() |>
    sort(decreasing = FALSE) %>%
    {tibble::tibble(
      "start" = .,
      "stop"  = . + numyear
    )} %>%
    subset(!.$stop > max(.$start))

  # Set lower and upper 25 percentile of the prevalence
  bounds <- apply(years, 1, function(windows) {
    tbl %>%
      subset(.[[colyear]] >= windows[[1]] & .[[colyear]] <= windows[[2]]) |>
      extract2(varname) |>
      as.numeric() |>
      quantile(c(0.25, 0.75), na.rm = TRUE)
  })

  # Detect anomaly based on lower and upper bounds
  res <- apply(tbl, 1, function(entry) {
    # Identify which  bounds to use
    year <- entry[[colyear]]
    id   <- with(years, year >= start & year <= stop)

    # Subset the bounds, 1 = 25%, 2 = 75%
    lo <- bounds[1, id]
    hi <- bounds[2, id]

    # Test for anomaly
    anomalies <- entry[[varname]] %>% {. < lo | . > hi}
    vote <- sum(anomalies) > ceiling(numyear / 2)

    return(vote)
  })

  return(res)
}
