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
    inset2("author_year", value = sprintf(
      "%s (%s)", gsub(x = .$author, "^(\\w+).*", "\\1"), .$year
    )) %>%
    inset2("incl_author_year", value = sprintf(
      "%s (%s)", gsub(x = .$incl_author, "^(\\w+).*", "\\1"), .$incl_year
    )) %>%
    cleanData()

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
    inset2("clean_criteria", value = .$criteria %>% {ifelse(
      grepl(x = ., "(interview|diagnosis|history|medical)"),
      "Clinical Diagnosis",
      "Self Report"
    )}) %>%
    inset2("clean_country", value = {
      .$country %>%
        ifelse(grepl(x = ., "(^US|Carolin|Califor)", ignore.case = TRUE), "USA", .) %>%
        ifelse(is.na(.) | grepl(x = ., "-"), "Global", .) %>%
        ifelse(grepl(x = ., "Netherlands", ignore.case = TRUE), "Netherlands", .) %>%
        ifelse(grepl(x = ., "UK|England"), "UK", .) %>%
        ifelse(grepl(x = ., "China"), "China", .) %>%
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
  ))

  tbl_clean <- tbl %>% subset(!duplicated(.$id))

  return(tbl_clean)
}
