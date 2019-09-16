## code to prepare `DATASET` dataset goes here

library(dplyr)
library(tidyr)
library(purrr)
library(ggplot2)
library(lubridate)
library(jsonlite)
library(gh)

url <- "https://ropensci.github.io/roregistry/registry.json"
packages <- jsonlite::fromJSON(url, simplifyDataFrame = TRUE)
packages <- packages[["packages"]]

# Replace all "" with NA

packages <- packages %>%
  mutate_all(~ ifelse(.x == "", NA, .x))

# Get all packages with an onboarding URL (gone/going through review)

software_review_packages <- packages %>%
  filter(!is.na(onboarding))

get_issue_metadata <- function(onboarding_url) {
  issue_endpoint <- sub("https://github.com/", "/repos/", onboarding_url)

  issue_data <- gh(paste("GET", issue_endpoint))

  issue_created <- issue_data[["created_at"]]
  issue_state <- issue_data[["state"]]
  issue_closed <- ifelse(issue_state == "closed", issue_data[["closed_at"]], NA_character_)

  tibble::tibble(
    created = as.Date(issue_created),
    state = issue_state,
    closed = as.Date(issue_closed)
  )
}

software_review_packages <- software_review_packages %>%
  mutate(gh_metadata = map(onboarding, get_issue_metadata)) %>%
  select(name, gh_metadata) %>%
  unnest()

ropensci_packages <- packages %>%
  left_join(software_review_packages, by = "name") %>%
  mutate(software_review = !is.na(state),
         review_status = case_when(state == "closed" ~ "Completed",
                                   state == "open" ~ "In Progress",
                                   !software_review ~ NA_character_)) %>%
  select(name, software_review, review_status, issue_created = created, issue_closed = closed) %>%
  as_tibble()

write.csv(ropensci_packages, "data-raw/ropensci_packages.csv", row.names = FALSE)

usethis::use_data(ropensci_packages, overwrite = TRUE)
