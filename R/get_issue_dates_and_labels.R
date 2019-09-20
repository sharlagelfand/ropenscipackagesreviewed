#' Get GitHub issue created and closed dates and current labels.
#'
#' Get GitHub issue created and (if relevant) closed dates, as well as the labels currently attached to the issue.
#'
#' @param issue_url GitHub issue URL
#'
#' @export
#' @examples
#' \dontrun{
#' get_issues_dates_and_labels("https://github.com/ropensci/onboarding/issues/33")
#' }
get_issues_dates_and_labels <- function(issue_url) {
  issue_endpoint <- sub("https://github.com/", "/repos/", issue_url)
  issue_data <- gh::gh(issue_endpoint)
  issue_created <- issue_data[["created_at"]]
  issue_state <- issue_data[["state"]]
  issue_closed <- issue_data[["closed_at"]]

  issue_labels <- issue_data[["labels"]]
  issue_labels <- purrr::transpose(issue_labels)
  issue_labels <- paste0(issue_labels[["name"]], collapse = ",")

  dplyr::tibble(
    issue_created = lubridate::ymd_hms(issue_created),
    issue_closed = lubridate::ymd_hms(ifelse(is.null(issue_closed), NA_real_, issue_closed)),
    issue_labels = issue_labels
  )
}
