% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_covidhub_predictions.R
\name{get_covidhub_forecaster_names}
\alias{get_covidhub_forecaster_names}
\title{List all COVID forecast models available}
\usage{
get_covidhub_forecaster_names(
  repo = c("zoltar", "covid19forecast_repo"),
  designations = "*"
)
}
\arguments{
\item{repo}{character string either "zoltar" indicating the
\href{https://zoltardata.com}{Zoltar} Forecast Archive or "covid19forecast_repo"
which lists those available at the
\href{https://github.com/reichlab/covid19-forecast-hub}{Reich Lab}
Github submission repo.}

\item{designations}{vector of character strings representing acceptable
designation types for models. If \code{"*"} (the default), models of all
designations will be returned. See
\href{https://github.com/reichlab/covid19-forecast-hub/blob/master/data-processed/METADATA.md#team_model_designation}{Reich Lab's Documentation}
for allowed designations and their meanings.}
}
\value{
character vector of all available forecasters matching given criteria
}
\description{
Utility function to list all forecasters submitting COVID-19 forecasts to
the \href{http://covid19forecasthub.org/}{COVID 19 Forecast Hub}.
}
