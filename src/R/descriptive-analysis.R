# Functions to perform descriptive analysis on the extracted data

vizPair <- function(tbl, single_plot = FALSE, ...) {
  #' Visualize Pair Plot
  #'
  #' Generate a pair plot from the input table
  #'
  #' @param tbl A data frame of extracted results
  #' @param single_plot Boolean indicating whether to return only a single plot
  #' or a list of multple plots
  #' @inheritDotParams GGally::ggpairs
  #' @return A ggmatrix object
  require("ggplot2")

  varnames <- c("prev_diabet", "incl_year")
  itervars <- c("region", "clean_instrument", "quality") %>%
    set_names(., .)

  # Generate the plot
  plts <- lapply(itervars, function(itervar) {
    sub_tbl <- subset(tbl, select = c(varnames, itervar))
    GGally::ggpairs(
      sub_tbl,
      aes(color = get(itervar), alpha = 0.7),
      columns = 1:2,
      columnLabels = c("Prevalence", "Publication Year"),
      ...
    ) +
      labs(title = sprintf("Grouped by %s", itervar))
  })

  plt <- GGally::ggpairs(
    subset(tbl, select = c(varnames, itervars)),
    aes(color = region, alpha = 0.7)
  )

  if(single_plot) {
    return(plt)
  }

  return(plts)
}

tblSummary <- function(tbl, ...) {
  #' Table Summary
  #' 
  #' Create a table of summary statistics from the extracted data
  #' 
  #' @param tbl A data frame of extracted results
  #' @inheritDotParams gtsummary::tbl_summary
  #' @return A latex table
  require("gtsummary")

  varname <- c("prev_diabet", "region", "clean_instrument", "quality")
  sub_tbl <- subset(tbl, select = varname)

  # Generate the descriptive statistics table
  res <- tbl_summary(
    sub_tbl,
    by = quality,
    label = list(
      prev_diabet      ~ "Prevalence of Depression",
      region           ~ "WHO Region",
      clean_instrument ~ "Diagnosis"
    ),
    statistic = list(
      all_continuous()  ~ "{mean} [{sd}]",
      all_categorical() ~ "{n} ({p}%)"
    ),
    ...
  )

  return(res)
}
