% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/quantgen.R
\name{quantgen_forecaster}
\alias{quantgen_forecaster}
\title{Simple quantile autoregressive forecaster based on \code{quantgen}}
\usage{
quantgen_forecaster(
  df,
  forecast_date,
  signals,
  incidence_period,
  ahead,
  geo_type,
  n = 4 * ifelse(incidence_period == "day", 7, 1),
  lags = 0,
  tau = modeltools::covidhub_probs,
  transform = NULL,
  inv_trans = NULL,
  featurize = NULL,
  noncross = FALSE,
  noncross_points = c("all", "test", "train"),
  cv_type = c("forward", "random"),
  verbose = FALSE,
  ...
)
}
\arguments{
\item{df}{Data frame of signal values to use for forecasting, of the format
that is returned by \code{\link[covidcast:covidcast_signals]{covidcast::covidcast_signals()}}.}

\item{forecast_date}{Date object or string of the form "YYYY-MM-DD",
indicating the date on which forecasts will be made. For example, if
\code{forecast_date = "2020-05-11"}, \code{incidence_period = "day"}, and \code{ahead = 3}, then, forecasts would be made for "2020-05-14".}

\item{signals}{Tibble with columns \code{data_source} and \code{signal} that specifies
which variables are being fetched from the COVIDcast API, and populated in
\code{df}. Each row of \code{signals} represents a separate signal, and first row is
taken to be the response. An optional column \code{start_day} can also be
included. This can be a Date object or string in the form "YYYY-MM-DD",
indicating the earliest date of data needed from that data source.
Importantly, \code{start_day} can also be a function (represented as a list
column) that takes a forecast date and returns a start date for model
training (again, Date object or string in the form "YYYY-MM-DD"). The
latter is useful when the start date should be computed dynamically from
the forecast date (e.g., when the forecaster only trains on the most recent
4 weeks of data).}

\item{incidence_period}{One of "day or "epiweek", indicating the period over
which forecasts are being made. Default is "day".}

\item{ahead}{Vector of ahead values, indicating how many days/epiweeks ahead
to forecast. If \code{incidence_period = "day"}, then \code{ahead = 1} means the day
after forecast date. If \code{incidence_period = "epiweek"} and the forecast
date falls on a Sunday or Monday, then \code{ahead = 1} means the epiweek that
includes the forecast date; if \code{forecast_date} falls on a Tuesday through
Saturday, then it means the following epiweek.}

\item{n}{Size of the local training window (in days/weeks, depending on
\code{incidence_period}) to use. For example, if \code{n = 14}, and \code{incidence_period = "day"}, then to make a 1-day-ahead forecast on December 15, we train on
data from December 1 to December 14.}

\item{lags}{Vector of lag values to use as features in the autoregressive
model. For example, when \code{incidence_period = "day"}, setting \code{lags = c(0, 7, 14)}means we use the current value of each signal (defined by a row of
the \code{signals} tibble), as well as the values 7 and 14 days ago, as the
features. Recall that the response is defined by the first row of the
\code{signals} tibble. Note that \code{lags} can also be a list of vectors of lag
values, this list having the same length as the number of rows of
\code{signals}, in order to apply a different set of shifts to each signal.
Default is 0, which means no additional lags (only current values) for each
signal.}

\item{tau}{Vector of quantile levels for the probabilistic forecast. If not
specified, defaults to the levels required by the COVID Forecast Hub.}

\item{transform, inv_trans}{Transformation and inverse transformations to use
for the response/features. The former \code{transform} can be a function or a
list of functions, this list having the same length as the number of rows
in the \code{signals} tibble, in order to apply the same transformation or a
different transformation to each signal. These transformations will be
applied before fitting the quantile model. The latter argument \code{inv_trans}
specifies the inverse transformation to use on the response variable
(inverse of \code{transform} if this is a function, or of \code{transform[[1]]} if
\code{transform} is a list), which will be applied post prediction from the
quantile model. Several convenience functions for transformations exist as
part of the \code{quantgen} package. Default is \code{NULL} for both \code{transform} and
\code{inv_trans}, which means no transformations are applied.}

\item{featurize}{Function to construct custom features before the quantile
model is fit. As input, this function must take a data frame with columns
\code{geo_value}, \code{time_value}, then the transformed, lagged signal values. This
function must return a data frame with columns \code{geo_value}, \code{time_value},
then any custom features. The rows of the returned data frame \emph{must not} be
reordered.}

\item{noncross}{Should noncrossing constraints be applied? These force the
predicted quantiles to be properly ordered across all quantile levels being
considered. The default is \code{FALSE}. If \code{TRUE}, then noncrossing constraints
are applied to the estimated quantiles at all points specified by the next
argument.}

\item{noncross_points}{One of "all", "test", "train" indicating which points
to use for the noncrossing constraints: the default "all" means to use both
training and testing sets combined, while "test" or "train" means to use
just one set, training or testing, respectively.}

\item{cv_type}{One of "forward" or "random", indicating the type of
cross-validation to perform. If "random", then \code{nfolds} folds are chosen by
dividing training data points randomly (the default being \code{nfolds = 5}). If
"forward", the default, then we instead use a "forward-validation" approach
that better reflects the way predictions are made in the current time
series forecasting context. Roughly, this works as follows: the data points
from the first \code{n - nfolds} time values are used for model training, and
then predictions are made at the earliest possible forecast date after this
training period. We march forward one time point at a time and repeat. In
either case ("random" or "forward"), the loss function used for computing
validation error is quantile regression loss (read the documentation for
\code{quantgen::cv_quantile_lasso()} for more details); and the final quantile
model is refit on the full training set using the validation-optimal tuning
parameter.}

\item{verbose}{Should progress be printed out to the console? Default is
\code{FALSE}.}

\item{...}{Additional arguments. Any parameter accepted by
\code{quantgen::cv_quantile_lasso()} (for model training) or by
\code{quantgen:::predict.cv_quantile_genlasso()} (for model prediction) can be
passed here. For example, \code{nfolds}, for specifying the number of folds used
in cross-validation, or \code{lambda}, for specifying the tuning parameter
values over which to perform cross-validation (the default allows
\code{quantgen::cv_quantile_lasso()} to set the lambda sequence itself). Note
that fixing a single tuning parameter value (such as \code{lambda = 0})
effectively disables cross-validation and fits a quantile model at the
given tuning parameter value (here unregularized quantile autoregression).}
}
\value{
Data frame with columns \code{ahead}, \code{geo_value}, \code{quantile}, and
\code{value}. The \code{quantile} column gives the probabilities associated with
quantile forecasts for that location and ahead.
}
\description{
A simple quantile autoregressive forecaster based on \code{quantgen}, to be used
with \code{evalcast}, via \code{\link[evalcast:get_predictions]{evalcast::get_predictions()}}. See the \href{https://cmu-delphi.github.io/covidcast/modeltoolsR/articles/quantgen-forecast.html}{quantgen forecast vignette}
for examples.
}
