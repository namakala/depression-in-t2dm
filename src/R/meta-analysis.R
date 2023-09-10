# Functions to conduct meta-analysis

finder <- function(regex) {
  #' Find ES Type
  #'
  #' Find the type of effect size when calculating the standard error
  #'
  #' @param type Type of effect size, such as proportion, prevalence, mean,
  #' etc.
  #' @return Standardized type of effect size
  estype <- list(
    "prop" = c("proportion", "prevalence"),
    "mean" = c("mean", "average", "SMD", "MD"),
    "corr" = c("correlation", "pearson"),
    "odds" = c("odds", "logit")
  )

  id <- grep(x = estype, pattern = regex, ignore.case = TRUE)

  if(length(id) > 0) {
    type <- names(estype)[id]
    return(type)
  }

  return(estype)
}

calcSE <- function(params, type = "prop") {
  #' Calculate SE
  #'
  #' Calculate standard error from the given effect size based on
  #' https://bookdown.org/MathiasHarrer/Doing_Meta_Analysis_in_R/effects.html
  #'
  #' @param params A list of parameters required to compute the effect size
  #' @param type Type of effect size
  #' @return An array of standard error
  params %<>% lapply(as.numeric)
  type   %<>% finder()

  if (type == "prop") {
    p  <- params$p
    n  <- params$n
    se <- sqrt({p * (1 - p)} / n)
  } else {
    se <- NULL
  }

  return(se)
}

poolES <- function(tbl, ...) {
  #' Pool Effect Size
  #'
  #' Pool the effect size for meta-analysis
  #'
  #' @param tbl A data frame containing extracted information
  #' @inheritDotParams meta::metagen
  #' @return Pooled effect size using `meta` package
  params <- with(tbl, list("n" = n_diabet, "p" = prev_diabet))
  res    <- meta::metagen(
    TE = as.numeric(prev_diabet),
    seTE = calcSE(params),
    data = tbl,
    studlab = incl_author_year,
    prediction = TRUE,
    predict.seed = 1810,
    ...
  ) %>%
    dmetar::find.outliers() %>%
    extract2("m.random") %>%
    meta::metabias(method = "linreg", k.min = 5)

  return(res)
}

iterate <- function(tbl, groupvar, ...) {
  #' Iterate Extracted data
  #'
  #' Iterate the subset of extracted data for measuring the effect size
  #'
  #' @param tbl A data frame containing extracted information
  #' @param groupvar A grouping variable for iterating the effect size pooling
  #' @param ... Arguments being passed on to `poolES`
  if (length(groupvar) == 1) {
    groups  <- unique(tbl[[groupvar]]) %>% set_names(., .)

    res <- lapply(groups, function(group) {
      sub_tbl <- tbl %>% subset(.[[groupvar]] == group)
      if (nrow(sub_tbl) > 1) {
        ES <- poolES(sub_tbl, ...)
        return(ES)
      }
    })
  } else {
    groupvars <- groupvar %>% set_names(., .)
    res <- lapply(groupvars, \(groupvar) iterate(tbl, groupvar, ...))
  }
  return(res)
}
