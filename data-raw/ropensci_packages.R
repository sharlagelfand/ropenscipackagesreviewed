library(jsonlite)
library(dplyr)
library(purrr)
library(tidyr)
library(stringr)
library(ropenscipackagesreviewed)

url <- "https://ropensci.github.io/roregistry/registry.json"
packages <- fromJSON(url, simplifyDataFrame = TRUE)
packages <- packages[["packages"]]

# Replace all "" with NA

packages <- packages %>%
  mutate_all(~ ifelse(.x == "", NA, .x))

# Get all packages with an onboarding URL (gone/going through review)

software_review_packages <- packages %>%
  filter(!is.na(onboarding))

# Get created/closed dates for github issues, as well as labels attached to issue

software_review_packages_dates_and_labels <- software_review_packages %>%
  mutate(issue_dates = map(onboarding, get_issues_dates_and_labels))

# Get events for an issue (to see when the "6/approved" label was added")

software_review_packages_events <- software_review_packages %>%
  mutate(issue_events = map(onboarding, get_issue_events))

package_approved <- software_review_packages_events %>%
  select(package = name, issue_events) %>%
  unnest(issue_events) %>%
  as_tibble() %>%
  filter(
    event == "labeled",
    str_detect(label, "approved")
  ) %>%
  select(package, event_time) %>%
  group_by(package) %>%
  filter(event_time == max(event_time)) %>% # In case the label was applied more than once, take the last time
  ungroup()

# Combine data to save

software_review_packages_with_completed_date <- software_review_packages_dates_and_labels %>%
  select(package = name, onboarding_url = onboarding, issue_dates) %>%
  unnest(issue_dates) %>%
  mutate(review_completed = str_detect(issue_labels, "6/approved")) %>%
  left_join(package_approved, by = "package") %>%
  mutate(review_completed = case_when(review_completed ~ coalesce(event_time, issue_closed))) %>%
  select(package, onboarding_url, issue_created, review_completed, issue_closed)

ropensci_packages <- packages %>%
  select(package = name) %>%
  left_join(software_review_packages_with_completed_date, by = "package") %>%
  as_tibble() %>%
  mutate(
    software_review = !is.na(issue_created),
    software_review_status = case_when(
      !is.na(review_completed) & software_review ~ "Completed",
      is.na(review_completed) & software_review ~ "In Progress"
    )
  ) %>%
  select(package, software_review, software_review_status, onboarding_url, issue_created, review_completed, issue_closed)

write.csv(ropensci_packages, "data-raw/ropensci_packages.csv", row.names = FALSE)

usethis::use_data(ropensci_packages, overwrite = TRUE)

# Create additional data set of all events for packages in the registry that have gone through or are in review

ropensci_package_events <- software_review_packages_events %>%
  select(name, issue_events) %>%
  unnest(issue_events) %>%
  select(package = name, event, event_time, label) %>%
  arrange(package, event_time)

usethis::use_data(ropensci_package_events, overwrite = TRUE)
