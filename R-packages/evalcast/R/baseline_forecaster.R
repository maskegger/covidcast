#' Baseline forecaster
#'
#' The "flat-line" forecaster, which essentially mirrors the baseline in the
#' [COVID Forecast Hub](https://github.com/reichlab/covid19-forecast-hub). It
#' augments a flat-line point prediction with a forecast distribution around
#' this point based on quantiles of symmetrized week-to-week residuals.
#'
#' @param df_list list of data of the format that is returned by
#'   [covidcast::covidcast_signal()] or [covidcast::covidcast_signals()].  
#' @template forecast_date-template
#' @template incidence_period-template
#' @template ahead-template
#' @param symmetrize Should symmetrized residuals be used, or unsymmetrized
#'   (raw) residuals? Default is `TRUE`, which results in the flat-line point
#'   prediction. If `FALSE`, then point predictions can be increasing or
#'   decreasing, depending on the historical trend.
#'
#' @return Data frame with columns `ahead`, `geo_value`, `quantile`, `value`.
#'   The `quantile` column gives the predicted quantiles of the forecast
#'   distribution for that location and ahead. An NA indicates a point forecast
#'   (same as the median in this case).
#'
#' @export
baseline_forecaster <- function(df_list,
                                forecast_date,
                                incidence_period = c("epiweek", "day"),
                                ahead = 1:4,
                                symmetrize = TRUE) {
  incidence_period <- match.arg(incidence_period)
  forecast_date <- lubridate::ymd(forecast_date)
  target_period <- get_target_period(forecast_date, incidence_period, ahead)
  incidence_length <- ifelse(incidence_period == "epiweek", 7, 1)
  dat <- list()
  s <- ifelse(symmetrize, -1, NA)
  
  if (class(df_list)[1] == "list") df_list <- df_list[[1]]
  
  for (a in seq_along(ahead)) {
    # recall the first row of signals is the response
    dat[[a]] <- df_list %>%
      group_by(.data$geo_value) %>%
      arrange(.data$time_value) %>%
      mutate(summed = zoo::rollsum(.data$value, 
                                   k = incidence_length, fill = NA, 
                                   align = "right"),
             resid = .data$summed - 
               lag(.data$summed, n = incidence_length * ahead[a])) %>%
      select(.data$geo_value, .data$time_value, .data$summed, 
                    .data$resid) %>%
      group_modify(~ {
        point <- .x$summed[.x$time_value == max(.x$time_value)]
        tibble(quantile = c(covidhub_probs(), NA),
               value = point + c(stats::quantile(
                 c(.x$resid, s * .x$resid),
                 probs = covidhub_probs(),
                 na.rm = TRUE), 0)
               )
        }, .keep = TRUE) %>%
        ungroup() %>%
        mutate(value = pmax(.data$value, 0))
  }
  names(dat) <- as.character(ahead)
  bind_rows(dat, .id = "ahead") %>%
    mutate(ahead = as.integer(ahead))
}

