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
  "year", "country", "criteria", "instrument"
)

# Initiate analysis pipeline
list(
  tar_target(file_extract, raw["extracted"], format = "file"),
  tar_target(tbl, readData(file_extract)),
  tar_target(pooled_author, iterate(tbl, "author", sm = "PRAW")),
  tar_target(tbl_clean, tbl),
  tar_target(pooled_es, iterate(tbl_clean, itergroup, sm = "PRAW")),
  tar_quarto(readme, "README.qmd")
)
