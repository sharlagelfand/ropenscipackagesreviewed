#' Get GitHub issue events
#'
#' Get GitHub issue events, including the type of event, the username that did the event, and the time of the event. If the event is "labeled" or "unlabeled", then the \code{label} is also returned.
#'
#' @param issue_url GitHub issue URL
#' @param limit Number of events to return. Defaults to \code{Inf}
#'
#' @export
#' @examples
#' \dontrun{
#' get_issue_events("https://github.com/ropensci/onboarding/issues/33")
#' }
get_issue_events <- function(issue_url, limit = Inf) {
  issue_events <- get_raw_events(issue_url, limit)
  issue_events <- purrr::map(issue_events, parse_events)
  dplyr::bind_rows(issue_events)
}

#' Get raw GitHub issue events
#'
#' Get a raw list of events associated with a GitHub issue URL.
#'
#' @param issue_url GitHub issue
#' @param limit Number of events to return. Defaults to \code{Inf}
#'
#' @export
#'
#' @examples
#' \dontrun{
#' get_raw_events("https://github.com/ropensci/onboarding/issues/33", limit = 1)
#' }
get_raw_events <- function(issue_url, limit = Inf) {
  events_endpoint <- paste0(sub("https://github.com/", "/repos/", issue_url), "/events")
  gh::gh(events_endpoint, .limit = limit)
}

#' Parse GitHub event
#'
#' @param event GitHub event from \code{get_raw_events}
#'
#' @export
#' @examples
#' \dontrun{
#' res <- get_raw_events("https://github.com/ropensci/onboarding/issues/33", limit = 2)
#' parse_events(res[[1]])
#' }
parse_events <- function(event) {
  event_user <- purrr::pluck(event, "actor", "login")
  event_time <- lubridate::ymd_hms(event[["created_at"]])
  label <- purrr::pluck(event, "label", "name")
  event <- event[["event"]]

  if (event %in% c("labeled", "unlabeled")) {
    dplyr::tibble(
      event,
      event_user,
      event_time,
      label
    )
  } else {
    dplyr::tibble(
      event,
      event_user,
      event_time
    )
  }
}
