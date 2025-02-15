% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/baseline_forecaster.R
\name{baseline_forecaster}
\alias{baseline_forecaster}
\title{Baseline forecaster}
\usage{
baseline_forecaster(
  df_list,
  forecast_date,
  incidence_period = c("epiweek", "day"),
  ahead = 1:4,
  symmetrize = TRUE
)
}
\arguments{
\item{df_list}{list of data of the format that is returned by
\code{\link[covidcast:covidcast_signal]{covidcast::covidcast_signal()}} or \code{\link[covidcast:covidcast_signals]{covidcast::covidcast_signals()}}.}

\item{forecast_date}{Date object or string of the form "YYYY-MM-DD",
indicating date on which forecasts will be made about some period (e.g.,
epiweek). For example, if \code{forecast_date = "2020-05-11"}, \code{incidence_period = "day"}, and \code{ahead = 3}, then, we'd be making forecasts for "2020-05-14".}

\item{incidence_period}{String indicating the incidence period, either
"epiweek" or "day".}

\item{ahead}{Vector of (one or more) integers. How many epiweeks/days ahead
are you forecasting? If \code{incidence_period = "epiweek"} and forecast_date is
Sunday or Monday, then \code{ahead = 1} means the epiweek that includes the
forecast date; if \code{forecast_date} falls on a Tuesday through Saturday, then
it is the following epiweek. If \code{incidence_period = "day"}, then \code{ahead = 1} means the day after forecast date.}

\item{symmetrize}{Should symmetrized residuals be used, or unsymmetrized
(raw) residuals? Default is \code{TRUE}, which results in the flat-line point
prediction. If \code{FALSE}, then point predictions can be increasing or
decreasing, depending on the historical trend.}
}
\value{
Data frame with columns \code{ahead}, \code{geo_value}, \code{quantile}, \code{value}.
The \code{quantile} column gives the predicted quantiles of the forecast
distribution for that location and ahead. An NA indicates a point forecast
(same as the median in this case).
}
\description{
The "flat-line" forecaster, which essentially mirrors the baseline in the
\href{https://github.com/reichlab/covid19-forecast-hub}{COVID Forecast Hub}. It
augments a flat-line point prediction with a forecast distribution around
this point based on quantiles of symmetrized week-to-week residuals.
}
