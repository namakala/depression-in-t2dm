# Functions to report meta-analysis results

vizMeta <- function(meta_res, ...) {
  #' Visualize Meta-Analysis
  #'
  #' Visualize the forest and funnel plot
  #'
  #' @param meta_res A meta-analysis object
  #' @return List of figures
  meta <- meta_res$x
  figs <- list(
    "funnel"  = meta::funnel(meta),
    "forest"  = meta::forest(meta, ref = 0, sortvar = TE),
    "drapery" = meta::drapery(meta, type = "pval")
  )

  return(figs)
}

getCI <- function(meta = NULL, lo = "lower", hi = "upper", se = NULL, m = NULL, multiply = TRUE) {
  #' Calculate the Confidence Interval
  #'
  #' Calculate the confidence interval from a meta-analysis object
  #'
  #' @param meta A meta-analysis object with a class of `metagen`
  #' @param lo A character vector of lower confidence interval
  #' @param hi A character vector of upper confidence interval
  #' @param se Standard error for calculating the confidence interval
  #' @param m Mean value for calculating the confidence interval
  #' @param multiply Boolean indicating whether to multiply by 100
  #' @return A vector of pretty confidence interval
  if (!is.null(meta)) {
    lo <- meta[[lo]]
    hi <- meta[[hi]]
  } else if (!is.null(se)) {
    lo <- m - {1.96 * se}
    hi <- m + {1.96 * se}
  }

  if (multiply) {
    lo %<>% multiply_by(100)
    hi %<>% multiply_by(100)
  }

  res  <- paste(round(lo, 2), round(hi, 2), sep = " - ")

  return(res)
}

getPval <- function(meta, p = "pval") {
  #' Get the P-value
  #'
  #' Prettify the p-value from a meta-analysis object
  #'
  #' @param meta A meta-analysis object with a class of `metagen` or `metabias`
  #' @param p A character of p-value to fetch
  #' @return A vector of pretty p-value
  pval <- with(meta,
    ifelse(get(p) < 0.001, "<0.001", round(get(p), 3))
  )

  return(pval)
}

reportCI <- function(meta = NULL, metric = NULL, se = NULL, m = NULL, multiply = FALSE) {
  #' Report Confidence Interval
  #'
  #' Report confidence interval obtained from a meta-analysis object
  #'
  #' @param meta A meta-analysis object with a class of `metagen`
  #' @param metric Statistical meatric from the meta-analysis object, such as
  #' `I2`, `H`, `tau`, `tau2`, and `Rb`
  #' @param se Standard error for calculating the confidence interval
  #' @param m Mean value for calculating the confidence interval
  #' @param multiply Boolean indicating whether to multiply by 100
  #' @return A character object of confidence interval report
  if (!is.null(meta)) {
    params <- list(
      "lo" = sprintf("lower.%s", metric),
      "hi" = sprintf("upper.%s", metric)
    )

    m  <- meta[[metric]]
    ci <- getCI(meta, lo = params$lo, hi = params$hi, multiply = multiply)

  } else if (!is.null(se)) {
    ci <- getCI(se = se, m = m, multiply = multiply)
  }

  m %<>% sapply(\(x) x %>% {ifelse(multiply, . * 100, .)})
  res <- sprintf("%s [%s]", round(m, 2), ci)

  return(res)
}

reportMeta <- function(meta_res, type = "meta", ...) {
  #' Report Meta-Analysis
  #'
  #' Report a meta-analysis model from `meta` package
  #'
  #' @param meta_res A meta-analysis object with a class of `metagen` or
  #' `metabias`
  #' @return A constructed table for rendering
  if (any(class(meta_res) == "metabias")) {
    bias <- meta_res
    meta <- bias$x
  } else if (any(class(meta_res) == "metagen")) {
    meta <- meta_res
  }

  if (type == "meta") {
    ci         <- getCI(meta, lo = "lower", hi = "upper")
    ci_fixed   <- getCI(meta, lo = "lower.fixed", hi = "upper.fixed")
    ci_random  <- getCI(meta, lo = "lower.random", hi = "upper.random")
    ci_predict <- getCI(meta, lo = "lower.predict", hi = "upper.predict")

    p          <- getPval(meta, p = "pval")
    p_fixed    <- getPval(meta, p = "pval.fixed")
    p_random   <- getPval(meta, p = "pval.random")

    weights    <- with(meta, tibble::tibble(
      "random" = w.random %>% {. / sum(.) * 100},
      "fixed"  = w.fixed %>% {. / sum(.) * 100}
    )) %>%
      round(2)

    tbl <- with(meta, tibble::tibble(
      "Author"  = studlab,
      "N"       = data$n_total,
      "%"       = TE * 100,
      "95% CI"  = ci,
      "Z"       = zval,
      "p"       = p,
      "Random"  = weights$random,
      "Fixed"   = weights$fixed,
      "Exclude" = exclude
    ))

    sub_tbl <- tbl %>% subset(!.$Exclude)

    res <- with(meta,
      tbl %>%
        rbind(list("Fixed", sum(sub_tbl$N), TE.fixed * 100, ci_fixed, zval.fixed, p_fixed, NA, NA, FALSE)) %>%
        rbind(list("Random", sum(sub_tbl$N), TE.random * 100, ci_random, zval.random, p_random, NA, NA, FALSE)) %>%
        rbind(list("Prediction", sum(sub_tbl$N), NA, ci_predict, NA, NA, NA, NA, FALSE))
    )

  } else if (type == "bias") {
    tbl <- with(bias, tibble::tibble(
      "N"    = sum(!x$exclude),
      "B"    = estimate[["bias"]],
      "SE"   = estimate[["se.bias"]],
      "p"    = getPval(bias),
      "I2"   = reportCI(bias$x, "I2", multiply = TRUE),
      "H"    = reportCI(bias$x, "H"),
      "tau"  = reportCI(bias$x, "tau"),
      "tau2" = reportCI(bias$x, "tau2"),
      "Rb"   = reportCI(bias$x, "Rb")
    ))

    res <- tbl
  } else if (type == "subgroup") {
    tbl <- with(meta, tibble::tibble(
      "Group"  = names(TE.common.w),
      "N"      = k.w,
      "Fixed"  = reportCI(se = seTE.fixed.w, m = TE.fixed.w, multiply = TRUE),
      "Random" = reportCI(se = seTE.random.w, m = TE.random.w, multiply = TRUE),
      "I2"     = round(I2.w * 100, 2),
      "H"      = round(H.w, 2),
      "tau2"   = round(tau2.w, 3)
    ))

    res <- tbl
  }

  return(res)
}

iterateReport <- function(meta_list, ...) {
  #' Iterate Report
  #'
  #' Iterate the reporting of a meta-analysis object
  #'
  #' @param meta_list A list of meta-analysis objects obtained from `meta::metabias`
  #' @param ... Arguments being passed on to `reportMeta`
  #' @return A list of constructed tables for rendering the report
  res <- lapply(meta_list, function(meta_res) {
    tryCatch(
      reportMeta(meta_res, ...),
      error = \(e) return(e)
    )
  })

  return(res)
}

mkReport <- function(meta_list, report_type = "meta", ...) {
  #' Make Meta-Analysis Report
  #'
  #' Generate a standardized data frame for meta-analysis report
  #'
  #' @param meta_list A list of meta-analysis objects obtained from `meta::metabias`
  #' @param report_type A character object specifying what to report, accept an
  #' argument of either `meta` or `bias`
  #' @param ... Arguments being passed on to `reportMeta`
  #' @return A table or list of tables for rendering the report
  res <- iterateReport(meta_list, type = report_type, ...) %>%
    extract(sapply(., is.data.frame)) %>%
    {do.call(rbind, .)} %>%
    tibble::add_column("Label" = gsub(x = rownames(.), "\\..*", ""), .before = 1)

  return(res)
}
