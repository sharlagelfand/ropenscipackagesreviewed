
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ropenscipackagesreviewed

This package contains a list of R packages in the [rOpenSci
registry](https://github.com/ropensci/roregistry/) and metadata on
whether they have gone through the rOpenSci software review process (as
of 2019-09-19).

## Installation

You can install the development version of ropenscipackagesreviewed
with:

``` r
# install.packages("devtools")
devtools::install_github("sharlagelfand/ropenscipackagesreviewed)
```

## Analysis

The list of packages is available internally, in
`ropenscipackagesreviewed::ropensci_packages`, or [in a
CSV](https://github.com/sharlagelfand/ropenscipackagesreviewed/blob/master/data-raw/ropensci_packages.csv).
The code to get the packages is [also
available](https://github.com/sharlagelfand/ropenscipackagesreviewed/blob/master/data-raw/ropensci_packages.R).

If a package had a GitHub issue onboarding URL in the registry, it is
considered to have gone through (or be going through) rOpenSci software
review. If the issue has the [“6/approved”
label](https://github.com/ropensci/software-review/issues?utf8=%E2%9C%93&q=is%3Aissue+label%3A6%2Fapproved+)
on it, then I’m considering the package to have been “Approved”
(regardless of whether the issue is open or closed). If it doesn’t, then
the review is “In Progress”.

``` r
library(ropenscipackagesreviewed)

ropensci_packages
#> # A tibble: 406 x 6
#>    name  software_review onboarding_issue issue_labels review_status
#>    <chr> <lgl>           <chr>            <chr>        <chr>        
#>  1 auk   TRUE            https://github.… 6/approved,… Approved     
#>  2 genb… TRUE            https://github.… 6/approved,… Approved     
#>  3 tree… TRUE            https://github.… 6/approved,… Approved     
#>  4 apip… FALSE           <NA>             <NA>         <NA>         
#>  5 arre… FALSE           <NA>             <NA>         <NA>         
#>  6 aspa… FALSE           <NA>             <NA>         <NA>         
#>  7 avai… FALSE           <NA>             <NA>         <NA>         
#>  8 bind… FALSE           <NA>             <NA>         <NA>         
#>  9 blog… FALSE           <NA>             <NA>         <NA>         
#> 10 cche… FALSE           <NA>             <NA>         <NA>         
#> # … with 396 more rows, and 1 more variable: issue_created <date>
```

``` r
library(dplyr)

n_ropensci_packages <- nrow(ropensci_packages)
ropensci_packages_review <- ropensci_packages %>%
  filter(software_review)
ropensci_packages_review_approved <- ropensci_packages_review %>%
  filter(review_status == "Approved")
ropensci_packages_review_in_progress <- ropensci_packages_review %>%
  filter(review_status == "In Progress")
ropensci_packages_no_review <- ropensci_packages %>%
  filter(!software_review)
```

Of the 406 packages in the rOpenSci registry, 30.0% (122) have gone
through review (121) or are still in review (1).

The following shows the number of packages that went through review each
year, using the GitHub issue *create* date for the review year. Of
course, some packages may not be approved the same year the issue is
opened (especially if it happens towards the end of the year), and 2019
is not over yet\!

``` r
library(ggplot2)
library(lubridate)

ropensci_packages_review_approved <- ropensci_packages_review_approved %>%
  mutate(review_year = year(issue_created))

ropensci_packages_review_approved %>%
  count(review_year) %>%
  arrange(review_year) %>%
  ggplot(aes(x = review_year, y = n)) +
  geom_col() + 
  geom_text(aes(label = n, vjust = -0.5)) +
  labs(x = "Review Year",
       y = "Number of Packages",
       title = "rOpenSci Packages Completed Software Review, by Year") + 
  theme_minimal(14)
```

<img src="man/figures/README-packages-reviewed-by-year-1.png" width="75%" />
