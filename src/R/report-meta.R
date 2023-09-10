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

reportMeta <- function(meta_res, type = "meta", ...) {
  #' Report Meta-Analysis
  #'
  #' Report a meta-analysis model from `meta` package
  #'
  #' @param meta_res A meta-analysis object obtained from `meta::metabias`
  #' @return List of constructed table for rendering
  bias <- meta_res
  meta <- bias$x

  if (type == "meta") {
    tbl <- with(meta, tibble::data_frame(
      "Author"     = studlab,
      "Prevalence" = TE,
      "95% CI"     = 
    ))
  }
}
