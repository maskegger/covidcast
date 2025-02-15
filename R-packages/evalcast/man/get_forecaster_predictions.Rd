% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_covidhub_predictions.R
\name{get_forecaster_predictions}
\alias{get_forecaster_predictions}
\title{Get predictions from a forecaster on the COVID Hub}
\usage{
get_forecaster_predictions(
  covidhub_forecaster_name,
  forecast_dates = NULL,
  geo_values = "*",
  forecast_type = c("point", "quantile"),
  ahead = 1:4,
  incidence_period = c("epiweek", "day"),
  signal = c("confirmed_incidence_num", "deaths_incidence_num",
    "deaths_cumulative_num", "confirmed_admissions_covid_1d")
)
}
\arguments{
\item{covidhub_forecaster_name}{String indicating of the forecaster
(matching what it is called on the COVID Hub).}

\item{forecast_dates}{Vector of Date objects (or strings of the form
"YYYY-MM-DD") indicating dates on which forecasts will be made. If \code{NULL},
the default, then all currently available forecast dates from the given
forecaster in the COVID Hub will be used.}

\item{geo_values}{vector of character strings containing FIPS codes of
counties, or lower case state abbreviations (or "us" for national). The
default "*" fetches all available locations}

\item{forecast_type}{"quantile", "point" or both (the default)}

\item{ahead}{number of periods ahead for which the forecast is required.
NULL will fetch all available aheads}

\item{incidence_period}{one of "epiweek" or "day". NULL will attempt to
return both}

\item{signal}{this function supports only "confirmed_incidence_num",
"deaths_incidence_num", "deaths_cumulative_num", and/or
"confirmed_admissions_covid_1d". For other types, use one of the
alternatives mentioned above}
}
\value{
Long data frame of forecasts with a class of \code{predictions_cards}.
The first 4 columns are the same as those returned by the forecaster. The
remainder specify the prediction task, 10 columns in total:
\code{ahead}, \code{geo_value}, \code{quantile}, \code{value}, \code{forecaster}, \code{forecast_date},
\code{data_source}, \code{signal}, \code{target_end_date}, and \code{incidence_period}. Here
\code{data_source} and \code{signal} correspond to the response variable only.

Predictions card. For more flexible processing of COVID Hub data, try
using \href{https://docs.zoltardata.com/zoltr/}{zoltr}
}
\description{
Simply converts the predictions of forecasters submitting to the \href{https://github.com/reichlab/covid19-forecast-hub/}{COVID Hub} to the format of a
predictions card, so it can be easily evaluated and compared.
}
\seealso{
\code{\link[=get_predictions]{get_predictions()}}

\code{\link[=get_zoltar_predictions]{get_zoltar_predictions()}}
}
