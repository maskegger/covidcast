#' Get predictions
#'
#' For each of the provided forecast dates, runs a forecaster using the data
#' that would have been available as of that given forecast date. Returns a list
#' of "predictions cards", where each list element corresponds to a different
#' forecast date. A predictions card is a data frame giving the forecast
#' distributions of a given forecaster for a given forecast task. A forecast
#' task is specified by the forecast date, ahead, response, incidence period,
#' and geo type (e.g., 1-epiweek-ahead death forecasting at the state level with
#' predictions made using the information as of September 14).
#'
#' @param forecaster Function that outputs a tibble with columns `ahead`,
#'   `geo_value`, `quantile`, and `value`. The `quantile` column gives the
#'   probabilities associated with quantile forecasts for that location and
#'   ahead. If your forecaster produces point forecasts, then set `quantile=NA`.
#'   
#'   One argument to `forecaster` must be named `df_list`. It will be 
#'   populated with the list of historical data returned by a call 
#'   to COVIDcast. The list will be the same length as the number of rows in 
#'   the `signals` tibble (see below).
#'   The forecaster will also receive a single `forecast_date` as a named argument.
#'   Any additional named arguments can be passed via the `forecaster_args`
#'   argument below.
#'   
#'   Thus, the forecaster should have a signature like 
#'   `forecaster(df_list = data, forecast_data = forecast_date, ...)`
#' @param name_of_forecaster String indicating name of the forecaster.
#' @template signals-template
#' @template forecast_dates-template
#' @template incidence_period-template
#' @template apply_corrections-template
#' @param response_data_source String indicating the `data_source` of the response.
#'   This is used mainly for downstream evaluation. By default, this will be the 
#'   same as the `data_source` in the first row of the `signals` tibble.
#' @param response_data_signal String indicating the `signal` of the response.
#'   This is used mainly for downstream evaluation. By default, this will be the 
#'   same as the `signal` in the first row in the `signals` tibble.
#' @param forecaster_args a list of additional named arguments to be passed 
#'   to `forecaster()`. A common use case would be to pass the period ahead
#'   (e.g. predict 1 day, 2 days, ..., k days ahead). Note that `ahead` is a 
#'   required component of the forecaster output (see above).
#'
#' @template predictions_cards-template
#' 
#'
#' @examples \dontrun{
#' baby_predictions = get_predictions(
#'   baseline_forecaster, "baby",
#'   tibble::tibble(
#'     data_source="jhu-csse",
#'     signal ="deaths_incidence_num",
#'     start_day="2020-08-15",
#'     geo_values = "mi",
#'     geo_type = "state"), 
#'   forecast_dates = "2020-10-01",
#'   incidence_period = "epiweek",
#'   forecaster_args = list(
#'     incidence_period = "epiweek",
#'     ahead = 1:4
#'   ))
#' }
#' 
#' @export
get_predictions <- function(forecaster,
                            name_of_forecaster,
                            signals,
                            forecast_dates,
                            incidence_period = c("epiweek", "day"),
                            apply_corrections = function(signals) signals,
                            response_data_source = signals$data_source[1],
                            response_data_signal = signals$signal[1],
                            forecaster_args = list()) {
  
  assert_that(is_tibble(signals), msg="`signals` should be a tibble.")
  
  
  out <- forecast_dates %>%
    map(~ do.call(
          get_predictions_single_date,
          list(forecaster = forecaster,
               signals = signals,
               forecast_date = .x,
               apply_corrections = apply_corrections,
               forecaster_args = forecaster_args)
          )
        ) %>%
    bind_rows()

  # for some reason, `value` gets named and ends up in attr
  names(out$value) = NULL 
  out <- out %>% 
    mutate(
      forecaster = name_of_forecaster,
      data_source = response_data_source,
      signal = response_data_signal,
      target_end_date = get_target_period(
        .data$forecast_date, 
        incidence_period, 
        .data$ahead)$end,
      incidence_period = incidence_period
      ) %>% 
    relocate(.data$forecaster, .before = .data$forecast_date)
  
  class(out) <- c("predictions_cards", class(out))
  out
}


get_predictions_single_date <- function(forecaster,
                                        signals,
                                        forecast_date,
                                        apply_corrections,
                                        forecaster_args) {

  forecast_date <- lubridate::ymd(forecast_date)
  signals <- signal_listcols(signals, forecast_date)
  
  df_list <- signals %>%
    pmap(function(...) {
      sig <- list(...)
      download_signal(
        data_source = sig$data_source,
        signal = sig$signal,
        start_day = sig$start_day,
        end_day = forecast_date,
        as_of = sig$as_of,
        geo_type = sig$geo_type,
        geo_values = sig$geo_values)
    })
  
  # Downloaded data postprocessing
  if(!is.null(apply_corrections)) df_list <- apply_corrections(df_list)

  forecaster_args$forecast_date = forecast_date
  forecaster_args$df_list <- df_list # pass in the data named to the right arg
  
  out <- do.call(forecaster, forecaster_args)
  assert_that(all(c("ahead", "geo_value", "quantile", "value") %in% names(out)),
              msg = paste("Your forecaster must return a data frame with",
                          "(at least) the columnns `ahead`, `geo_value`,",
                          "`quantile`, and `value`."))
  
  # make a predictions card
  out$forecast_date = forecast_date
  return(out)
}

