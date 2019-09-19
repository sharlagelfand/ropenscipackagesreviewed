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

  issue_data <- gh(issue_endpoint)

  labels <- issue_data[["labels"]]
  labels <- transpose(labels)
  labels <- paste0(labels[["name"]], collapse = ",")

  issue_created <- issue_data[["created_at"]]

  tibble(
    issue_created = as.Date(issue_created),
    issue_labels = labels
  )
}

software_review_packages <- software_review_packages %>%
  mutate(gh_metadata = map(onboarding, get_issue_metadata)) %>%
  unnest(gh_metadata) %>%
  select(name, onboarding_issue = onboarding, issue_created, issue_labels)

ropensci_packages <- packages %>%
  left_join(software_review_packages, by = "name") %>%
  mutate(software_review = !is.na(onboarding_issue),
         review_status = case_when(str_detect(issue_labels, "6/approved") ~ "Approved",
                                   !str_detect(issue_labels, "6/approved") ~ "In Progress",
                                   !software_review ~ NA_character_)) %>%
  select(name, software_review, onboarding_issue, issue_labels, review_status, issue_created) %>%
  as_tibble()

write.csv(ropensci_packages, "data-raw/ropensci_packages.csv", row.names = FALSE)

usethis::use_data(ropensci_packages, overwrite = TRUE)
