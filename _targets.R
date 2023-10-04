# Load packages
sapply(
  c("magrittr", "targets", "tarchetypes"),
  library,
  character.only = TRUE
)

# List all data files
raw <- list.files(
  "data/raw", full.names = TRUE, recursive = TRUE, pattern = "*.csv"
) %>%
  set_names(gsub(x = ., ".*/|.csv|\\W", ""))

# Source all functions
sapply(
  list.files("src/R", recursive = TRUE, pattern = "*.R", full.names = TRUE),
  source
)

# Set group of variables to iterate the meta analysis
itergroup <- c(
  "year", "incl_year", paste("clean", c("country", "criteria", "instrument"), sep = "_")
) %>%
  set_names(., .)

# Initiate analysis pipeline
list(
  tar_target(file_extract, raw["extracted"], format = "file"),
  tar_target(tbl, readData(file_extract)),
  tar_target(tbl_clean, deduplicate(tbl)),
  tar_target(tbl_trim, tbl_clean %>% subset(!.$anomaly)),
  tar_target(pooled_author, iterate(tbl, "author_year", sm = "PRAW")),
  tar_target(pooled_groups, iterate(tbl_clean, itergroup, sm = "PRAW")),
  tar_target(meta_author, mkReport(pooled_author, report_type = "meta")),
  tar_target(bias_author, mkReport(pooled_author, report_type = "bias")),
  tar_target(meta_eda, lapply(pooled_groups, mkReport, report_type = "meta")),
  tar_target(bias_eda, lapply(pooled_groups, mkReport, report_type = "bias")),
  tar_target(pooled_all, poolES(tbl_clean, sm = "PRAW")),
  tar_target(meta_all, reportMeta(pooled_all, type = "meta")),
  tar_target(bias_all, reportMeta(pooled_all, type = "bias")),
  tar_target(pooled_trim, poolES(tbl_trim, rm_outlier = FALSE, sm = "PRAW")),
  tar_target(meta_trim, reportMeta(pooled_trim, type = "meta")),
  tar_target(bias_trim, reportMeta(pooled_trim, type = "bias")),
  tar_target(pooled_trim_glmm, poolES(tbl_trim, rm_outlier = FALSE, sm = "PLOGIT", method = "GLMM")),
  tar_target(meta_trim_glmm, reportMeta(pooled_trim_glmm, type = "meta")),
  tar_target(bias_trim_glmm, reportMeta(pooled_trim_glmm, type = "bias")),
  tar_target(subgroup_analysis, lapply(itergroup[-3], \(group) fitSubgroup(pooled_all, group))),
  tar_target(meta_subgroup, lapply(subgroup_analysis, \(group) reportMeta(group, type = "subgroup"))),
  tar_target(meta_reg, fitRegression(pooled_all, ~ incl_year + clean_criteria)),
  tar_target(plt_metareg, vizMetareg(meta_reg)),
  tar_target(pooled_glmm, poolES(tbl_clean, sm = "PLOGIT", method = "GLMM")),
  tar_target(meta_glmm, reportMeta(pooled_glmm, type = "meta", logit2p = TRUE)),
  tar_target(bias_glmm, reportMeta(pooled_glmm, type = "bias", logit2p = TRUE)),
  tar_target(subgroup_glmm, lapply(itergroup[-3], \(group) fitSubgroup(pooled_glmm, group))),
  tar_target(meta_subgroup_glmm, lapply(subgroup_glmm, \(group) reportMeta(group, type = "subgroup", logit2p = TRUE))),
  tar_target(meta_reg_glmm, fitRegression(pooled_glmm, ~ incl_year + clean_criteria)),
  tar_target(plt_metareg_glmm, vizMetareg(meta_reg_glmm)),
  tar_quarto(readme, "README.qmd"),
  tar_quarto(report, "draft")
)
