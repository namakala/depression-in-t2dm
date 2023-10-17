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
  "year", "incl_year", "region", "continent",
  paste("clean", c("criteria", "instrument"), sep = "_"),
  "quality"
) %>%
  set_names(., .)

# Initiate analysis pipeline
list(

  # Read the data frames
  tar_target(file_extract, raw["extracted"], format = "file"),
  tar_target(file_gbd, raw["prevmdddm"], format = "file"),
  tar_target(tbl, readData(file_extract)),
  tar_target(tbl_clean, deduplicate(tbl)),
  tar_target(tbl_gbd, readGBD(file_gbd, ctry_list = tbl_clean$clean_country)),
  tar_target(tbl_merge, mergeGBD(tbl_clean, tbl_gbd)),
  tar_target(tbl_trim, tbl_clean %>% subset(!.$anomaly)),
  tar_target(tbl_sub, tbl_merge %>% subset(.$clean_instrument != "Others")),

  # Perform descriptive analysis
  tar_target(desc_clean, tblSummary(tbl_clean)),
  tar_target(plt_pair_clean, vizPair(tbl_clean)),

  # Reproduce meta-analysis from previous reviews
  tar_target(pooled_author, iterate(tbl, "author_year", sm = "PRAW", rm_outlier = FALSE)),
  tar_target(pooled_groups, iterate(tbl_clean, itergroup, sm = "PRAW", rm_outlier = TRUE)),
  tar_target(pooled_groups_nodrop, iterate(tbl_clean, itergroup, sm = "PRAW", rm_outlier = FALSE)),
  tar_target(meta_author, mkReport(pooled_author, report_type = "meta")),
  tar_target(bias_author, mkReport(pooled_author, report_type = "bias")),
  tar_target(meta_eda, lapply(pooled_groups, mkReport, report_type = "meta")),
  tar_target(bias_eda, lapply(pooled_groups, mkReport, report_type = "bias")),
  tar_target(meta_eda_nodrop, lapply(pooled_groups_nodrop, mkReport, report_type = "meta")),
  tar_target(bias_eda_nodrop, lapply(pooled_groups_nodrop, mkReport, report_type = "bias")),

  # Pooling ES inverse-variance method, no transformation
  tar_target(pooled_all, poolES(tbl_clean, sm = "PRAW", rm_outlier = TRUE)),
  tar_target(meta_all, reportMeta(pooled_all, type = "meta")),
  tar_target(bias_all, reportMeta(pooled_all, type = "bias")),
  tar_target(subgroup_analysis, lapply(itergroup, \(group) fitSubgroup(pooled_all, group))),
  tar_target(meta_subgroup, lapply(subgroup_analysis, \(group) reportMeta(group, type = "subgroup"))),
  tar_target(meta_reg, fitRegression(pooled_all, ~ incl_year + region + clean_instrument)),
  tar_target(plt_metareg, vizMetareg(meta_reg)),

  # Pooling ES inverse-variance method, no transformation, no drop
  tar_target(pooled_all_nodrop, poolES(tbl_clean, sm = "PRAW", rm_outlier = FALSE)),
  tar_target(meta_all_nodrop, reportMeta(pooled_all_nodrop, type = "meta")),
  tar_target(bias_all_nodrop, reportMeta(pooled_all_nodrop, type = "bias")),
  tar_target(subgroup_nodrop, lapply(itergroup, \(group) fitSubgroup(pooled_all_nodrop, group))),
  tar_target(meta_subgroup_nodrop, lapply(subgroup_nodrop, \(group) reportMeta(group, type = "subgroup"))),
  tar_target(meta_reg_nodrop, fitRegression(pooled_all_nodrop, ~ incl_year + region + clean_instrument)),
  tar_target(plt_metareg_nodrop, vizMetareg(meta_reg_nodrop)),

  # Pooling ES inverse-variance method, no transformation, trimmed anomalies
  tar_target(pooled_trim, poolES(tbl_trim, rm_outlier = TRUE, sm = "PRAW")),
  tar_target(meta_trim, reportMeta(pooled_trim, type = "meta")),
  tar_target(bias_trim, reportMeta(pooled_trim, type = "bias")),
  tar_target(subgroup_trim, lapply(itergroup, \(group) fitSubgroup(pooled_trim, group))),
  tar_target(meta_subgroup_trim, lapply(subgroup_trim, \(group) reportMeta(group, type = "subgroup"))),
  tar_target(meta_reg_trim, fitRegression(pooled_trim, ~ incl_year + region + clean_instrument)),
  tar_target(plt_metareg_trim, vizMetareg(meta_reg_trim)),

  # Pooling ES inverse-variance method, no transformation, trimmed anomalies, no drop
  tar_target(pooled_trim_nodrop, poolES(tbl_trim, rm_outlier = FALSE, sm = "PRAW")),
  tar_target(meta_trim_nodrop, reportMeta(pooled_trim_nodrop, type = "meta")),
  tar_target(bias_trim_nodrop, reportMeta(pooled_trim_nodrop, type = "bias")),
  tar_target(subgroup_trim_nodrop, lapply(itergroup, \(group) fitSubgroup(pooled_trim_nodrop, group))),
  tar_target(meta_subgroup_trim_nodrop, lapply(subgroup_trim_nodrop, \(group) reportMeta(group, type = "subgroup"))),
  tar_target(meta_reg_trim_nodrop, fitRegression(pooled_trim_nodrop, ~ incl_year + region + clean_instrument)),
  tar_target(plt_metareg_trim_nodrop, vizMetareg(meta_reg_trim_nodrop)),

  # Pooling ES, GLMM method, logit link function
  tar_target(pooled_glmm, poolES(tbl_clean, sm = "PLOGIT", method = "GLMM")),
  tar_target(meta_glmm, reportMeta(pooled_glmm, type = "meta", logit2p = TRUE)),
  tar_target(bias_glmm, reportMeta(pooled_glmm, type = "bias", logit2p = TRUE)),
  tar_target(subgroup_glmm, lapply(itergroup, \(group) fitSubgroup(pooled_glmm, group))),
  tar_target(meta_subgroup_glmm, lapply(subgroup_glmm, \(group) reportMeta(group, type = "subgroup", logit2p = TRUE))),
  tar_target(meta_reg_glmm, fitRegression(pooled_glmm, ~ incl_year + region + clean_instrument)),
  tar_target(plt_metareg_glmm, vizMetareg(meta_reg_glmm)),

  # Pooling ES, GLMM method, logit link function, no drop
  tar_target(pooled_nodrop_glmm, poolES(tbl_clean, sm = "PLOGIT", method = "GLMM", rm_outlier = FALSE)),
  tar_target(meta_nodrop_glmm, reportMeta(pooled_nodrop_glmm, type = "meta", logit2p = TRUE)),
  tar_target(bias_nodrop_glmm, reportMeta(pooled_nodrop_glmm, type = "bias", logit2p = TRUE)),
  tar_target(subgroup_nodrop_glmm, lapply(itergroup, \(group) fitSubgroup(pooled_nodrop_glmm, group)) %>% extract(!is.na(.))),
  tar_target(meta_subgroup_nodrop_glmm, lapply(subgroup_nodrop_glmm, \(group) reportMeta(group, type = "subgroup", logit2p = TRUE))),
  tar_target(meta_reg_nodrop_glmm, fitRegression(pooled_nodrop_glmm, ~ incl_year + region + clean_instrument)),
  tar_target(plt_metareg_nodrop_glmm, vizMetareg(meta_reg_nodrop_glmm)),

  # Pooling ES, GLMM method, logit link function, trimmed anomalies
  tar_target(pooled_trim_glmm, poolES(tbl_trim, sm = "PLOGIT", method = "GLMM")),
  tar_target(meta_trim_glmm, reportMeta(pooled_trim_glmm, type = "meta")),
  tar_target(bias_trim_glmm, reportMeta(pooled_trim_glmm, type = "bias")),
  tar_target(subgroup_trim_glmm, lapply(itergroup, \(group) fitSubgroup(pooled_trim_glmm, group))),
  tar_target(meta_subgroup_trim_glmm, lapply(subgroup_trim_glmm, \(group) reportMeta(group, type = "subgroup", logit2p = TRUE))),
  tar_target(meta_reg_trim_glmm, fitRegression(pooled_trim_glmm, ~ incl_year + region + clean_instrument)),
  tar_target(plt_metareg_trim_glmm, vizMetareg(meta_reg_trim_glmm)),

  # Pooling ES inverse-variance method, no transformation, subset of clean instrument
  tar_target(pooled_sub, poolES(tbl_sub, rm_outlier = TRUE, sm = "PRAW")),
  tar_target(meta_sub, reportMeta(pooled_sub, type = "meta")),
  tar_target(bias_sub, reportMeta(pooled_sub, type = "bias")),
  tar_target(subgroup_sub, lapply(itergroup, \(group) fitSubgroup(pooled_sub, group))),
  tar_target(meta_subgroup_sub, lapply(subgroup_sub, \(group) reportMeta(group, type = "subgroup"))),
  tar_target(meta_reg_sub, fitRegression(pooled_sub, ~ incl_year + region + clean_instrument)),
  tar_target(plt_metareg_sub, vizMetareg(meta_reg_sub)),

  # Pooling ES, GLMM method, logit link function, subset of clean instrument
  tar_target(pooled_sub_glmm, poolES(tbl_sub, sm = "PLOGIT", method = "GLMM")),
  tar_target(meta_sub_glmm, reportMeta(pooled_sub_glmm, type = "meta")),
  tar_target(bias_sub_glmm, reportMeta(pooled_sub_glmm, type = "bias")),
  tar_target(subgroup_sub_glmm, lapply(itergroup, \(group) fitSubgroup(pooled_sub_glmm, group))),
  tar_target(meta_subgroup_sub_glmm, lapply(subgroup_sub_glmm, \(group) reportMeta(group, type = "subgroup", logit2p = TRUE))),
  tar_target(meta_reg_sub_glmm, fitRegression(pooled_sub_glmm, ~ incl_year + region + clean_instrument)),
  tar_target(plt_metareg_sub_glmm, vizMetareg(meta_reg_sub_glmm)),

  # Documentation and reporting
  tar_quarto(readme, "README.qmd", priority = 0),
  tar_quarto(report, "draft", error = "continue", priority = 0)

)
