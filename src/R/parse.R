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
        {ifelse(grepl(x = ., "(^US|Carolin|Califor|Maryland|Chicago|Texa)", ignore.case = TRUE), "United States of America", .)} %>%
        {ifelse(is.na(.) | grepl(x = ., "-|report|multic|unavail", ignore.case = TRUE), "Global", .)} %>%
        {ifelse(grepl(x = ., "Netherlands", ignore.case = TRUE), "Netherlands", .)} %>%
        {ifelse(grepl(x = ., "UK|England|Scotla"), "United Kingdom", .)} %>%
        {ifelse(grepl(x = ., "China"), "China", .)} %>%
        {ifelse(grepl(x = ., "India"), "India", .)} %>%
        {ifelse(grepl(x = ., "Saudi"), "Saudi Arabia", .)} %>%
        {ifelse(grepl(x = ., "Russia"), "Russian Federation", .)} %>%
        {ifelse(grepl(x = ., "Iran"), "Iran (Islamic Republic of)", .)} %>%
        {ifelse(grepl(x = ., "Korea"), "Republic of Korea", .)} %>%
        {ifelse(grepl(x = ., "Gaza"), "Palestine", .)} %>%
        {ifelse(grepl(x = ., "Taiwan"), "Taiwan (Province of China)", .)} %>%
        {ifelse(grepl(x = ., "Austral"), "Australia", .)} %>%
        {ifelse(grepl(x = ., "Kosovo"), "Serbia", .)} %>%
        {ifelse(grepl(x = ., "Pakista"), "Pakistan", .)} %>%
        {ifelse(grepl(x = ., "Viet"), "Viet Nam", .)} %>%
        {ifelse(grepl(x = ., "UAE"), "United Arab Emirates", .)} %>%
        {ifelse(grepl(x = ., "Malaysia"), "Malaysia", .)}
    }) %>%
    inset2("clean_instrument", value = {
      gsub(x = .$instrument, "\\s+([<>].*|&.*|\\n)", "") %>%
        {ifelse(grepl(x = ., "PHQ", ignore.case = TRUE), "PHQ", .)} %>%
        {ifelse(grepl(x = ., "BDI", ignore.case = TRUE), "BDI", .)} %>%
        {ifelse(grepl(x = ., "PHQ|BDI"), ., "Others")}
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

readGBD <- function(path, ctry_list, ...) {
  #' Read GBD data
  #'
  #' Read GBD data from a specified path
  #'
  #' @param path Relative path of the file
  #' @param ctry_list A vector of country names
  #' @inheritDotParams readr::read_csv()
  #' @return A tibble data frame

  # Parse and subset the data frame
  tbl <- readr::read_csv(path, ...) %>%
    inset2("se", value = {.$upper - .$val} / 1.96)

  sub_tbl <- tbl %>%
    subset(
      {.$location_name %in% unique(ctry_list)} &
        .$sex_name    == "Both" &
        .$age_name    == "All ages" &
        .$metric_name == "Percent",
      select = c("year", "location_name", "cause_name", "val", "se")
    )

  # Clean the cause name (diagnosis) variable
  tbl_clean <- sub_tbl %>% inset2("cause_name", value = {
    .$cause_name %>% {dplyr::case_when(
      . == "Diabetes mellitus type 1"  ~ "gbd_t1dm",
      . == "Diabetes mellitus type 2"  ~ "gbd_t2dm",
      . == "Diabetes mellitus"         ~ "gbd_dm",
      . == "Major depressive disorder" ~ "gbd_mdd",
      .default = "gbd_other"
    )}
  })
  
  # Reshape into a wide table
  tbl_wide <- tbl_clean %>%
    tidyr::pivot_wider(names_from = "cause_name", values_from = c("val", "se"))

  return(tbl_wide)
}

mergeGBD <- function(tbl, tbl_gbd, ...) {
  #' Merge GBD
  #'
  #' Merge extracted information with GBD data
  #'
  #' @param tbl A data frame of extracted information from primary studies
  #' @param tbl_gbd A data frame of GBD data
  #' @inheritDotParams base::merge
  #' @return A merged data frame
  tbl_merge <- merge(
    tbl, tbl_gbd,
    by.x = c("incl_year", "clean_country"),
    by.y = c("year", "location_name"),
    ...
  ) %>%
    tibble::tibble()

  tbl_rr <- tbl_merge %>%
    inset("rr_mdd", value = as.numeric(.$prev_diabet) / .$val_gbd_mdd)

  return(tbl_rr)
}
