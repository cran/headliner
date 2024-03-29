% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/trend-terms.R
\name{trend_terms}
\alias{trend_terms}
\title{Phrases for direction of difference}
\usage{
trend_terms(more = "increase", less = "decrease")
}
\arguments{
\item{more}{string to use when x > y}

\item{less}{string to use when x < y}
}
\value{
Returns a list object.
}
\description{
\code{trend_terms()} returns a list object describing the values to
display when \code{x} is greater than \code{y} or \code{x} is less than \code{y}.
}
\details{
\code{trend_terms()} will primarily be used in \code{headline()} and passed
along to \code{compare_conditions()}. Similar to \code{plural_phrasing()} Trend terms
can be passed in a list. See examples below.
}
\examples{

headline(
  x = c(9, 11),
  y = 10,
  headline = "{trend} by {delta_p}\%",
  trend_phrases = trend_terms("higher", "lower")
)

# a complex example passing multiple trends and plural phrases
headline(
  35, 30,
  headline =
    "We had {an_increase} of {delta} {people}.
    That is {delta} {more} {employees} \\\\
    than the same time last year ({orig_values}).",
  trend_phrases = list(
    an_increase = trend_terms("an increase", "a decrease"),
    more = trend_terms("more", "less")
  ),
  plural_phrases =
    list(
      people = plural_phrasing("person", "people"),
      employees = plural_phrasing("employee", "employees")
    )
)
}
\seealso{
\code{\link[=compare_values]{compare_values()}}
}
