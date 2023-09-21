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
    "prop"    = c("proportion", "prevalence", "PRAW"),
    "mean"    = c("mean", "average", "SMD", "MD"),
    "corr"    = c("correlation", "pearson"),
    "odds"    = c("odds"),
    "logit"   = c("logit", "PLOGIT"),
    "arcsine" = c("arcsine", "PAS", "asin"),
    "tukey"   = c("tukey", "PFT", "double_arcsine", "double_asin")
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
  #' https://github.com/guido-s/meta/blob/37b707495725f1bf44c008a604c69b122794cad1/R/metaprop.R
  #'
  #' @param params A list of parameters required to compute the effect size
  #' @param type Type of effect size
  #' @return An array of standard error
  params %<>% lapply(as.numeric)
  type   %<>% finder()

  p     <- params$p
  n     <- params$n
  event <- round(p * n)

  if (type == "prop") {
    se <- sqrt({p * (1 - p)} / n)
  } else if (type == "logit") {
    se <- sqrt({1 / event} + {1 / {n - event}})
  } else if (type == "arcsine") {
    se <- sqrt(1 / (4 * n))
  } else if(type == "tukey") {
    se <- sqrt(1 / (4 * n + 2))
  } else {
    se <- NULL
  }

  return(se)
}

poolES <- function(tbl, rm_outlier = TRUE, ...) {
  #' Pool Effect Size
  #'
  #' Pool the effect size for meta-analysis
  #'
  #' @param tbl A data frame containing extracted information
  #' @inheritDotParams meta::metagen
  #' @return Pooled effect size using `meta` package
  args   <- c(as.list(environment()), list(...))
  params <- with(tbl, list("n" = n_diabet, "p" = prev_diabet)) %>%
    lapply(as.numeric)

  if (hasArg(sm)) {
    n <- params$n
    p <- params$p
    event <- as.numeric(n) * as.numeric(p)

    seTE  <- calcSE(params, type = args$sm)

    if (args$sm == "PRAW") {
      TE <- p
    } else if (args$sm == "PLOGIT") {
      TE <- log(event / {n - event})
    } else if (args$sm == "PAS") {
      TE <- asin(sqrt(event / n))
    } else if (args$sm == "PFT") {
      asn1 <- asin(sqrt(event / {n + 1}))
      asn2 <- asin(sqrt({event + 1} / {n + 1}))
      TE   <- 0.5 * {asn1 + asn2}
    }

  } else {
    TE   <- params$p
    seTE <- calcSE(params, type = "prop")
  }

  res <- meta::metagen(
    TE = TE,
    seTE = seTE,
    data = tbl,
    studlab = incl_author_year,
    prediction = TRUE,
    predict.seed = 1810,
    ...
  )

  if (rm_outlier) {
    res %<>%
      dmetar::find.outliers() %>%
      extract2("m.random")
  }

  res %<>%
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

fitSubgroup <- function(meta_res, group, ...) {
  #' Subgroup Meta-Analysis
  #'
  #' Perform subgroup meta-analysis for the included grouping variable
  #'
  #' @param meta_res Meta-analysis object obtained from `poolES` with the class
  #' of `metabias`
  #' @param group A character vector indicating the grouping variable included
  #' in the meta-analysis object
  #' @inheritDotParams meta::update.meta
  bias <- meta_res
  mod  <- bias$x
  res  <- meta::update.meta(
    mod,
    subgroup = get(group),
    ...
  )

  return(res)
}

fitRegression <- function(meta_res, form, ...) {
  #' Fit Meta Regression
  #'
  #' Fit a regression modle into a meta-analysis object
  #'
  #' @param meta_res Meta-analysis object obtained from `poolES` with the class
  #' of `metabias`
  #' @param form A formula for fitting the regression line
  #' @inheritDotParams meta::metareg
  #' @return A fitted meta-regression model
  bias <- meta_res
  mod  <- bias$x
  res  <- meta::metareg(mod, form, intercept = TRUE, ...)

  return(res)
}
