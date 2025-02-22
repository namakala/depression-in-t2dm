# Functions to deduplicate the search

readBib <- function(filepath, ...) {
  #' Read Bibliography
  #'
  #' Read bilbiography file, supporting plain text, csv, or bibtex as
  #' documented in https://www.bibliometrix.org/vignettes/Data-Importing-and-Converting.html
  #'
  #' @param filepath A relative path to access the file, complete with the file
  #' name. It is recommended to have the file named after the database source,
  #' e.g. pubmed.txt or scopus.csv (case insensitive).
  #' @inheritDotParams bibliometrix::convert2df
  #' @return A data frame of `bibliometrixDB` class
  require("bibliometrix")

  if (length(filepath) > 1) {
    bib <- lapply(filepath, readBib, ...)
  } else {
    bib <- synthesisr::read_ref(filepath) |> tibble::tibble()
  }

  return(bib)
}

dedup <- function(bib, ...) {
  #' Deduplicate Data Frame
  #'
  #' Deduplicated bibliometric data frame obtained from
  #' `bibliometrix::convert2df`
  #'
  #' @param bib A bibliometric data frame
  #' @inheritDotParams base::duplicated
  #' @return A deduplicated data frame

  # Find duplicates based on DOI and title
  dup_doi   <- duplicated(bib$doi)
  dup_title <- duplicated(bib$title)
  id        <- dup_doi | dup_title

  # Remove duplicates, prioritize preserving the complete entry
  sub_bib   <- subset(bib, !id)

  return(sub_bib)
}

flatten <- function(tbl, ref, varname, ...) {
  #' Flatten the Data Frame
  #'
  #' Flatten the data frame by grouping and collapsing target column. The data
  #' frame should only contain two columns, as this function is not well tested
  #' on larger data frames.
  #'
  #' @param tbl A data frame
  #' @param ref A character vector signifying the name of reference column for
  #' grouping
  #' @param varname A character vector signifying the name of column to flatten
  #' @inheritDotParams base::paste
  #' @return A tidy data frame

  res <- tbl %>%
    tibble::tibble() %>%
    dplyr::group_by(get(ref)) %>%
    dplyr::summarize(varname = paste(get(varname), ...)) %>%
    set_colnames(c(ref, varname))

  return(res)
}

mergeByDOI <- function(tbls) {
  #' Merge By DOI
  #'
  #' Merge a list of tidy data frames by the column DOI
  #'
  #' @param tbls A list of tidy data frames
  #' @return A tidy data frame with the DOI column
  tbl <- purrr::reduce(
    .f = \(x, y) dplyr::inner_join(x, y, by = "doi", suffix = c("1", "2")),
    .x = tbls
  )

  return(tbl)
}

# Dummy functions

dedup_update <- function() {
  #' Deduplicate updated search
  #'
  #' This is a dummy function to prevent the following lines from running when
  #' updating `targets`.

  ref <- "data/raw/update.ris"
  bib <- readBib(ref)
  bib_dedup <- dedup(bib) |> subset(year >= 2023) |> data.frame()
  synthesisr::write_refs(bib_dedup, format = "ris", file = "data/processed/update.ris")

}
