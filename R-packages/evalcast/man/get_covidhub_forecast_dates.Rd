% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_covidhub_predictions.R
\name{get_covidhub_forecast_dates}
\alias{get_covidhub_forecast_dates}
\title{Get available forecast dates for a forecaster on the COVID Hub}
\usage{
get_covidhub_forecast_dates(forecaster_name)
}
\arguments{
\item{forecaster_name}{String indicating of the forecaster
(matching what it is called on the COVID Hub).}
}
\value{
vector of forecast dates
}
\description{
Retrieves the forecast dates that a forecaster submitted to
the \href{https://github.com/reichlab/covid19-forecast-hub/}{COVID Hub}.
}
