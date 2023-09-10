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
  "year", paste("clean", c("country", "criteria", "instrument"), sep = "_")
)

# Initiate analysis pipeline
list(
  tar_target(file_extract, raw["extracted"], format = "file"),
  tar_target(tbl, readData(file_extract)),
  tar_target(tbl_clean, deduplicate(tbl)),
  tar_target(pooled_author, iterate(tbl, "author_year", sm = "PRAW")),
  tar_target(pooled_groups, iterate(tbl_clean, itergroup, sm = "PRAW")),
  tar_target(pooled_all, poolES(tbl_clean, sm = "PRAW")),
  tar_target(meta_author, mkReport(pooled_author, report_type = "meta")),
  tar_target(bias_author, mkReport(pooled_author, report_type = "bias")),
  tar_target(meta_eda, lapply(pooled_groups, mkReport, report_type = "meta")),
  tar_target(bias_eda, lapply(pooled_groups, mkReport, report_type = "bias")),
  tar_target(meta_all, reportMeta(pooled_all, type = "meta")),
  tar_target(bias_all, reportMeta(pooled_all, type = "bias")),
  tar_quarto(readme, "README.qmd"),
  tar_quarto(report, "draft/report.qmd")
)
