% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_issue_dates_and_labels.R
\name{get_issues_dates_and_labels}
\alias{get_issues_dates_and_labels}
\title{Get GitHub issue created and closed dates and current labels.}
\usage{
get_issues_dates_and_labels(issue_url)
}
\arguments{
\item{issue_url}{GitHub issue URL}
}
\description{
Get GitHub issue created and (if relevant) closed dates, as well as the labels currently attached to the issue.
}
\examples{
\dontrun{
get_issues_dates_and_labels("https://github.com/ropensci/onboarding/issues/33")
}
}
