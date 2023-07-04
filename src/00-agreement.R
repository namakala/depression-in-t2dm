## LOAD PACKAGES

pkgs <- c("magrittr")
pkgs_load <- sapply(pkgs, library, character.only = TRUE)


## FUNC

getDecision <- function(notes, actor) {
  reg <- sprintf(".*%s\\\"=>\\\"(\\w+).*", actor)
  sub(x = notes, reg, "\\1") %>%
    {ifelse(. == "Included", 1, 0)}
}


## PREP

# Read data frame
tbl <- readr::read_csv("data/raw/articles.csv") %>%
  subset(select = "notes")

# Set actors
actors <- c("Nora", "Aly")

# Extract decision
tbl %<>%
  inset(actors, value = lapply(actors, \(actor) getDecision(tbl$notes, actor)))
