# Functions to parse and manipulate the data

readData <- function(path, ...) {
  #' Read Data
  #'
  #' Read the file as tibble data frame
  #'
  #' @param path Relative path of the file
  #' @inheritDotParams readr::read_csv()
  #' @return A tibble data frame
  tbl <- readr::read_csv(file = path, ...)

  return(tbl)
}

findCol <- function(tbl, regex, fetch = FALSE, ...) {
  #' Find Column
  #'
  #' Find variables in the column of a data frame using regular expression
  #'
  #' @param tbl A data frame object
  #' @param regex Regular expression pattern
  #' @inheritDotParams base::grep
  #' @return A vector of variable names or a subset of data frame
  labels  <- colnames(tbl)
  varname <- labels %>%
    extract(grep(x = ., regex))

  if (fetch) {
    sub_tbl <- subset(tbl, select = varname)
    return(sub_tbl)
  }

  return(varname)
}
