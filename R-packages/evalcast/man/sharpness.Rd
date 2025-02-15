% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/error_measures.R
\name{sharpness}
\alias{sharpness}
\title{Sharpness component of the weighted interval score}
\usage{
sharpness(quantile, value, actual_value)
}
\arguments{
\item{quantile}{vector of forecasted quantiles}

\item{value}{vector of forecasted values}

\item{actual_value}{Actual value.}
}
\description{
Requires symmetric quantile forecasts. Roughly, a penalty for the w
width of predicted quantiles.
}
