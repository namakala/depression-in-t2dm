# Functions to report meta-analysis results

vizMetareg <- function(meta_reg, alpha = 0.7, ...) {
  #' Visualize Meta-Regression
  #'
  #' Generate bubble plot to visualize the meta regression
  #'
  #' @param meta_reg A meta-regression object from `meta::metareg`
  #' @return GGPlot2 object
  require("ggplot2")

  # Detect GLMM model
  is_glmm <- any(class(meta_reg) == "rma.glmm")

  # Extract the model matrix without intercept to perform prediction
  mod_mtx   <- meta_reg$X.f[, -1]

  pred_prev <- meta_reg %>%
    metafor::predict.rma(newmods = mod_mtx) %>%
    data.frame() %>%
    merge(mod_mtx, by = "row.names") %>%
    subset(select = c(pred, ci.lb, ci.ub))

  if (is_glmm) { # Need to exponentiate the log scale
    pred_prev %<>% exp()
  }

  # Configure table for plotting
  tbl <- meta_reg$data %>%
    inset2("weight", value = 1 / sqrt(meta_reg$vi.f)) %>%
    inset(names(pred_prev), value = pred_prev) %>%
    dplyr::group_by(region) %>%
    dplyr::mutate("min" = min(ci.lb, na.rm = TRUE), "max" = max(ci.ub, na.rm = TRUE)) %>%
    dplyr::ungroup()

  # Extract the beta estimates
  beta_val <- round(meta_reg$b * 100, 2) %>%
    {ifelse(. > 0, paste0("+", .), .)} %>%
    data.frame() %>%
    set_names("beta") %>%
    inset2("region", value = gsub(x = rownames(.), "region|cl\\w*ment", ""))

  # Get the reference region
  ref_region <- tbl$region %>% unique() %>% {.[!. %in% beta_val$region]}

  # Generate equation for each region
  tbl_eq <- beta_val %>%
    subset(grepl(x = rownames(.), "region")) %>%
    inset2("label", value = {
      sprintf(
        #"'Prevalence (%%)' == %s %s * x[1] + ...",
        "'Prevalence %s%%'",
        .$beta
      )
    }) %>%
    set_rownames(c()) %>%
    subset(.$region != "Unclassified") %>%
    extract(c("region", "label")) %>%
    rbind(list("region" = ref_region, "label" = "Reference"))

  # Merge equation into the data frame, remove unclassified
  tbl %<>%
    subset(.$region != "Unclassified") %>%
    merge(tbl_eq, by = "region")

  # Generate subtitle and initiate the canvas
  if (is_glmm) {

    subtitle <- sprintf(
      "Meta-Regression on %s primary studies from %s to %s, where only %s studies rely on clinical diagnosis",
      sum(!is.na(tbl$.event)),
      min(tbl$incl_year),
      max(tbl$incl_year),
      tbl$clean_criteria %>% table() %>% extract2("Assisted by Clinician")
    )

    canvas <- ggplot(tbl, aes(x = incl_year, y = .event / .n))

  } else {

    subtitle <- sprintf(
      "Meta-Regression on %s primary studies from %s to %s, where only %s studies rely on clinical diagnosis",
      sum(!is.na(tbl$.TE)),
      min(tbl$incl_year),
      max(tbl$incl_year),
      tbl$clean_criteria %>% table() %>% extract2("Assisted by Clinician")
    )

    canvas <- ggplot(tbl, aes(x = incl_year, y = .TE))

  }

  # Create the figure
  plt <- canvas +
    geom_ribbon(aes(ymin = min, ymax = max), alpha = alpha * 0.2) +
    geom_point(alpha = alpha * 0.8, aes(color = clean_instrument, size = weight)) +
    geom_point(aes(y = pred, size = weight, shape = "Predicted value"), alpha = alpha, color = "grey30") +
    facet_wrap(~ factor(region, levels = levels(tbl$region)), scales = "free") +
    geom_text(data = tbl_eq, aes(x = -Inf, y = Inf, label = label), parse = TRUE, hjust = -0.1, vjust = 1, size = 3) +
    scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
    scale_size(guide = "none") +
    guides(color = guide_legend("")) +
    scale_shape_manual(values = c("Predicted value" = 18), name = "") +
    labs(
      title = "The prediction of depression prevalence among T2DM patients",
      subtitle = subtitle,
      caption = "The gray band represents predicted confidence interval across regions",
      x = "Year of Publication", y = "Depression Prevalence"
    ) +
    theme_minimal() +
    theme(
      legend.position = "top",
      legend.direction = "horizontal",
      legend.justification = c("left", "bottom"),
      panel.grid.minor = element_blank()
    )

  return(plt)
}

getCI <- function(meta = NULL, lo = "lower", hi = "upper", se = NULL, m = NULL, multiply = TRUE, ...) {
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
  #' @param ... Additional arguments for conditional statements, including
  #' `logit2p` which transform logit into probability
  #' @return A vector of pretty confidence interval
  if (!is.null(meta)) {
    lo <- meta[[lo]]
    hi <- meta[[hi]]
  } else if (!is.null(se)) {
    lo <- m - {1.96 * se}
    hi <- m + {1.96 * se}
  }

  if (hasArg(logit2p)) {
    lo %<>% meta:::logit2p()
    hi %<>% meta:::logit2p()
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

reportCI <- function(meta = NULL, metric = NULL, se = NULL, m = NULL, multiply = FALSE, ...) {
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
  #' @param ... Additional arguments for conditional statements passed on to
  #' getCI
  #' @return A character object of confidence interval report
  transmute <- hasArg(logit2p)

  if (!is.null(meta)) {
    params <- list(
      "lo" = sprintf("lower.%s", metric),
      "hi" = sprintf("upper.%s", metric)
    )

    m  <- meta[[metric]]
    ci <- getCI(meta, lo = params$lo, hi = params$hi, multiply = multiply, ...)

  } else if (!is.null(se)) {
    ci <- getCI(se = se, m = m, multiply = multiply, ...)
  }

  m %<>% sapply(function(meanval) {
    meanval %>%
      {ifelse(transmute, meta:::logit2p(.), .)} %>%
      {ifelse(multiply, . * 100, .)}
  })

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

    # Preserve data consistency
    if (!".exclude" %in% names(bias$x$data)) {
      bias$x$exclude <-
        bias$x$data$.exclude <-
        meta$exclude <-
          meta$data$.exclude <- FALSE
    }

  } else if (any(class(meta_res) %in% c("metagen", "metaprop"))) {
    meta <- meta_res
  }

  is_prop   <- any(class(meta) == "metaprop")
  transmute <- hasArg(logit2p)

  if (type == "meta") {
    ci         <- getCI(meta, lo = "lower", hi = "upper")
    ci_fixed   <- getCI(meta, lo = "lower.fixed", hi = "upper.fixed", ...)
    ci_random  <- getCI(meta, lo = "lower.random", hi = "upper.random", ...)
    ci_predict <- getCI(meta, lo = "lower.predict", hi = "upper.predict", ...)

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
      "%"       = ifelse(rep(is_prop, nrow(meta$data)), meta:::logit2p(TE), TE) * 100,
      "95% CI"  = ci,
      "Z"       = zval,
      "p"       = p,
      "Random"  = weights$random,
      "Fixed"   = weights$fixed,
      "Exclude" = exclude
    ))

    sub_tbl <- tbl %>% subset(!.$Exclude)

    fixed_es  <- meta$TE.fixed  %>% {ifelse(transmute, meta:::logit2p(.), .) * 100}
    random_es <- meta$TE.random %>% {ifelse(transmute, meta:::logit2p(.), .) * 100}

    res <- with(meta,
      sub_tbl %>%
        rbind(list("Fixed", sum(sub_tbl$N),  fixed_es,  ci_fixed,  zval.fixed,  p_fixed,  NA, NA, FALSE)) %>%
        rbind(list("Random", sum(sub_tbl$N), random_es, ci_random, zval.random, p_random, NA, NA, FALSE)) %>%
        rbind(list("Prediction", sum(sub_tbl$N), NA,    ci_predict, NA, NA, NA, NA, FALSE))
    )

  } else if (type == "bias") {
    tbl <- with(bias, tibble::tibble(
      "N"    = sum(!x$data$.exclude),
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
      "Fixed"  = reportCI(
        se = seTE.fixed.w,
        m  = TE.fixed.w,
        multiply = TRUE,
        ...
      ),
      "Random" = reportCI(
        se = seTE.random.w,
        m  = TE.random.w,
        multiply = TRUE,
        ...
      ),
      "I2"     = round(I2.w * 100, 2),
      "H"      = round(H.w, 2),
      "tau2"   = round(tau2.w, 3)
    ))

    sub_tbl <- tbl %>% subset(.$N > 0)

    res <- sub_tbl
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
