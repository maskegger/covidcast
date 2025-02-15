% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/intersect_averagers.R
\name{intersect_averagers}
\alias{intersect_averagers}
\title{Find common averaging "locations"}
\usage{
intersect_averagers(cards, grp_vars, avg_vars)
}
\arguments{
\item{cards}{long data frame}

\item{grp_vars}{character vector of indicating variables to group on}

\item{avg_vars}{character vector of variables to average over}
}
\value{
a data frame of the same type as input
}
\description{
Many scoring or plotting functions compute averages over "locations"
for a number of different grouping facets. We say "locations" because this
most often the geo_value that gets averaged over, while the groupings are
the forecaster, forecast horizon, and forecast date. But under other
combinations may be desired.
}
\details{
In the case that we want to make comparisons, we want the avg_vars to be
common. This function finds common avg_vars. An example would be if one
forecaster makes predictions for a location that others don't, we would
want to throw it when ever we compute error measures.
}
